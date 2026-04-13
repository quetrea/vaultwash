import 'package:flutter/material.dart';
import 'package:vaultwash/app/theme/app_tokens.dart';
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
    final textTheme = Theme.of(context).textTheme;

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: 'Current scan',
            subtitle: lastScannedAt == null
                ? 'No scan has been run yet.'
                : 'Last scanned at ${_formatTime(lastScannedAt!)}',
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _SummaryMetric(
                label: 'Markdown scanned',
                value: '${summary?.totalFilesScanned ?? 0}',
              ),
              _SummaryMetric(
                label: 'Files to review',
                value: '${summary?.filesWithMatches ?? 0}',
              ),
              _SummaryMetric(
                label: 'Artifacts found',
                value: '${summary?.totalMatchesFound ?? 0}',
              ),
              _SummaryMetric(
                label: 'Read failures',
                value: '${summary?.failureCount ?? 0}',
              ),
            ],
          ),
          if (statusMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              statusMessage!,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (errorMessage != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              errorMessage!,
              style: textTheme.bodySmall?.copyWith(color: AppColors.danger),
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
    return Container(
      width: 150,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: AppRadius.sm,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xxs),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
