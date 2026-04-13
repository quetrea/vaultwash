import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaultwash/features/settings/domain/app_appearance_mode.dart';
import 'package:vaultwash/features/settings/domain/app_settings.dart';

const _lastVaultPathKey = 'settings.last_vault_path';
const _createBackupsKey = 'settings.create_backups';
const _excludeObsidianKey = 'settings.exclude_obsidian';
const _excludeHiddenFoldersKey = 'settings.exclude_hidden_folders';
const _appearanceModeKey = 'settings.appearance_mode';
const _enabledRuleIdsKey = 'settings.enabled_rule_ids';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) =>
      throw UnimplementedError('sharedPreferencesProvider must be overridden.'),
);

final appSettingsLocalDataSourceProvider = Provider<AppSettingsLocalDataSource>(
  (ref) => AppSettingsLocalDataSource(ref.watch(sharedPreferencesProvider)),
);

class AppSettingsLocalDataSource {
  AppSettingsLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  AppSettings load() {
    final enabledRuleIds =
        _preferences.getStringList(_enabledRuleIdsKey)?.toSet() ??
        const {'oaicite_content_reference'};

    return AppSettings(
      lastVaultPath: _preferences.getString(_lastVaultPathKey),
      createBackupsBeforeWrite: _preferences.getBool(_createBackupsKey) ?? true,
      excludeObsidian: _preferences.getBool(_excludeObsidianKey) ?? true,
      excludeHiddenFolders:
          _preferences.getBool(_excludeHiddenFoldersKey) ?? false,
      appearanceMode: AppAppearanceMode.fromStorageValue(
        _preferences.getString(_appearanceModeKey),
      ),
      enabledRuleIds: enabledRuleIds,
    );
  }

  Future<void> save(AppSettings settings) async {
    if (settings.lastVaultPath == null || settings.lastVaultPath!.isEmpty) {
      await _preferences.remove(_lastVaultPathKey);
    } else {
      await _preferences.setString(_lastVaultPathKey, settings.lastVaultPath!);
    }

    await _preferences.setBool(
      _createBackupsKey,
      settings.createBackupsBeforeWrite,
    );
    await _preferences.setBool(_excludeObsidianKey, settings.excludeObsidian);
    await _preferences.setBool(
      _excludeHiddenFoldersKey,
      settings.excludeHiddenFolders,
    );
    await _preferences.setString(
      _appearanceModeKey,
      settings.appearanceMode.storageValue,
    );
    await _preferences.setStringList(
      _enabledRuleIdsKey,
      settings.enabledRuleIds.toList()..sort(),
    );
  }
}
