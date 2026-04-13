import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:vaultwash/features/cleanup/application/cleanup_engine.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_rule.dart';
import 'package:vaultwash/features/cleanup/infrastructure/cleanup_patterns.dart';
import 'package:vaultwash/features/cleanup/infrastructure/cleanup_writer.dart';
import 'package:vaultwash/features/scan/domain/scan_file_result.dart';

void main() {
  const engine = CleanupEngine();
  const writer = CleanupWriter();
  final rule = CleanupRule(
    id: 'oaicite_content_reference',
    label: 'Remove broken oaicite contentReference artifacts',
    description:
        'Removes patterns such as :contentReference[oaicite:...]{...} from markdown files.',
    pattern: CleanupPatterns.oaiciteContentReference,
    replacement: '',
    enabledByDefault: true,
  );

  late Directory tempDirectory;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'vault_wash_writer_test',
    );
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('creates backups and writes cleaned content', () async {
    final file = File(p.join(tempDirectory.path, 'note.md'));
    const original = 'Keep :contentReference[oaicite:10]{index=10} this clean.';
    await file.writeAsString(original);

    final preview = engine.generatePreview(original, [rule]);
    final result = await writer.execute(
      files: [
        ScanFileResult(
          absolutePath: file.path,
          relativePath: 'note.md',
          matchCount: preview.matchCount,
          matchedSnippets: preview.matchedSnippets,
          cleanedPreviewContent: preview.cleanedContent,
          originalContentHash: preview.originalContentHash,
          preview: preview,
        ),
      ],
      createBackups: true,
    );

    expect(result.successCount, 1);
    expect(await File('${file.path}.bak').exists(), isTrue);
    expect(
      await file.readAsString(),
      isNot(contains(':contentReference[oaicite:')),
    );
  });

  test('skips writes when the file changed after scan', () async {
    final file = File(p.join(tempDirectory.path, 'note.md'));
    const original = 'Keep :contentReference[oaicite:10]{index=10} this clean.';
    await file.writeAsString(original);

    final preview = engine.generatePreview(original, [rule]);
    await file.writeAsString('A different version of the file.');

    final result = await writer.execute(
      files: [
        ScanFileResult(
          absolutePath: file.path,
          relativePath: 'note.md',
          matchCount: preview.matchCount,
          matchedSnippets: preview.matchedSnippets,
          cleanedPreviewContent: preview.cleanedContent,
          originalContentHash: preview.originalContentHash,
          preview: preview,
        ),
      ],
      createBackups: false,
    );

    expect(result.skippedCount, 1);
    expect(await file.readAsString(), 'A different version of the file.');
  });

  test(
    'returns aggregate results when one file fails and one succeeds',
    () async {
      final goodFile = File(p.join(tempDirectory.path, 'good.md'));
      final badFile = File(p.join(tempDirectory.path, 'missing.md'));
      const original =
          'Keep :contentReference[oaicite:10]{index=10} this clean.';

      await goodFile.writeAsString(original);
      await badFile.writeAsString(original);

      final goodPreview = engine.generatePreview(original, [rule]);
      final badPreview = engine.generatePreview(original, [rule]);

      await badFile.delete();

      final result = await writer.execute(
        files: [
          ScanFileResult(
            absolutePath: goodFile.path,
            relativePath: 'good.md',
            matchCount: goodPreview.matchCount,
            matchedSnippets: goodPreview.matchedSnippets,
            cleanedPreviewContent: goodPreview.cleanedContent,
            originalContentHash: goodPreview.originalContentHash,
            preview: goodPreview,
          ),
          ScanFileResult(
            absolutePath: badFile.path,
            relativePath: 'missing.md',
            matchCount: badPreview.matchCount,
            matchedSnippets: badPreview.matchedSnippets,
            cleanedPreviewContent: badPreview.cleanedContent,
            originalContentHash: badPreview.originalContentHash,
            preview: badPreview,
          ),
        ],
        createBackups: false,
      );

      expect(result.successCount, 1);
      expect(result.failureCount, 1);
      expect(result.attemptedCount, 2);
    },
  );
}
