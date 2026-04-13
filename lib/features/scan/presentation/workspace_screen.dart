import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultwash/app/app_strings.dart';
import 'package:vaultwash/app/theme/app_tokens.dart';
import 'package:vaultwash/core/widgets/app_button.dart';
import 'package:vaultwash/core/widgets/app_surface_card.dart';
import 'package:vaultwash/core/widgets/empty_state_view.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_execution_result.dart';
import 'package:vaultwash/features/cleanup/presentation/preview_panel.dart';
import 'package:vaultwash/features/scan/application/scan_controller.dart';
import 'package:vaultwash/features/scan/domain/scan_failure.dart';
import 'package:vaultwash/features/scan/domain/scan_file_result.dart';
import 'package:vaultwash/features/scan/presentation/affected_files_list.dart';
import 'package:vaultwash/features/scan/presentation/scan_summary_card.dart';
import 'package:vaultwash/features/settings/application/app_settings_controller.dart';
import 'package:vaultwash/features/settings/presentation/settings_dialog.dart';
import 'package:vaultwash/features/vault/application/vault_controller.dart';
import 'package:vaultwash/features/vault/domain/vault_ref.dart';
import 'package:vaultwash/features/vault/presentation/vault_selector.dart';

class WorkspaceScreen extends ConsumerStatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  ConsumerState<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends ConsumerState<WorkspaceScreen> {
  @override
  Widget build(BuildContext context) {
    final vaultState = ref.watch(vaultControllerProvider);
    final scanState = ref.watch(scanControllerProvider);
    final settings = ref.watch(appSettingsControllerProvider);
    final workspace = scanState.asData?.value ?? const ScanWorkspaceState();
    final currentVault = vaultState.asData?.value;
    final isBusy = workspace.isScanning || workspace.isCleaning;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 1180;

            if (isCompact) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLeftRail(
                      context: context,
                      currentVault: currentVault,
                      workspace: workspace,
                      settingsSummary: settings.createBackupsBeforeWrite
                          ? 'Backups enabled'
                          : 'Backups disabled',
                      isBusy: isBusy,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 560,
                      child: _buildCenterPane(context, currentVault, workspace),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(height: 520, child: _buildPreviewPane(workspace)),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 288,
                    child: _buildLeftRail(
                      context: context,
                      currentVault: currentVault,
                      workspace: workspace,
                      settingsSummary: settings.createBackupsBeforeWrite
                          ? 'Backups enabled'
                          : 'Backups disabled',
                      isBusy: isBusy,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 11,
                    child: _buildCenterPane(context, currentVault, workspace),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(flex: 10, child: _buildPreviewPane(workspace)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLeftRail({
    required BuildContext context,
    required VaultRef? currentVault,
    required ScanWorkspaceState workspace,
    required String settingsSummary,
    required bool isBusy,
  }) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.appName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppStrings.sidebarSubtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            AppStrings.shortDescription,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          VaultSelector(
            vault: currentVault,
            isBusy: isBusy,
            onPickVault: _handlePickVault,
            onClearVault: _handleClearVault,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: workspace.isScanning ? 'Scanning…' : 'Scan vault',
            icon: Icons.search_rounded,
            onPressed: currentVault == null || isBusy ? null : _runScan,
          ),
          const SizedBox(height: AppSpacing.xs),
          AppButton(
            label: workspace.isCleaning ? 'Cleaning…' : 'Clean selected files',
            icon: Icons.cleaning_services_outlined,
            variant: AppButtonVariant.secondary,
            onPressed: isBusy || workspace.selectedPaths.isEmpty
                ? null
                : _handleCleanSelected,
          ),
          const SizedBox(height: AppSpacing.xs),
          AppButton(
            label: 'Clean all affected files',
            icon: Icons.done_all_rounded,
            variant: AppButtonVariant.secondary,
            onPressed: isBusy || workspace.affectedFiles.isEmpty
                ? null
                : _handleCleanAll,
          ),
          const SizedBox(height: AppSpacing.xs),
          AppButton(
            label: 'Settings',
            icon: Icons.tune_rounded,
            variant: AppButtonVariant.ghost,
            onPressed: _openSettings,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSurfaceCard(
            backgroundColor: AppColors.surfaceRaised,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  workspace.statusMessage ?? AppStrings.tagline,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (workspace.lastExecutionResult != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _executionSummary(workspace.lastExecutionResult!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Text(
                  settingsSummary,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterPane(
    BuildContext context,
    VaultRef? currentVault,
    ScanWorkspaceState workspace,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScanSummaryCard(
          summary: workspace.summary,
          statusMessage: workspace.statusMessage,
          errorMessage: workspace.errorMessage,
          lastScannedAt: workspace.lastScannedAt,
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: AppSurfaceCard(
            child: currentVault == null
                ? const EmptyStateView(
                    title: 'Select an Obsidian vault to begin',
                    message:
                        'Pick a vault in the left rail, scan markdown files recursively, and review every change before VaultWash writes anything.',
                    icon: Icons.folder_copy_outlined,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AffectedFilesList(
                          files: workspace.affectedFiles,
                          selectedPaths: workspace.selectedPaths,
                          focusedRelativePath: workspace.focusedRelativePath,
                          onFocusFile: ref
                              .read(scanControllerProvider.notifier)
                              .focusFile,
                          onToggleSelection: ref
                              .read(scanControllerProvider.notifier)
                              .toggleSelection,
                        ),
                      ),
                      if (workspace.failures.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        _FailureSection(failures: workspace.failures),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewPane(ScanWorkspaceState workspace) {
    return SizedBox(
      height: double.infinity,
      child: AppSurfaceCard(
        child: PreviewPanel(fileResult: workspace.focusedFile),
      ),
    );
  }

  Future<void> _handlePickVault() async {
    try {
      await ref.read(vaultControllerProvider.notifier).pickVault();
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _handleClearVault() async {
    await ref.read(vaultControllerProvider.notifier).clearVault();
  }

  Future<void> _runScan() async {
    await ref
        .read(scanControllerProvider.notifier)
        .scanVault(preserveExecutionResult: false);
  }

  Future<void> _handleCleanSelected() async {
    final files = ref.read(scanControllerProvider.notifier).selectedFiles();
    await _confirmAndClean(
      files: files,
      title: 'Clean selected files',
      description:
          'VaultWash will update only the files selected in the current review list.',
    );
  }

  Future<void> _handleCleanAll() async {
    final files = ref.read(scanControllerProvider.notifier).allAffectedFiles();
    await _confirmAndClean(
      files: files,
      title: 'Clean all affected files',
      description:
          'VaultWash will update every affected markdown file from the current scan.',
    );
  }

  Future<void> _confirmAndClean({
    required List<ScanFileResult> files,
    required String title,
    required String description,
  }) async {
    if (files.isEmpty) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  ref
                          .read(appSettingsControllerProvider)
                          .createBackupsBeforeWrite
                      ? 'Backup copies will be created beside each file before VaultWash writes changes.'
                      : 'Backup copies are currently disabled for this cleanup run.',
                  style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Files to change',
                  style: Theme.of(dialogContext).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 260),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: files.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, index) {
                        final file = files[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xs,
                          ),
                          child: Text(file.relativePath),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Review later'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Clean files'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final result = await ref
        .read(scanControllerProvider.notifier)
        .cleanFiles(files);
    if (result == null || !mounted) {
      return;
    }

    _showMessage(_executionSummary(result));
  }

  Future<void> _openSettings() async {
    await showDialog<void>(
      context: context,
      builder: (_) => const SettingsDialog(),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _executionSummary(CleanupExecutionResult result) {
    return '${result.successCount} files cleaned, ${result.skippedCount} skipped, ${result.failureCount} failed.';
  }
}

class _FailureSection extends StatelessWidget {
  const _FailureSection({required this.failures});

  final List<ScanFailure> failures;

  @override
  Widget build(BuildContext context) {
    final visibleFailures = failures.take(4).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: AppRadius.sm,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${failures.length} unreadable files',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.warning),
          ),
          const SizedBox(height: AppSpacing.xs),
          ...visibleFailures.map(
            (failure) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
              child: Text(
                '${failure.relativePath}: ${failure.message}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),
          if (failures.length > visibleFailures.length)
            Text(
              'Plus ${failures.length - visibleFailures.length} more unreadable files.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}
