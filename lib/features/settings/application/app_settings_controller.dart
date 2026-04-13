import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultwash/features/settings/domain/app_settings.dart';
import 'package:vaultwash/features/settings/infrastructure/settings_local_data_source.dart';

final appSettingsControllerProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );

class AppSettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return ref.watch(appSettingsLocalDataSourceProvider).load();
  }

  Future<void> _persist(AppSettings next) async {
    state = next;
    await ref.read(appSettingsLocalDataSourceProvider).save(next);
  }

  Future<void> setLastVaultPath(String path) async {
    await _persist(state.copyWith(lastVaultPath: path));
  }

  Future<void> clearLastVaultPath() async {
    await _persist(state.copyWith(clearLastVaultPath: true));
  }

  Future<void> setCreateBackupsBeforeWrite(bool enabled) async {
    await _persist(state.copyWith(createBackupsBeforeWrite: enabled));
  }

  Future<void> setExcludeObsidian(bool enabled) async {
    await _persist(state.copyWith(excludeObsidian: enabled));
  }

  Future<void> setExcludeHiddenFolders(bool enabled) async {
    await _persist(state.copyWith(excludeHiddenFolders: enabled));
  }

  Future<void> setRuleEnabled(String ruleId, bool enabled) async {
    final nextRuleIds = {...state.enabledRuleIds};

    if (enabled) {
      nextRuleIds.add(ruleId);
    } else {
      nextRuleIds.remove(ruleId);
    }

    await _persist(state.copyWith(enabledRuleIds: nextRuleIds));
  }
}
