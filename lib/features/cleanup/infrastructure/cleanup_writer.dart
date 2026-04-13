import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultwash/core/utils/file_hash.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_execution_result.dart';
import 'package:vaultwash/features/scan/domain/scan_file_result.dart';

final cleanupWriterProvider = Provider<CleanupWriter>(
  (ref) => const CleanupWriter(),
);

class CleanupWriter {
  const CleanupWriter();

  Future<CleanupExecutionResult> execute({
    required List<ScanFileResult> files,
    required bool createBackups,
  }) async {
    final results = <CleanupFileExecution>[];

    for (final fileResult in files) {
      final file = File(fileResult.absolutePath);

      try {
        final currentContent = await file.readAsString();
        final currentHash = hashContent(currentContent);

        if (currentHash != fileResult.originalContentHash) {
          results.add(
            CleanupFileExecution(
              absolutePath: fileResult.absolutePath,
              relativePath: fileResult.relativePath,
              status: CleanupFileStatus.skipped,
              message: 'Skipped because the file changed after the scan.',
            ),
          );
          continue;
        }

        var backupCreated = false;
        if (createBackups) {
          final backupFile = File('${file.path}.bak');
          await backupFile.writeAsString(currentContent);
          backupCreated = true;
        }

        await file.writeAsString(fileResult.cleanedPreviewContent);

        results.add(
          CleanupFileExecution(
            absolutePath: fileResult.absolutePath,
            relativePath: fileResult.relativePath,
            status: CleanupFileStatus.success,
            message: 'Cleaned successfully.',
            backupCreated: backupCreated,
          ),
        );
      } catch (error) {
        results.add(
          CleanupFileExecution(
            absolutePath: fileResult.absolutePath,
            relativePath: fileResult.relativePath,
            status: CleanupFileStatus.failure,
            message: error.toString(),
          ),
        );
      }
    }

    return CleanupExecutionResult(fileResults: results);
  }
}
