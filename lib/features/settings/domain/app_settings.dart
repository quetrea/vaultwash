class AppSettings {
  const AppSettings({
    this.lastVaultPath,
    this.createBackupsBeforeWrite = true,
    this.excludeObsidian = true,
    this.excludeHiddenFolders = false,
    this.enabledRuleIds = const {'oaicite_content_reference'},
  });

  final String? lastVaultPath;
  final bool createBackupsBeforeWrite;
  final bool excludeObsidian;
  final bool excludeHiddenFolders;
  final Set<String> enabledRuleIds;

  AppSettings copyWith({
    String? lastVaultPath,
    bool clearLastVaultPath = false,
    bool? createBackupsBeforeWrite,
    bool? excludeObsidian,
    bool? excludeHiddenFolders,
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
      enabledRuleIds: enabledRuleIds ?? this.enabledRuleIds,
    );
  }
}
