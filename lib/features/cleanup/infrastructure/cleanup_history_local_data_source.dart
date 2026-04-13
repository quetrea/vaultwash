import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vaultwash/app/app_strings.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_session.dart';

const _historyFileName = 'cleanup_history.json';
const _maxSessions = 50;

typedef HistoryDirectoryResolver = Future<Directory> Function();

final cleanupHistoryLocalDataSourceProvider =
    Provider<CleanupHistoryLocalDataSource>(
      (ref) => CleanupHistoryLocalDataSource(
        resolveDirectory: CleanupHistoryLocalDataSource.resolveStorageDirectory,
      ),
    );

class CleanupHistoryLocalDataSource {
  CleanupHistoryLocalDataSource({
    required HistoryDirectoryResolver resolveDirectory,
  }) : _resolveDirectory = resolveDirectory;

  final HistoryDirectoryResolver _resolveDirectory;

  static Future<Directory> resolveStorageDirectory() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      if (documentsDirectory.path.trim().isNotEmpty) {
        final preferred = Directory(
          p.join(documentsDirectory.path, AppStrings.appName, 'state'),
        );
        await preferred.create(recursive: true);
        return preferred;
      }
    } on Exception {
      // Fall through to application support directory.
    }

    final supportDirectory = await getApplicationSupportDirectory();
    final fallback = Directory(p.join(supportDirectory.path, 'state'));
    await fallback.create(recursive: true);
    return fallback;
  }

  Future<List<CleanupSession>> load() async {
    try {
      final file = await _historyFile();
      if (!await file.exists()) {
        return [];
      }
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return [];
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(CleanupSession.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> append(CleanupSession session) async {
    final sessions = await load();
    sessions.insert(0, session);
    final trimmed = sessions.take(_maxSessions).toList();
    final file = await _historyFile();
    await file.writeAsString(
      const JsonEncoder.withIndent('  ')
          .convert(trimmed.map((s) => s.toJson()).toList()),
    );
  }

  Future<File> _historyFile() async {
    final directory = await _resolveDirectory();
    return File(p.join(directory.path, _historyFileName));
  }
}
