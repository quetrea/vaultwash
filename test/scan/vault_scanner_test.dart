import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:vaultwash/features/cleanup/application/cleanup_engine.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_rule.dart';
import 'package:vaultwash/features/cleanup/infrastructure/cleanup_patterns.dart';
import 'package:vaultwash/features/scan/domain/scan_request.dart';
import 'package:vaultwash/features/scan/infrastructure/vault_scanner.dart';
import 'package:vaultwash/features/vault/domain/vault_ref.dart';

void main() {
  const scanner = VaultScanner(CleanupEngine());
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
      'vault_wash_scanner_test',
    );

    await Directory(p.join(tempDirectory.path, '.obsidian')).create();
    await Directory(p.join(tempDirectory.path, '.trash')).create();
    await Directory(p.join(tempDirectory.path, '.hidden')).create();
    await Directory(p.join(tempDirectory.path, 'nested')).create();

    await File(
      p.join(tempDirectory.path, 'note.md'),
    ).writeAsString('Keep :contentReference[oaicite:10]{index=10} this clean.');
    await File(
      p.join(tempDirectory.path, 'clean.md'),
    ).writeAsString('Already clean.');
    await File(
      p.join(tempDirectory.path, '.obsidian', 'ignored.md'),
    ).writeAsString(':contentReference[oaicite:20]{index=20}');
    await File(
      p.join(tempDirectory.path, '.trash', 'ignored.md'),
    ).writeAsString(':contentReference[oaicite:21]{index=21}');
    await File(
      p.join(tempDirectory.path, '.hidden', 'hidden.md'),
    ).writeAsString(':contentReference[oaicite:22]{index=22}');
    await File(
      p.join(tempDirectory.path, 'nested', 'deep.md'),
    ).writeAsString(':contentReference[oaicite:23]{index=23}');
    await File(
      p.join(tempDirectory.path, 'binary.txt'),
    ).writeAsString(':contentReference[oaicite:24]{index=24}');
    await File(
      p.join(tempDirectory.path, 'broken.md'),
    ).writeAsBytes(<int>[0xFF, 0xFF, 0xFF]);
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test(
    'recursively scans markdown files and excludes obsidian and trash by default',
    () async {
      final result = await scanner.scan(
        ScanRequest(
          vault: VaultRef.fromPath(tempDirectory.path),
          enabledRules: [rule],
          excludeObsidian: true,
          excludeHiddenFolders: false,
        ),
      );

      expect(result.summary.totalFilesScanned, 5);
      expect(result.summary.filesWithMatches, 3);
      expect(result.summary.totalMatchesFound, 3);
      expect(result.summary.failureCount, 1);
      expect(
        result.affectedFiles.map((file) => file.relativePath),
        containsAll(<String>['note.md', '.hidden/hidden.md', 'nested/deep.md']),
      );
      expect(result.failures.single.relativePath, 'broken.md');
    },
  );

  test('respects hidden-folder exclusion', () async {
    final result = await scanner.scan(
      ScanRequest(
        vault: VaultRef.fromPath(tempDirectory.path),
        enabledRules: [rule],
        excludeObsidian: true,
        excludeHiddenFolders: true,
      ),
    );

    expect(result.summary.totalFilesScanned, 4);
    expect(
      result.affectedFiles.map((file) => file.relativePath),
      isNot(contains('.hidden/hidden.md')),
    );
  });
}
