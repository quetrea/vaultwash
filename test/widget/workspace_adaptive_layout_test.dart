import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaultwash/app/theme/app_theme.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_preview.dart';
import 'package:vaultwash/features/scan/application/scan_controller.dart';
import 'package:vaultwash/features/scan/domain/scan_file_result.dart';
import 'package:vaultwash/features/scan/domain/scan_summary.dart';
import 'package:vaultwash/features/scan/presentation/workspace_screen.dart';
import 'package:vaultwash/features/settings/infrastructure/settings_local_data_source.dart';
import 'package:vaultwash/features/vault/application/vault_controller.dart';
import 'package:vaultwash/features/vault/domain/vault_ref.dart';

ScanFileResult _buildFileResult({
  required int matchCount,
  required String relativePath,
  required String hash,
}) {
  final excerpts = List.generate(
    matchCount,
    (index) => PreviewExcerpt(
      ruleId: 'oaicite_content_reference',
      originalExcerpt:
          'Before artifact ${index + 1} in $relativePath :contentReference[oaicite:${index + 1}]',
      cleanedExcerpt: 'Before artifact ${index + 1} in $relativePath',
    ),
  );
  final matches = List.generate(
    matchCount,
    (index) => CleanupMatch(
      ruleId: 'oaicite_content_reference',
      snippet: ':contentReference[oaicite:${index + 1}]',
      start: index * 12,
      end: index * 12 + 8,
    ),
  );

  return ScanFileResult(
    absolutePath: '/vault/$relativePath',
    relativePath: relativePath,
    matchCount: matchCount,
    matchedSnippets: matches.map((match) => match.snippet).toList(),
    cleanedPreviewContent: 'Cleaned content for $relativePath',
    originalContentHash: hash,
    preview: CleanupPreview(
      originalContent: 'Original content for $relativePath',
      cleanedContent: 'Cleaned content for $relativePath',
      matchCount: matchCount,
      matchedSnippets: matches.map((match) => match.snippet).toList(),
      excerpts: excerpts,
      originalContentHash: hash,
      matches: matches,
    ),
  );
}

ScanWorkspaceState _buildWorkspaceState({
  List<ScanFileResult>? files,
  String? focusedRelativePath,
}) {
  final affectedFiles =
      files ??
      [
        _buildFileResult(
          matchCount: 3,
          relativePath: 'notes/chapter.md',
          hash: 'chapter-hash',
        ),
        _buildFileResult(
          matchCount: 2,
          relativePath: 'notes/appendix.md',
          hash: 'appendix-hash',
        ),
      ];

  return ScanWorkspaceState(
    summary: ScanSummary(
      totalFilesScanned: 18,
      filesWithMatches: affectedFiles.length,
      totalMatchesFound: affectedFiles.fold<int>(
        0,
        (total, file) => total + file.matchCount,
      ),
      failureCount: 0,
    ),
    affectedFiles: affectedFiles,
    selectedPaths: {affectedFiles.first.relativePath},
    focusedRelativePath:
        focusedRelativePath ?? affectedFiles.first.relativePath,
    lastScannedAt: DateTime(2026, 4, 13, 10, 30),
    statusMessage:
        'Scan complete. Review affected files before cleaning anything.',
  );
}

Future<ProviderContainer> _pumpWorkspace(
  WidgetTester tester, {
  required Size size,
  required ScanWorkspaceState workspace,
}) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
  );

  addTearDown(container.dispose);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const WorkspaceScreen(),
      ),
    ),
  );

  await container.read(vaultControllerProvider.future);
  await container.read(scanControllerProvider.future);
  container.read(vaultControllerProvider.notifier).state = const AsyncData(
    VaultRef(absolutePath: '/vault', name: 'vault'),
  );
  container.read(scanControllerProvider.notifier).state = AsyncData(workspace);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));

  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('wide desktop keeps the full tri-pane workspace visible', (
    tester,
  ) async {
    await _pumpWorkspace(
      tester,
      size: const Size(1560, 980),
      workspace: _buildWorkspaceState(),
    );

    expect(find.byKey(const ValueKey('workspace-layout-wide')), findsOneWidget);
    expect(find.text('Scan summary'), findsOneWidget);
    expect(find.text('Affected files'), findsWidgets);
    expect(find.text('INSPECTOR'), findsOneWidget);
    expect(find.byKey(const ValueKey('workspace-files-pane')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('workspace-preview-pane')),
      findsOneWidget,
    );
  });

  testWidgets('standard desktop stays tri-pane with tighter proportions', (
    tester,
  ) async {
    await _pumpWorkspace(
      tester,
      size: const Size(1320, 920),
      workspace: _buildWorkspaceState(),
    );

    expect(
      find.byKey(const ValueKey('workspace-layout-standard')),
      findsOneWidget,
    );
    expect(find.text('Scan summary'), findsOneWidget);
    expect(find.text('Affected files'), findsWidgets);
    expect(find.text('INSPECTOR'), findsOneWidget);
    expect(find.text('Clean selected'), findsOneWidget);
  });

  testWidgets('compact desktop uses a switchable files and review workspace', (
    tester,
  ) async {
    await _pumpWorkspace(
      tester,
      size: const Size(1100, 920),
      workspace: _buildWorkspaceState(),
    );

    expect(
      find.byKey(const ValueKey('workspace-layout-compact')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('workspace-compact-switcher')),
      findsOneWidget,
    );
    expect(find.text('Affected files'), findsWidgets);
    expect(find.text('INSPECTOR'), findsNothing);

    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();

    expect(find.text('INSPECTOR'), findsOneWidget);
    expect(find.text('chapter.md'), findsWidgets);
  });

  testWidgets('selected file context survives a resize into compact mode', (
    tester,
  ) async {
    final workspace = _buildWorkspaceState(
      focusedRelativePath: 'notes/appendix.md',
    );
    final container = await _pumpWorkspace(
      tester,
      size: const Size(1500, 940),
      workspace: workspace,
    );

    expect(find.byKey(const ValueKey('workspace-layout-wide')), findsOneWidget);
    expect(find.text('appendix.md'), findsWidgets);

    tester.view.physicalSize = const Size(1100, 920);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      find.byKey(const ValueKey('workspace-layout-compact')),
      findsOneWidget,
    );
    expect(find.textContaining('notes/appendix.md selected'), findsOneWidget);
    expect(
      container.read(scanControllerProvider).asData?.value.focusedRelativePath,
      'notes/appendix.md',
    );

    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();

    expect(find.text('appendix.md'), findsWidgets);
  });

  testWidgets('below the compact threshold shows a minimum-width fallback', (
    tester,
  ) async {
    await _pumpWorkspace(
      tester,
      size: const Size(900, 900),
      workspace: _buildWorkspaceState(),
    );

    expect(
      find.byKey(const ValueKey('workspace-layout-constrained')),
      findsOneWidget,
    );
    expect(find.textContaining('960 px or wider'), findsOneWidget);
  });
}
