import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:vaultwash/features/onboarding/infrastructure/onboarding_local_data_source.dart';

void main() {
  test('writes and reads the onboarding marker file', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'vaultwash-onboarding-store',
    );
    addTearDown(() => tempDirectory.delete(recursive: true));

    final dataSource = OnboardingLocalDataSource(
      resolveDirectory: () async => tempDirectory,
    );

    final initial = await dataSource.load();
    expect(initial.shouldShow, isTrue);

    final completed = await dataSource.markCompleted(
      completedAt: DateTime.parse('2026-04-13T10:15:00.000Z'),
    );
    expect(completed.isCompleted, isTrue);
    expect(completed.version, 1);

    final markerFile = File(p.join(tempDirectory.path, 'onboarding_seen.txt'));
    expect(await markerFile.exists(), isTrue);

    final raw = await markerFile.readAsString();
    expect(raw, contains('seen=true'));
    expect(raw, contains('version=1'));
    expect(raw, contains('completed_at=2026-04-13T10:15:00.000Z'));

    final reloaded = await dataSource.load();
    expect(reloaded.isCompleted, isTrue);
    expect(reloaded.shouldShow, isFalse);
  });
}
