import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaultwash/app/theme/app_theme.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_preview.dart';
import 'package:vaultwash/features/cleanup/presentation/preview_panel.dart';
import 'package:vaultwash/features/scan/domain/scan_file_result.dart';
import 'package:vaultwash/features/scan/presentation/affected_files_list.dart';

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
              const Expanded(
                child: SizedBox(
                  height: 420,
                  child: PreviewPanel(fileResult: fileResult),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('notes/chapter.md'), findsNWidgets(2));
    expect(find.text('Affected files'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);
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
}
