import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultwash/app/theme/app_tokens.dart';
import 'package:vaultwash/core/widgets/app_section_header.dart';
import 'package:vaultwash/features/cleanup/application/cleanup_history_controller.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_session.dart';
import 'package:vaultwash/features/cleanup/infrastructure/restore_service.dart';
import 'package:vaultwash/features/vault/application/vault_controller.dart';

class CleanupHistoryDialog extends ConsumerWidget {
  const CleanupHistoryDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(cleanupHistoryControllerProvider);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: AppSectionHeader(
                      title: 'Cleanup history',
                      subtitle:
                          'Recent cleanup sessions recorded on this machine.',
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: historyAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (_, _) => const Center(
                    child: Text('Could not load cleanup history.'),
                  ),
                  data: (sessions) => sessions.isEmpty
                      ? _EmptyHistoryState()
                      : _SessionList(sessions: sessions),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyHistoryState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_rounded,
            size: 36,
            color: colors.textMuted,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No cleanup sessions yet',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Sessions are recorded here each time you run a cleanup.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Session list ───────────────────────────────────────────────────────────────

class _SessionList extends StatelessWidget {
  const _SessionList({required this.sessions});

  final List<CleanupSession> sessions;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: sessions.length,
      separatorBuilder: (_, _) => const Divider(height: AppSpacing.lg),
      itemBuilder: (context, index) =>
          _SessionTile(session: sessions[index]),
    );
  }
}

// ── Single session tile ────────────────────────────────────────────────────────

class _SessionTile extends ConsumerWidget {
  const _SessionTile({required this.session});

  final CleanupSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final timestamp = _formatTimestamp(session.timestamp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row ───────────────────────────────────────────────────
        Row(
          children: [
            Icon(Icons.history_rounded, size: 14, color: colors.textMuted),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                timestamp,
                style: textTheme.labelMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            Text(
              session.vaultName,
              style: textTheme.labelSmall?.copyWith(color: colors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // ── Stats row ────────────────────────────────────────────────────
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xxs,
          children: [
            _StatChip(
              label:
                  '${session.filesChanged} file${session.filesChanged == 1 ? '' : 's'} cleaned',
              color: colors.success,
              background: colors.successSoft,
              border: colors.border,
            ),
            if (session.filesSkipped > 0)
              _StatChip(
                label: '${session.filesSkipped} skipped',
                color: colors.textSecondary,
                background: colors.surfaceMuted,
                border: colors.border,
              ),
            if (session.filesFailed > 0)
              _StatChip(
                label: '${session.filesFailed} failed',
                color: colors.warning,
                background: colors.warningSoft,
                border: colors.border,
              ),
            if (session.backupsCreated)
              _StatChip(
                label: 'Backups created',
                color: colors.accent,
                background: colors.accentSoft,
                border: colors.border,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // ── Rules used ───────────────────────────────────────────────────
        if (session.ruleLabels.isNotEmpty)
          Text(
            'Rules: ${session.ruleLabels.join(' · ')}',
            style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: AppSpacing.sm),

        // ── Actions ──────────────────────────────────────────────────────
        Row(
          children: [
            TextButton.icon(
              onPressed: () => _copySummary(context, session),
              icon: const Icon(Icons.copy_rounded, size: 14),
              label: const Text('Copy summary'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            if (session.backupsCreated && session.changedRelativePaths.isNotEmpty)
              TextButton.icon(
                onPressed: () => _confirmRestore(context, ref, session),
                icon: const Icon(Icons.restore_rounded, size: 14),
                label: const Text('Restore'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _copySummary(BuildContext context, CleanupSession session) {
    Clipboard.setData(ClipboardData(text: session.toSummaryText()));
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(content: Text('Session summary copied to clipboard.')),
      );
  }

  Future<void> _confirmRestore(
    BuildContext context,
    WidgetRef ref,
    CleanupSession session,
  ) async {
    final vault = await ref.read(vaultControllerProvider.future);
    if (vault == null || !context.mounted) {
      return;
    }

    final restoreService = ref.read(restoreServiceProvider);
    final hasBackups = await restoreService.sessionHasBackups(
      session: session,
      vaultAbsolutePath: vault.absolutePath,
    );

    if (!context.mounted) {
      return;
    }

    if (!hasBackups) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('No .bak backup files were found for this session.'),
          ),
        );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _RestoreConfirmDialog(session: session),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final result = await restoreService.restoreSession(
      session: session,
      vaultAbsolutePath: vault.absolutePath,
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(result.summary)));
  }

  static String _formatTimestamp(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$y-$mo-$d at $h:$mi';
  }
}

// ── Stat chip ──────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.color,
    required this.background,
    required this.border,
  });

  final String label;
  final Color color;
  final Color background;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.sm,
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

// ── Restore confirmation dialog ────────────────────────────────────────────────

class _RestoreConfirmDialog extends StatelessWidget {
  const _RestoreConfirmDialog({required this.session});

  final CleanupSession session;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final files = session.changedRelativePaths;

    return AlertDialog(
      title: const Text('Restore from backup'),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VaultWash will restore ${files.length} file${files.length == 1 ? '' : 's'} '
              'from the .bak backups created during this session. '
              'The current file content will be replaced.',
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'This action cannot be undone.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Files to restore',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: files.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, index) => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      files[index],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Restore now'),
        ),
      ],
    );
  }
}
