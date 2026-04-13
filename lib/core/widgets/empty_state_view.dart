import 'package:flutter/material.dart';
import 'package:vaultwash/app/theme/app_tokens.dart';
import 'package:vaultwash/core/widgets/app_surface_card.dart';

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.description_outlined,
    this.eyebrow,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: AppSurfaceCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          backgroundColor: colors.surfaceRaised,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: AppRadius.md,
                  border: Border.all(color: colors.border),
                ),
                child: Icon(icon, size: 22, color: colors.textSecondary),
              ),
              if (eyebrow case final value?) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  value,
                  style: textTheme.labelLarge?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
