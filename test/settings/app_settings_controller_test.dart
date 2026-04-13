import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaultwash/features/settings/application/app_settings_controller.dart';
import 'package:vaultwash/features/settings/infrastructure/settings_local_data_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'loads persisted settings and writes updates back to preferences',
    () async {
      SharedPreferences.setMockInitialValues({
        'settings.last_vault_path': '/tmp/vault',
        'settings.create_backups': false,
        'settings.exclude_obsidian': true,
        'settings.exclude_hidden_folders': false,
        'settings.enabled_rule_ids': <String>['oaicite_content_reference'],
      });

      final preferences = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      );
      addTearDown(container.dispose);

      final initial = container.read(appSettingsControllerProvider);
      expect(initial.lastVaultPath, '/tmp/vault');
      expect(initial.createBackupsBeforeWrite, isFalse);
      expect(initial.excludeObsidian, isTrue);
      expect(initial.excludeHiddenFolders, isFalse);

      await container
          .read(appSettingsControllerProvider.notifier)
          .setExcludeHiddenFolders(true);
      await container
          .read(appSettingsControllerProvider.notifier)
          .setCreateBackupsBeforeWrite(true);

      expect(preferences.getBool('settings.exclude_hidden_folders'), isTrue);
      expect(preferences.getBool('settings.create_backups'), isTrue);
    },
  );
}
