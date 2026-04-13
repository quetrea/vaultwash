import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:vaultwash/features/cleanup/application/cleanup_engine.dart';
import 'package:vaultwash/features/scan/domain/scan_failure.dart';
import 'package:vaultwash/features/scan/domain/scan_file_result.dart';
import 'package:vaultwash/features/scan/domain/scan_request.dart';
import 'package:vaultwash/features/scan/domain/scan_result.dart';
import 'package:vaultwash/features/scan/domain/scan_summary.dart';

final vaultScannerProvider = Provider<VaultScanner>(
  (ref) => VaultScanner(ref.watch(cleanupEngineProvider)),
);

class VaultScanner {
  const VaultScanner(this._cleanupEngine);

  final CleanupEngine _cleanupEngine;

  Future<ScanResult> scan(ScanRequest request) async {
    final affectedFiles = <ScanFileResult>[];
    final failures = <ScanFailure>[];
    var totalFilesScanned = 0;
    var totalMatchesFound = 0;

    Future<void> visitDirectory(Directory directory) async {
      try {
        await for (final entity in directory.list(followLinks: false)) {
          if (entity is Directory) {
            if (_shouldSkipDirectory(
              entity.path,
              excludeObsidian: request.excludeObsidian,
              excludeHiddenFolders: request.excludeHiddenFolders,
              excludedFolderNames: request.excludedFolderNames,
            )) {
              continue;
            }

            await visitDirectory(entity);
            continue;
          }

          if (entity is! File ||
              p.extension(entity.path).toLowerCase() != '.md') {
            continue;
          }

          totalFilesScanned += 1;
          final relativePath = p.relative(
            entity.path,
            from: request.vault.absolutePath,
          );

          try {
            final originalContent = await entity.readAsString();
            final preview = _cleanupEngine.generatePreview(
              originalContent,
              request.enabledRules,
            );

            if (preview.hasChanges) {
              affectedFiles.add(
                ScanFileResult(
                  absolutePath: entity.path,
                  relativePath: relativePath,
                  matchCount: preview.matchCount,
                  matchedSnippets: preview.matchedSnippets,
                  cleanedPreviewContent: preview.cleanedContent,
                  originalContentHash: preview.originalContentHash,
                  preview: preview,
                ),
              );
              totalMatchesFound += preview.matchCount;
            }
          } catch (error) {
            failures.add(
              ScanFailure(
                absolutePath: entity.path,
                relativePath: relativePath,
                message: error.toString(),
              ),
            );
          }

          if (totalFilesScanned % 25 == 0) {
            await Future<void>.delayed(Duration.zero);
          }
        }
      } catch (error) {
        failures.add(
          ScanFailure(
            absolutePath: directory.path,
            relativePath: p.relative(
              directory.path,
              from: request.vault.absolutePath,
            ),
            message: error.toString(),
          ),
        );
      }
    }

    await visitDirectory(Directory(request.vault.absolutePath));

    affectedFiles.sort(
      (left, right) => left.relativePath.compareTo(right.relativePath),
    );
    failures.sort(
      (left, right) => left.relativePath.compareTo(right.relativePath),
    );

    return ScanResult(
      summary: ScanSummary(
        totalFilesScanned: totalFilesScanned,
        filesWithMatches: affectedFiles.length,
        totalMatchesFound: totalMatchesFound,
        failureCount: failures.length,
      ),
      affectedFiles: affectedFiles,
      failures: failures,
    );
  }

  bool _shouldSkipDirectory(
    String path, {
    required bool excludeObsidian,
    required bool excludeHiddenFolders,
    required List<String> excludedFolderNames,
  }) {
    final name = p.basename(path);

    if (name == '.trash') {
      return true;
    }

    if (excludeObsidian && name == '.obsidian') {
      return true;
    }

    if (excludeHiddenFolders && name.startsWith('.')) {
      return true;
    }

    if (excludedFolderNames.contains(name)) {
      return true;
    }

    return false;
  }
}
