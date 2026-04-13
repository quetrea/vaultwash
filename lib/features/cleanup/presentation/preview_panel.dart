import 'package:flutter/material.dart';
import 'package:vaultwash/app/theme/app_tokens.dart';
import 'package:vaultwash/core/widgets/app_section_header.dart';
import 'package:vaultwash/core/widgets/empty_state_view.dart';
import 'package:vaultwash/core/widgets/app_surface_card.dart';
import 'package:vaultwash/features/scan/domain/scan_file_result.dart';

class PreviewPanel extends StatelessWidget {
  const PreviewPanel({super.key, required this.fileResult});

  final ScanFileResult? fileResult;

  @override
  Widget build(BuildContext context) {
    if (fileResult == null) {
      return const EmptyStateView(
        title: 'Select a file to preview',
        message:
            'Choose a file from the results list to compare the original and cleaned excerpts.',
        icon: Icons.view_week_outlined,
      );
    }

    final textTheme = Theme.of(context).textTheme;
    final monoStyle = textTheme.bodySmall?.copyWith(
      fontFamily: 'monospace',
      color: AppColors.textPrimary,
      height: 1.5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Change preview',
          subtitle: fileResult!.relativePath,
          trailing: Chip(label: Text('${fileResult!.matchCount} artifacts')),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: ListView.separated(
            itemCount: fileResult!.preview.excerpts.isEmpty
                ? 1
                : fileResult!.preview.excerpts.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              if (fileResult!.preview.excerpts.isEmpty) {
                return AppSurfaceCard(
                  backgroundColor: AppColors.surfaceRaised,
                  child: Text(
                    'This file needs cleanup, but no excerpt slices are currently available. Run another scan to refresh the preview.',
                    style: textTheme.bodySmall,
                  ),
                );
              }

              final excerpt = fileResult!.preview.excerpts[index];
              return AppSurfaceCard(
                backgroundColor: AppColors.surfaceRaised,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Excerpt ${index + 1}',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _PreviewColumn(
                            label: 'Before',
                            value: excerpt.originalExcerpt,
                            textStyle: monoStyle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _PreviewColumn(
                            label: 'After',
                            value: excerpt.cleanedExcerpt,
                            textStyle: monoStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PreviewColumn extends StatelessWidget {
  const _PreviewColumn({
    required this.label,
    required this.value,
    required this.textStyle,
  });

  final String label;
  final String value;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.sm,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          SelectableText(value, style: textStyle),
        ],
      ),
    );
  }
}
