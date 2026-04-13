import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaultwash/app/theme/app_theme.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_preview.dart';
import 'package:vaultwash/features/cleanup/presentation/preview_panel.dart';
import 'package:vaultwash/features/scan/domain/scan_file_result.dart';
import 'package:vaultwash/features/scan/presentation/affected_files_list.dart';

ScanFileResult buildFileResult({
  required int matchCount,
  String relativePath = 'notes/chapter.md',
  String originalContentHash = 'hash',
}) {
  final excerpts = List.generate(
    matchCount,
    (index) => PreviewExcerpt(
      ruleId: 'oaicite_content_reference',
      originalExcerpt: [
        'Before artifact ${index + 1}',
        List.filled(24, 'original segment ${index + 1}').join(' '),
      ].join(' '),
      cleanedExcerpt: [
        'After artifact ${index + 1}',
        List.filled(24, 'cleaned segment ${index + 1}').join(' '),
      ].join(' '),
    ),
  );

  final matches = List.generate(
    matchCount,
    (index) => CleanupMatch(
      ruleId: 'oaicite_content_reference',
      snippet: ':contentReference[oaicite:${index + 1}]{index=${index + 1}}',
      start: index * 10,
      end: index * 10 + 5,
    ),
  );

  return ScanFileResult(
    absolutePath: '/vault/$relativePath',
    relativePath: relativePath,
    matchCount: matchCount,
    matchedSnippets: matches.map((match) => match.snippet).toList(),
    cleanedPreviewContent: 'Cleaned file content',
    originalContentHash: originalContentHash,
    preview: CleanupPreview(
      originalContent: 'Original file content',
      cleanedContent: 'Cleaned file content',
      matchCount: matchCount,
      matchedSnippets: matches.map((match) => match.snippet).toList(),
      excerpts: excerpts,
      originalContentHash: originalContentHash,
      matches: matches,
    ),
  );
}

void main() {
  testWidgets('renders affected files and preview excerpts', (tester) async {
    var focusedPath = '';
    var toggledPath = '';
    var toggledValue = false;

    const fileResult = ScanFileResult(
      absolutePath: '/vault/notes/chapter.md',
      relativePath: 'notes/chapter.md',
      matchCount: 2,
      matchedSnippets: ['contentReference artifact'],
      cleanedPreviewContent: 'Cleaned file content',
      originalContentHash: 'hash',
      preview: CleanupPreview(
        originalContent: 'Original file content',
        cleanedContent: 'Cleaned file content',
        matchCount: 2,
        matchedSnippets: ['contentReference artifact'],
        excerpts: [
          PreviewExcerpt(
            ruleId: 'oaicite_content_reference',
            originalExcerpt:
                'Before :contentReference[oaicite:10]{index=10} after',
            cleanedExcerpt: 'Before  after',
          ),
        ],
        originalContentHash: 'hash',
        matches: [
          CleanupMatch(
            ruleId: 'oaicite_content_reference',
            snippet: ':contentReference[oaicite:10]{index=10}',
            start: 7,
            end: 47,
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: Scaffold(
          body: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 420,
                  child: AffectedFilesList(
                    files: const [fileResult],
                    selectedPaths: const {'notes/chapter.md'},
                    focusedRelativePath: 'notes/chapter.md',
                    onToggleSelection: (path, selected) {
                      toggledPath = path;
                      toggledValue = selected;
                    },
                    onFocusFile: (path) => focusedPath = path,
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 420,
                  child: ProviderScope(
                    child: PreviewPanel(fileResult: fileResult),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // File list shows full relative path; inspector header shows only filename.
    expect(find.text('notes/chapter.md'), findsOneWidget);
    expect(find.text('chapter.md'), findsOneWidget);
    expect(find.text('Affected files'), findsOneWidget);
    // Inspector eyebrow and mode labels
    expect(find.text('INSPECTOR'), findsOneWidget);
    expect(find.text('Excerpts'), findsOneWidget);
    expect(find.text('Changes'), findsOneWidget);
    // Excerpts mode (default) renders before/after columns
    expect(find.text('Before'), findsOneWidget);
    expect(find.text('After'), findsOneWidget);
    expect(find.textContaining('contentReference'), findsWidgets);

    await tester.tap(find.text('notes/chapter.md').first);
    await tester.pump();

    expect(focusedPath, 'notes/chapter.md');

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    expect(toggledPath, 'notes/chapter.md');
    expect(toggledValue, isFalse);
  });

  testWidgets(
    'returns to offscreen matches after manual scrolling and arrow navigation',
    (tester) async {
      final fileResult = buildFileResult(matchCount: 10);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 720,
                height: 320,
                child: ProviderScope(
                  child: PreviewPanel(fileResult: fileResult),
                ),
              ),
            ),
          ),
        ),
      );

      final scrollable = find.byKey(
        const ValueKey('inspector-match-scrollable'),
      );

      await tester.drag(scrollable, const Offset(0, -1400));
      await tester.pumpAndSettle();

      expect(find.text('1 of 10'), findsOneWidget);

      await tester.tap(find.byTooltip('Next match'));
      await tester.pumpAndSettle();

      final viewportTop = tester.getTopLeft(scrollable).dy;
      final viewportBottom = tester.getBottomLeft(scrollable).dy;
      final matchTwoCenter = tester.getCenter(find.text('Match 2')).dy;

      expect(find.text('2 of 10'), findsOneWidget);
      expect(matchTwoCenter, greaterThanOrEqualTo(viewportTop - 24));
      expect(matchTwoCenter, lessThan(viewportBottom));
    },
  );

  testWidgets(
    'shows every match count when preview contains more than twelve excerpts',
    (tester) async {
      final fileResult = buildFileResult(matchCount: 20);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 720,
                height: 320,
                child: ProviderScope(
                  child: PreviewPanel(fileResult: fileResult),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('20 artifacts'), findsOneWidget);
      expect(find.text('1 of 20'), findsOneWidget);
    },
  );

  testWidgets('switching files resets the inspector list scroll position', (
    tester,
  ) async {
    final firstFile = buildFileResult(
      matchCount: 10,
      relativePath: 'notes/first.md',
      originalContentHash: 'first-hash',
    );
    final secondFile = buildFileResult(
      matchCount: 10,
      relativePath: 'notes/second.md',
      originalContentHash: 'second-hash',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 720,
              height: 320,
              child: ProviderScope(child: PreviewPanel(fileResult: firstFile)),
            ),
          ),
        ),
      ),
    );

    final scrollable = find.byKey(const ValueKey('inspector-match-scrollable'));

    await tester.drag(scrollable, const Offset(0, -1400));
    await tester.pumpAndSettle();

    expect(find.text('first.md'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 720,
              height: 320,
              child: ProviderScope(child: PreviewPanel(fileResult: secondFile)),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final viewportTop = tester.getTopLeft(scrollable).dy;
    final matchOneCenter = tester.getCenter(find.text('Match 1')).dy;

    expect(find.text('second.md'), findsOneWidget);
    expect(find.text('1 of 10'), findsOneWidget);
    expect(matchOneCenter, greaterThanOrEqualTo(viewportTop - 24));
  });
}
