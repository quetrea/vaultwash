import 'package:flutter/material.dart';
import 'package:vaultwash/app/theme/app_tokens.dart';
import 'package:vaultwash/core/widgets/app_section_header.dart';
import 'package:vaultwash/core/widgets/app_surface_card.dart';
import 'package:vaultwash/core/widgets/empty_state_view.dart';
import 'package:vaultwash/features/scan/domain/scan_file_result.dart';

class PreviewPanel extends StatelessWidget {
  const PreviewPanel({super.key, required this.fileResult});

  final ScanFileResult? fileResult;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final monoStyle = textTheme.bodySmall?.copyWith(
      fontFamily: 'monospace',
      color: colors.textPrimary,
      height: 1.5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Preview',
          subtitle: 'Inspect original and cleaned excerpts before writing.',
        ),
        const SizedBox(height: AppSpacing.md),
        if (fileResult == null)
          const Expanded(
            child: EmptyStateView(
              eyebrow: 'Preview',
              title: 'Select a file to inspect',
              message:
                  'Choose an affected file to compare the original excerpt with VaultWash’s cleaned preview.',
              icon: Icons.pageview_outlined,
            ),
          )
        else ...[
          _PreviewMetaCard(fileResult: fileResult!),
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
                    backgroundColor: colors.surfaceMuted,
                    child: Text(
                      'This file needs cleanup, but no excerpt slices are currently available. Run another scan to refresh the preview.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  );
                }

                final excerpt = fileResult!.preview.excerpts[index];
                return AppSurfaceCard(
                  backgroundColor: colors.surfaceRaised,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Excerpt ${index + 1}',
                        style: textTheme.labelLarge?.copyWith(
                          color: colors.textSecondary,
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
                              backgroundColor: colors.surfaceSunken,
                              textStyle: monoStyle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _PreviewColumn(
                              label: 'After',
                              value: excerpt.cleanedExcerpt,
                              backgroundColor: colors.accentSoft,
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
      ],
    );
  }
}

class _PreviewMetaCard extends StatelessWidget {
  const _PreviewMetaCard({required this.fileResult});

  final ScanFileResult fileResult;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      backgroundColor: colors.surfaceMuted,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Tooltip(
                  message: fileResult.relativePath,
                  waitDuration: const Duration(milliseconds: 400),
                  child: Text(
                    fileResult.relativePath,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Original hash ${_shortHash(fileResult.originalContentHash)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              borderRadius: AppRadius.sm,
              border: Border.all(color: colors.border),
            ),
            child: Text(
              '${fileResult.matchCount} artifact${fileResult.matchCount == 1 ? '' : 's'}',
              style: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  String _shortHash(String value) {
    if (value.length <= 8) {
      return value;
    }

    return value.substring(0, 8);
  }
}

class _PreviewColumn extends StatelessWidget {
  const _PreviewColumn({
    required this.label,
    required this.value,
    required this.backgroundColor,
    required this.textStyle,
  });

  final String label;
  final String value;
  final Color backgroundColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.sm,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          SelectableText(value, style: textStyle),
        ],
      ),
    );
  }
}
