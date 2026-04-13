import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:vaultwash/features/cleanup/domain/cleanup_session.dart';

final restoreServiceProvider = Provider<RestoreService>(
  (ref) => const RestoreService(),
);

class RestoreResult {
  const RestoreResult({
    required this.restoredCount,
    required this.missingBackupsCount,
    required this.errorCount,
  });

  final int restoredCount;
  final int missingBackupsCount;
  final int errorCount;

  bool get hasIssues => missingBackupsCount > 0 || errorCount > 0;

  String get summary {
    final parts = <String>[
      '$restoredCount file${restoredCount == 1 ? '' : 's'} restored',
      if (missingBackupsCount > 0)
        '$missingBackupsCount backup${missingBackupsCount == 1 ? '' : 's'} not found',
      if (errorCount > 0)
        '$errorCount error${errorCount == 1 ? '' : 's'}',
    ];
    return '${parts.join(', ')}.';
  }
}

class RestoreService {
  const RestoreService();

  /// Checks whether at least one .bak file exists for [session] files.
  Future<bool> sessionHasBackups({
    required CleanupSession session,
    required String vaultAbsolutePath,
  }) async {
    for (final relativePath in session.changedRelativePaths) {
      final backupFile = File(
        '${p.join(vaultAbsolutePath, relativePath)}.bak',
      );
      if (await backupFile.exists()) {
        return true;
      }
    }
    return false;
  }

  /// Restores files from .bak backups for [session].
  ///
  /// For each changed file: reads the .bak, overwrites the current file,
  /// then deletes the .bak. Files without a .bak are counted as missing.
  Future<RestoreResult> restoreSession({
    required CleanupSession session,
    required String vaultAbsolutePath,
  }) async {
    var restoredCount = 0;
    var missingBackupsCount = 0;
    var errorCount = 0;

    for (final relativePath in session.changedRelativePaths) {
      final absolutePath = p.join(vaultAbsolutePath, relativePath);
      final originalFile = File(absolutePath);
      final backupFile = File('$absolutePath.bak');

      try {
        if (!await backupFile.exists()) {
          missingBackupsCount += 1;
          continue;
        }

        final backupContent = await backupFile.readAsString();
        await originalFile.writeAsString(backupContent);
        await backupFile.delete();
        restoredCount += 1;
      } catch (_) {
        errorCount += 1;
      }
    }

    return RestoreResult(
      restoredCount: restoredCount,
      missingBackupsCount: missingBackupsCount,
      errorCount: errorCount,
    );
  }
}
