import 'package:flutter/material.dart';
import 'package:vaultwash/app/theme/app_tokens.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: AppRadius.sm,
        border: Border.all(color: colors.border),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
      ),
    );
  }
}
