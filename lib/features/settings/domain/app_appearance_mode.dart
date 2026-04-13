enum AppAppearanceMode {
  system,
  light,
  dark;

  String get storageValue => switch (this) {
    AppAppearanceMode.system => 'system',
    AppAppearanceMode.light => 'light',
    AppAppearanceMode.dark => 'dark',
  };

  String get label => switch (this) {
    AppAppearanceMode.system => 'System',
    AppAppearanceMode.light => 'Light',
    AppAppearanceMode.dark => 'Dark',
  };

  static AppAppearanceMode fromStorageValue(String? value) {
    for (final mode in AppAppearanceMode.values) {
      if (mode.storageValue == value) {
        return mode;
      }
    }

    return AppAppearanceMode.system;
  }
}
