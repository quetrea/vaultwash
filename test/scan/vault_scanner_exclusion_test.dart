import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:vaultwash/features/cleanup/application/cleanup_engine.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_rule.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_rule_category.dart';
import 'package:vaultwash/features/cleanup/infrastructure/cleanup_patterns.dart';
import 'package:vaultwash/features/scan/domain/scan_request.dart';
import 'package:vaultwash/features/scan/infrastructure/vault_scanner.dart';
import 'package:vaultwash/features/vault/domain/vault_ref.dart';

void main() {
  const scanner = VaultScanner(CleanupEngine());

  final rule = CleanupRule(
    id: 'oaicite_content_reference',
    label: 'Remove oaicite contentReference artifacts',
    description: 'Test rule.',
    pattern: CleanupPatterns.oaiciteContentReference,
    replacement: '',
    enabledByDefault: true,
    category: CleanupRuleCategory.aiArtifact,
  );

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('vault_scanner_exclusion_');

    // Vault structure:
    //   note.md              — has artifact (should be found)
    //   archive/old.md       — has artifact (excluded by custom name)
    //   drafts/draft.md      — has artifact (not excluded)
    //   temp/junk.md         — has artifact (excluded by custom name)

    await Directory(p.join(tempDir.path, 'archive')).create();
    await Directory(p.join(tempDir.path, 'drafts')).create();
    await Directory(p.join(tempDir.path, 'temp')).create();

    const artifact = ':contentReference[oaicite:1]{index=1}';
    await File(p.join(tempDir.path, 'note.md')).writeAsString(artifact);
    await File(
      p.join(tempDir.path, 'archive', 'old.md'),
    ).writeAsString(artifact);
    await File(
      p.join(tempDir.path, 'drafts', 'draft.md'),
    ).writeAsString(artifact);
    await File(
      p.join(tempDir.path, 'temp', 'junk.md'),
    ).writeAsString(artifact);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('excludedFolderNames skips matching directories', () async {
    final result = await scanner.scan(
      ScanRequest(
        vault: VaultRef.fromPath(tempDir.path),
        enabledRules: [rule],
        excludeObsidian: true,
        excludeHiddenFolders: false,
        excludedFolderNames: ['archive', 'temp'],
      ),
    );

    final paths = result.affectedFiles.map((f) => f.relativePath).toList();

    // note.md and drafts/draft.md should be found.
    expect(paths, containsAll(['note.md', p.join('drafts', 'draft.md')]));

    // archive/ and temp/ should be skipped entirely.
    expect(paths, isNot(contains(p.join('archive', 'old.md'))));
    expect(paths, isNot(contains(p.join('temp', 'junk.md'))));
    expect(result.summary.filesWithMatches, 2);
  });

  test('empty excludedFolderNames skips nothing extra', () async {
    final result = await scanner.scan(
      ScanRequest(
        vault: VaultRef.fromPath(tempDir.path),
        enabledRules: [rule],
        excludeObsidian: true,
        excludeHiddenFolders: false,
        excludedFolderNames: const [],
      ),
    );

    expect(result.summary.filesWithMatches, 4);
  });

  test('excludedFolderNames is case-sensitive', () async {
    // 'Archive' (capital A) should NOT exclude the lowercase 'archive' folder.
    final result = await scanner.scan(
      ScanRequest(
        vault: VaultRef.fromPath(tempDir.path),
        enabledRules: [rule],
        excludeObsidian: true,
        excludeHiddenFolders: false,
        excludedFolderNames: ['Archive'],
      ),
    );

    // All 4 files should still be found — 'archive' != 'Archive'.
    expect(result.summary.filesWithMatches, 4);
  });
}
