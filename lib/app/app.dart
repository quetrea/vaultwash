import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultwash/app/app_strings.dart';
import 'package:vaultwash/app/router.dart';
import 'package:vaultwash/app/theme/app_theme.dart';
import 'package:vaultwash/app/theme/app_tokens.dart';
import 'package:vaultwash/features/settings/application/app_settings_controller.dart';
import 'package:vaultwash/features/settings/domain/app_appearance_mode.dart';

class VaultWashApp extends ConsumerWidget {
  const VaultWashApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearanceMode = ref.watch(
      appSettingsControllerProvider.select((s) => s.appearanceMode),
    );

    return MaterialApp(
      title: AppStrings.windowTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: switch (appearanceMode) {
        AppAppearanceMode.system => ThemeMode.system,
        AppAppearanceMode.light => ThemeMode.light,
        AppAppearanceMode.dark => ThemeMode.dark,
      },
      themeAnimationDuration: AppDurations.standard,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.workspace,
    );
  }
}
