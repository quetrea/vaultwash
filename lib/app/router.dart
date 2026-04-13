import 'package:flutter/material.dart';
import 'package:vaultwash/features/scan/presentation/workspace_screen.dart';

abstract final class AppRouter {
  static const workspace = '/';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case workspace:
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const WorkspaceScreen(),
          settings: settings,
        );
    }
  }
}
