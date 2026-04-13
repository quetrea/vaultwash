import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vaultwash/app/app_strings.dart';
import 'package:vaultwash/features/onboarding/domain/onboarding_status.dart';

typedef OnboardingDirectoryResolver = Future<Directory> Function();

const _markerFileName = 'onboarding_seen.txt';

final onboardingDirectoryResolverProvider =
    Provider<OnboardingDirectoryResolver>(
      (ref) => OnboardingLocalDataSource.resolveStorageDirectory,
    );

final onboardingLocalDataSourceProvider = Provider<OnboardingLocalDataSource>(
  (ref) => OnboardingLocalDataSource(
    resolveDirectory: ref.watch(onboardingDirectoryResolverProvider),
  ),
);

class OnboardingLocalDataSource {
  OnboardingLocalDataSource({
    required OnboardingDirectoryResolver resolveDirectory,
  }) : _resolveDirectory = resolveDirectory;

  final OnboardingDirectoryResolver _resolveDirectory;

  static Future<Directory> resolveStorageDirectory() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      if (documentsDirectory.path.trim().isNotEmpty) {
        return Directory(
          p.join(documentsDirectory.path, AppStrings.appName, 'state'),
        );
      }
    } catch (_) {
      // Fall back to an application-owned directory below.
    }

    final supportDirectory = await getApplicationSupportDirectory();
    return Directory(p.join(supportDirectory.path, 'state'));
  }

  Future<OnboardingStatus> load() async {
    final markerFile = await _markerFile();
    if (!await markerFile.exists()) {
      return const OnboardingStatus.unseen();
    }

    final raw = await markerFile.readAsString();
    return _parse(raw);
  }

  Future<OnboardingStatus> markCompleted({
    int version = currentOnboardingVersion,
    DateTime? completedAt,
  }) async {
    final markerFile = await _markerFile();
    await markerFile.parent.create(recursive: true);

    final record = OnboardingStatus(
      isCompleted: true,
      version: version,
      completedAt: completedAt ?? DateTime.now(),
    );

    await markerFile.writeAsString(_serialize(record));
    return record;
  }

  Future<File> _markerFile() async {
    final directory = await _resolveDirectory();
    return File(p.join(directory.path, _markerFileName));
  }

  OnboardingStatus _parse(String raw) {
    final values = <String, String>{};

    for (final line in const LineSplitter().convert(raw)) {
      final separatorIndex = line.indexOf('=');
      if (separatorIndex <= 0) {
        continue;
      }

      final key = line.substring(0, separatorIndex).trim();
      final value = line.substring(separatorIndex + 1).trim();
      if (key.isEmpty) {
        continue;
      }

      values[key] = value;
    }

    return OnboardingStatus(
      isCompleted: values['seen']?.toLowerCase() == 'true',
      version: int.tryParse(values['version'] ?? '') ?? 0,
      completedAt: DateTime.tryParse(values['completed_at'] ?? ''),
    );
  }

  String _serialize(OnboardingStatus status) {
    final buffer = StringBuffer()
      ..writeln('seen=${status.isCompleted}')
      ..writeln('version=${status.version}')
      ..writeln('completed_at=${status.completedAt?.toIso8601String() ?? ''}');

    return buffer.toString();
  }
}
