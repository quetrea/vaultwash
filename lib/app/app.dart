import 'package:flutter/material.dart';
import 'package:vaultwash/app/app_strings.dart';
import 'package:vaultwash/app/router.dart';
import 'package:vaultwash/app/theme/app_theme.dart';

class VaultWashApp extends StatelessWidget {
  const VaultWashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.windowTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.workspace,
    );
  }
}
