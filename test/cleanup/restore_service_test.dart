import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:vaultwash/features/cleanup/domain/cleanup_session.dart';
import 'package:vaultwash/features/cleanup/infrastructure/restore_service.dart';

void main() {
  const service = RestoreService();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('restore_service_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  CleanupSession makeSession(List<String> relativePaths) {
    return CleanupSession(
      id: '1',
      timestamp: DateTime.now(),
      ruleIds: [],
      ruleLabels: [],
      vaultPath: tempDir.path,
      vaultName: 'TestVault',
      filesChanged: relativePaths.length,
      filesSkipped: 0,
      filesFailed: 0,
      backupsCreated: true,
      changedRelativePaths: relativePaths,
    );
  }

  // ── sessionHasBackups ─────────────────────────────────────────────────────

  group('sessionHasBackups', () {
    test('returns false when no backup files exist', () async {
      await File(p.join(tempDir.path, 'note.md')).writeAsString('content');
      final session = makeSession(['note.md']);

      final result = await service.sessionHasBackups(
        session: session,
        vaultAbsolutePath: tempDir.path,
      );
      expect(result, isFalse);
    });

    test('returns true when at least one .bak file exists', () async {
      await File(p.join(tempDir.path, 'note.md')).writeAsString('current');
      await File(p.join(tempDir.path, 'note.md.bak')).writeAsString('original');
      final session = makeSession(['note.md']);

      final result = await service.sessionHasBackups(
        session: session,
        vaultAbsolutePath: tempDir.path,
      );
      expect(result, isTrue);
    });

    test('returns false for empty changed paths', () async {
      final session = makeSession([]);

      final result = await service.sessionHasBackups(
        session: session,
        vaultAbsolutePath: tempDir.path,
      );
      expect(result, isFalse);
    });
  });

  // ── restoreSession ────────────────────────────────────────────────────────

  group('restoreSession', () {
    test('restores content from .bak and deletes the backup', () async {
      final notePath = p.join(tempDir.path, 'note.md');
      final bakPath = '$notePath.bak';

      await File(notePath).writeAsString('cleaned content');
      await File(bakPath).writeAsString('original content');

      final session = makeSession(['note.md']);
      final result = await service.restoreSession(
        session: session,
        vaultAbsolutePath: tempDir.path,
      );

      expect(result.restoredCount, 1);
      expect(result.missingBackupsCount, 0);
      expect(result.errorCount, 0);
      expect(await File(notePath).readAsString(), 'original content');
      expect(await File(bakPath).exists(), isFalse);
    });

    test('counts missing backups when .bak file does not exist', () async {
      await File(p.join(tempDir.path, 'note.md')).writeAsString('cleaned');
      final session = makeSession(['note.md']);

      final result = await service.restoreSession(
        session: session,
        vaultAbsolutePath: tempDir.path,
      );

      expect(result.restoredCount, 0);
      expect(result.missingBackupsCount, 1);
    });

    test('restores multiple files from the same session', () async {
      for (final name in ['a.md', 'b.md', 'c.md']) {
        await File(p.join(tempDir.path, name)).writeAsString('cleaned-$name');
        await File(p.join(tempDir.path, '$name.bak'))
            .writeAsString('original-$name');
      }

      final session = makeSession(['a.md', 'b.md', 'c.md']);
      final result = await service.restoreSession(
        session: session,
        vaultAbsolutePath: tempDir.path,
      );

      expect(result.restoredCount, 3);
      expect(result.missingBackupsCount, 0);

      for (final name in ['a.md', 'b.md', 'c.md']) {
        final content = await File(p.join(tempDir.path, name)).readAsString();
        expect(content, 'original-$name');
      }
    });

    test('partial restore: some backups missing, some present', () async {
      await File(p.join(tempDir.path, 'with-backup.md'))
          .writeAsString('cleaned');
      await File(p.join(tempDir.path, 'with-backup.md.bak'))
          .writeAsString('original');
      await File(p.join(tempDir.path, 'no-backup.md')).writeAsString('cleaned');

      final session = makeSession(['with-backup.md', 'no-backup.md']);
      final result = await service.restoreSession(
        session: session,
        vaultAbsolutePath: tempDir.path,
      );

      expect(result.restoredCount, 1);
      expect(result.missingBackupsCount, 1);
    });

    test('RestoreResult.summary is human-readable', () {
      const result = RestoreResult(
        restoredCount: 3,
        missingBackupsCount: 1,
        errorCount: 0,
      );
      expect(result.summary, contains('3 files restored'));
      expect(result.summary, contains('1 backup'));
    });

    test('RestoreResult.hasIssues is false when everything succeeded', () {
      const result = RestoreResult(
        restoredCount: 2,
        missingBackupsCount: 0,
        errorCount: 0,
      );
      expect(result.hasIssues, isFalse);
    });

    test('RestoreResult.hasIssues is true when backups were missing', () {
      const result = RestoreResult(
        restoredCount: 0,
        missingBackupsCount: 1,
        errorCount: 0,
      );
      expect(result.hasIssues, isTrue);
    });
  });
}
