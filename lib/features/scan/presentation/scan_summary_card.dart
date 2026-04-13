import 'package:flutter/material.dart';
import 'package:vaultwash/app/theme/app_tokens.dart';
import 'package:vaultwash/core/widgets/app_badge.dart';
import 'package:vaultwash/core/widgets/app_section_header.dart';
import 'package:vaultwash/core/widgets/app_surface_card.dart';
import 'package:vaultwash/features/scan/domain/scan_summary.dart';

class ScanSummaryCard extends StatelessWidget {
  const ScanSummaryCard({
    super.key,
    required this.summary,
    required this.statusMessage,
    required this.errorMessage,
    required this.lastScannedAt,
  });

  final ScanSummary? summary;
  final String? statusMessage;
  final String? errorMessage;
  final DateTime? lastScannedAt;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final effectiveSummary = summary;
    final filesScanned = effectiveSummary?.totalFilesScanned ?? 0;
    final affectedFiles = effectiveSummary?.filesWithMatches ?? 0;
    final totalMatches = effectiveSummary?.totalMatchesFound ?? 0;
    final failures = effectiveSummary?.failureCount ?? 0;

    return AppSurfaceCard(
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: 'Scan summary',
            subtitle: lastScannedAt == null
                ? 'Run a scan to inspect markdown files and review changes before cleanup.'
                : 'Last scanned at ${_formatTime(lastScannedAt!)}',
            trailing: AppBadge(
              label: lastScannedAt == null
                  ? 'Awaiting scan'
                  : '$affectedFiles affected',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: AppRadius.sm,
              border: Border.all(color: colors.border),
            ),
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                _SummaryMetric(label: 'Markdown files', value: '$filesScanned'),
                _SummaryMetric(
                  label: 'Affected files',
                  value: '$affectedFiles',
                ),
                _SummaryMetric(
                  label: 'Artifacts found',
                  value: '$totalMatches',
                ),
                _SummaryMetric(label: 'Unreadable files', value: '$failures'),
              ],
            ),
          ),
          if (statusMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              statusMessage!,
              style: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
            ),
          ],
          if (errorMessage != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              errorMessage!,
              style: textTheme.bodySmall?.copyWith(color: colors.danger),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
