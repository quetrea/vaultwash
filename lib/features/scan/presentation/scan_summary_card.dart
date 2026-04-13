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
    this.collapsed = false,
    this.onToggleCollapsed,
  });

  final ScanSummary? summary;
  final String? statusMessage;
  final String? errorMessage;
  final DateTime? lastScannedAt;
  final bool collapsed;
  final VoidCallback? onToggleCollapsed;

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
      key: const ValueKey('scan-summary-card'),
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: 'Scan summary',
            subtitle: lastScannedAt == null
                ? 'Run a scan to inspect markdown files and review changes before cleanup.'
                : 'Last scanned at ${_formatTime(lastScannedAt!)}',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBadge(
                  label: lastScannedAt == null
                      ? 'Awaiting scan'
                      : '$affectedFiles affected',
                ),
                if (onToggleCollapsed != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  IconButton(
                    key: const ValueKey('workspace-summary-toggle'),
                    tooltip: collapsed ? 'Expand summary' : 'Collapse summary',
                    visualDensity: VisualDensity.compact,
                    iconSize: 18,
                    onPressed: onToggleCollapsed,
                    icon: Icon(
                      collapsed
                          ? Icons.unfold_more_rounded
                          : Icons.unfold_less_rounded,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRect(
            child: collapsed
                ? _CollapsedSummaryBody(
                    key: const ValueKey('scan-summary-collapsed-content'),
                    filesScanned: filesScanned,
                    affectedFiles: affectedFiles,
                    totalMatches: totalMatches,
                    failures: failures,
                    statusMessage: statusMessage,
                    errorMessage: errorMessage,
                  )
                : _ExpandedSummaryBody(
                    key: const ValueKey('scan-summary-expanded-content'),
                    filesScanned: filesScanned,
                    affectedFiles: affectedFiles,
                    totalMatches: totalMatches,
                    failures: failures,
                    statusMessage: statusMessage,
                    errorMessage: errorMessage,
                    colors: colors,
                    textTheme: textTheme,
                  ),
          ),
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

class _ExpandedSummaryBody extends StatelessWidget {
  const _ExpandedSummaryBody({
    super.key,
    required this.filesScanned,
    required this.affectedFiles,
    required this.totalMatches,
    required this.failures,
    required this.statusMessage,
    required this.errorMessage,
    required this.colors,
    required this.textTheme,
  });

  final int filesScanned;
  final int affectedFiles;
  final int totalMatches;
  final int failures;
  final String? statusMessage;
  final String? errorMessage;
  final AppColors colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              _SummaryMetric(label: 'Affected files', value: '$affectedFiles'),
              _SummaryMetric(label: 'Artifacts found', value: '$totalMatches'),
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
    );
  }
}

class _CollapsedSummaryBody extends StatelessWidget {
  const _CollapsedSummaryBody({
    super.key,
    required this.filesScanned,
    required this.affectedFiles,
    required this.totalMatches,
    required this.failures,
    required this.statusMessage,
    required this.errorMessage,
  });

  final int filesScanned;
  final int affectedFiles;
  final int totalMatches;
  final int failures;
  final String? statusMessage;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: colors.surfaceMuted,
            borderRadius: AppRadius.sm,
            border: Border.all(color: colors.border),
          ),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _CompactMetricChip(label: '$filesScanned scanned'),
              _CompactMetricChip(label: '$affectedFiles affected'),
              _CompactMetricChip(label: '$totalMatches artifacts'),
              _CompactMetricChip(label: '$failures unreadable'),
            ],
          ),
        ),
        if (statusMessage != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            statusMessage!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
    );
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

class _CompactMetricChip extends StatelessWidget {
  const _CompactMetricChip({required this.label});

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
        color: colors.surfaceRaised,
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
