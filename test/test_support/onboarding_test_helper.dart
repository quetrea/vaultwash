import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:vaultwash/features/onboarding/infrastructure/onboarding_local_data_source.dart';

Future<Directory> createOnboardingStateDirectory({required bool seen}) async {
  final directory = await Directory.systemTemp.createTemp(
    'vaultwash-onboarding',
  );

  if (seen) {
    final markerFile = File(p.join(directory.path, 'onboarding_seen.txt'));
    await markerFile.parent.create(recursive: true);
    await markerFile.writeAsString(
      'seen=true\nversion=1\ncompleted_at=2026-04-13T12:00:00.000Z\n',
    );
  }

  return directory;
}

onboardingDirectoryOverride(Directory directory) {
  return onboardingDirectoryResolverProvider.overrideWithValue(
    () async => directory,
  );
}
