import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_preset.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_rule.dart';
import 'package:vaultwash/features/settings/domain/app_appearance_mode.dart';
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

  Future<void> setAppearanceMode(AppAppearanceMode mode) async {
    await _persist(state.copyWith(appearanceMode: mode));
  }

  Future<void> setRuleEnabled(String ruleId, bool enabled) async {
    final nextRuleIds = {...state.enabledRuleIds};

    if (enabled) {
      nextRuleIds.add(ruleId);
    } else {
      nextRuleIds.remove(ruleId);
    }

    // Toggling individual rules breaks preset alignment — clear activePreset.
    await _persist(
      state.copyWith(enabledRuleIds: nextRuleIds, clearActivePreset: true),
    );
  }

  /// Applies [preset], updating [enabledRuleIds] and recording [activePreset].
  /// [allRules] is the full rule registry needed to resolve preset membership.
  Future<void> applyPreset(
    CleanupPreset preset,
    List<CleanupRule> allRules,
  ) async {
    final ruleIds = preset.ruleIds(allRules);
    await _persist(state.copyWith(enabledRuleIds: ruleIds, activePreset: preset));
  }

  Future<void> addExcludedFolderName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || state.excludedFolderNames.contains(trimmed)) {
      return;
    }
    final next = [...state.excludedFolderNames, trimmed];
    await _persist(state.copyWith(excludedFolderNames: next));
  }

  Future<void> removeExcludedFolderName(String name) async {
    final next = state.excludedFolderNames.where((n) => n != name).toList();
    await _persist(state.copyWith(excludedFolderNames: next));
  }
}
