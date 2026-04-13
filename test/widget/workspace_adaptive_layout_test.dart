import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaultwash/app/theme/app_theme.dart';
import 'package:vaultwash/features/cleanup/application/inspector_controller.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_preview.dart';
import 'package:vaultwash/features/cleanup/domain/inspector_mode.dart';
import 'package:vaultwash/features/scan/application/scan_controller.dart';
import 'package:vaultwash/features/scan/domain/scan_file_result.dart';
import 'package:vaultwash/features/scan/domain/scan_summary.dart';
import 'package:vaultwash/features/scan/presentation/workspace_layout.dart';
import 'package:vaultwash/features/scan/presentation/workspace_screen.dart';
import 'package:vaultwash/features/settings/infrastructure/settings_local_data_source.dart';
import 'package:vaultwash/features/vault/application/vault_controller.dart';
import 'package:vaultwash/features/vault/domain/vault_ref.dart';
import 'package:vaultwash/features/workspace/application/workspace_preferences_controller.dart';

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
  Map<String, Object> preferenceValues = const {},
}) async {
  SharedPreferences.setMockInitialValues(preferenceValues);
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

  testWidgets('wide desktop lets users resize panes within controlled bounds', (
    tester,
  ) async {
    final container = await _pumpWorkspace(
      tester,
      size: const Size(1560, 980),
      workspace: _buildWorkspaceState(),
    );

    final initialRailWidth = tester
        .getSize(find.byKey(const ValueKey('workspace-left-rail-host')))
        .width;
    final initialPreviewWidth = tester
        .getSize(find.byKey(const ValueKey('workspace-preview-pane-host')))
        .width;

    await tester.drag(
      find.byKey(const ValueKey('workspace-rail-resize-handle')),
      const Offset(120, 0),
    );
    await tester.pumpAndSettle();

    final widenedRailWidth = tester
        .getSize(find.byKey(const ValueKey('workspace-left-rail-host')))
        .width;
    expect(widenedRailWidth, greaterThan(initialRailWidth));
    expect(
      container.read(workspacePreferencesControllerProvider).desktopRailWidth,
      closeTo(widenedRailWidth, 0.5),
    );

    await tester.drag(
      find.byKey(const ValueKey('workspace-rail-resize-handle')),
      const Offset(-900, 0),
    );
    await tester.pumpAndSettle();

    final narrowedRailWidth = tester
        .getSize(find.byKey(const ValueKey('workspace-left-rail-host')))
        .width;
    expect(
      narrowedRailWidth,
      closeTo(WorkspaceLayoutSpec.wide.minDesktopRailWidth, 0.5),
    );

    await tester.drag(
      find.byKey(const ValueKey('workspace-preview-resize-handle')),
      const Offset(-180, 0),
    );
    await tester.pumpAndSettle();

    final expandedPreviewWidth = tester
        .getSize(find.byKey(const ValueKey('workspace-preview-pane-host')))
        .width;
    expect(expandedPreviewWidth, greaterThan(initialPreviewWidth));
    final savedPreviewFraction = container
        .read(workspacePreferencesControllerProvider)
        .desktopPreviewFraction;
    expect(savedPreviewFraction, isNotNull);
    expect(savedPreviewFraction!, greaterThan(0.5));
  });

  testWidgets('summary can collapse and expand without hiding review panes', (
    tester,
  ) async {
    await _pumpWorkspace(
      tester,
      size: const Size(1500, 940),
      workspace: _buildWorkspaceState(),
    );

    expect(
      find.byKey(const ValueKey('scan-summary-expanded-content')),
      findsOneWidget,
    );
    expect(find.text('Affected files'), findsWidgets);
    expect(find.text('INSPECTOR'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('workspace-summary-toggle')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('scan-summary-collapsed-content')),
      findsOneWidget,
    );
    expect(find.text('Affected files'), findsWidgets);
    expect(find.text('INSPECTOR'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('workspace-summary-toggle')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('scan-summary-expanded-content')),
      findsOneWidget,
    );
  });

  testWidgets('restores persisted workspace state on relaunch', (tester) async {
    final container = await _pumpWorkspace(
      tester,
      size: const Size(1560, 980),
      workspace: _buildWorkspaceState(),
      preferenceValues: const {
        'workspace.desktop_rail_width': 336.0,
        'workspace.desktop_preview_fraction': 0.60,
        'workspace.summary_collapsed': true,
        'workspace.inspector_mode': 'changes',
      },
    );

    expect(
      find.byKey(const ValueKey('scan-summary-collapsed-content')),
      findsOneWidget,
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey('workspace-left-rail-host')))
          .width,
      closeTo(336, 0.5),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey('workspace-preview-pane-host')))
          .width,
      greaterThan(
        tester
            .getSize(find.byKey(const ValueKey('workspace-center-pane-host')))
            .width,
      ),
    );
    expect(
      container.read(workspacePreferencesControllerProvider).summaryCollapsed,
      isTrue,
    );
    expect(
      container.read(inspectorControllerProvider).mode,
      InspectorMode.changes,
    );
  });
}
