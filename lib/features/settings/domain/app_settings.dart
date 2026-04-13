import 'package:vaultwash/features/settings/domain/app_appearance_mode.dart';

class AppSettings {
  const AppSettings({
    this.lastVaultPath,
    this.createBackupsBeforeWrite = true,
    this.excludeObsidian = true,
    this.excludeHiddenFolders = false,
    this.appearanceMode = AppAppearanceMode.system,
    this.enabledRuleIds = const {'oaicite_content_reference'},
  });

  final String? lastVaultPath;
  final bool createBackupsBeforeWrite;
  final bool excludeObsidian;
  final bool excludeHiddenFolders;
  final AppAppearanceMode appearanceMode;
  final Set<String> enabledRuleIds;

  AppSettings copyWith({
    String? lastVaultPath,
    bool clearLastVaultPath = false,
    bool? createBackupsBeforeWrite,
    bool? excludeObsidian,
    bool? excludeHiddenFolders,
    AppAppearanceMode? appearanceMode,
    Set<String>? enabledRuleIds,
  }) {
    return AppSettings(
      lastVaultPath: clearLastVaultPath
          ? null
          : (lastVaultPath ?? this.lastVaultPath),
      createBackupsBeforeWrite:
          createBackupsBeforeWrite ?? this.createBackupsBeforeWrite,
      excludeObsidian: excludeObsidian ?? this.excludeObsidian,
      excludeHiddenFolders: excludeHiddenFolders ?? this.excludeHiddenFolders,
      appearanceMode: appearanceMode ?? this.appearanceMode,
      enabledRuleIds: enabledRuleIds ?? this.enabledRuleIds,
    );
  }
}
