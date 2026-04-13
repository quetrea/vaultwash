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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight =
            constraints.hasBoundedHeight && constraints.maxHeight < 240;
        final padding = isTight ? AppSpacing.sm : AppSpacing.lg;
        final iconBoxSize = isTight ? 32.0 : 52.0;
        final iconSize = isTight ? 16.0 : 22.0;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AppSurfaceCard(
              padding: EdgeInsets.all(padding),
              backgroundColor: colors.surfaceRaised,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: iconBoxSize,
                    height: iconBoxSize,
                    decoration: BoxDecoration(
                      color: colors.surfaceMuted,
                      borderRadius: AppRadius.md,
                      border: Border.all(color: colors.border),
                    ),
                    child: Icon(
                      icon,
                      size: iconSize,
                      color: colors.textSecondary,
                    ),
                  ),
                  if (!isTight && eyebrow != null) ...[
                    SizedBox(height: isTight ? AppSpacing.xs : AppSpacing.md),
                    Text(
                      eyebrow!,
                      style: textTheme.labelLarge?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                  SizedBox(height: isTight ? AppSpacing.xs : AppSpacing.sm),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: isTight
                        ? textTheme.titleMedium
                        : textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    message,
                    maxLines: isTight ? 2 : null,
                    overflow: isTight ? TextOverflow.ellipsis : null,
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
      },
    );
  }
}
