import 'package:vaultwash/features/cleanup/domain/cleanup_preset.dart';
import 'package:vaultwash/features/settings/domain/app_appearance_mode.dart';

class AppSettings {
  const AppSettings({
    this.lastVaultPath,
    this.createBackupsBeforeWrite = true,
    this.excludeObsidian = true,
    this.excludeHiddenFolders = false,
    this.appearanceMode = AppAppearanceMode.system,
    this.enabledRuleIds = const {
      'oaicite_content_reference',
      'oaicite_standalone',
    },
    this.excludedFolderNames = const [],
    this.activePreset,
  });

  final String? lastVaultPath;
  final bool createBackupsBeforeWrite;
  final bool excludeObsidian;
  final bool excludeHiddenFolders;
  final AppAppearanceMode appearanceMode;
  final Set<String> enabledRuleIds;

  /// Exact folder basenames excluded from scanning (e.g. 'archive', 'old').
  final List<String> excludedFolderNames;

  /// The last preset applied, or null if rules have been customised manually.
  final CleanupPreset? activePreset;

  AppSettings copyWith({
    String? lastVaultPath,
    bool clearLastVaultPath = false,
    bool? createBackupsBeforeWrite,
    bool? excludeObsidian,
    bool? excludeHiddenFolders,
    AppAppearanceMode? appearanceMode,
    Set<String>? enabledRuleIds,
    List<String>? excludedFolderNames,
    CleanupPreset? activePreset,
    bool clearActivePreset = false,
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
      excludedFolderNames: excludedFolderNames ?? this.excludedFolderNames,
      activePreset:
          clearActivePreset ? null : (activePreset ?? this.activePreset),
    );
  }
}
