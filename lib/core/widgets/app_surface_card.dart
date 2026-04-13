import 'package:flutter/material.dart';
import 'package:vaultwash/app/theme/app_tokens.dart';

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.backgroundColor,
    this.borderRadius,
    this.showShadow = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.surface,
        borderRadius: borderRadius ?? AppRadius.md,
        border: Border.all(color: colors.border),
        boxShadow: showShadow ? AppShadows.surface(colors) : null,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
