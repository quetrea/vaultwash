import 'package:flutter/material.dart';
import 'package:vaultwash/app/theme/app_tokens.dart';
import 'package:vaultwash/core/widgets/app_button.dart';
import 'package:vaultwash/core/widgets/app_section_header.dart';
import 'package:vaultwash/features/vault/domain/vault_ref.dart';

class VaultSelector extends StatelessWidget {
  const VaultSelector({
    super.key,
    required this.vault,
    required this.isBusy,
    required this.onPickVault,
    required this.onClearVault,
    this.compact = false,
  });

  final VaultRef? vault;
  final bool isBusy;
  final VoidCallback onPickVault;
  final VoidCallback onClearVault;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Vault',
          subtitle: compact
              ? null
              : 'Choose the Obsidian vault you want VaultWash to inspect.',
        ),
        const SizedBox(height: AppSpacing.sm),
        Tooltip(
          message: vault?.absolutePath ?? 'No vault selected yet',
          waitDuration: const Duration(milliseconds: 400),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(compact ? AppSpacing.xs : AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              borderRadius: AppRadius.sm,
              border: Border.all(color: colors.border),
            ),
            child: vault == null
                ? Row(
                    children: [
                      _VaultIcon(
                        colors: colors,
                        icon: Icons.folder_outlined,
                        size: compact ? 32 : 36,
                        iconSize: compact ? 16 : 18,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'No vault selected yet',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _VaultIcon(
                            colors: colors,
                            icon: Icons.folder_open_rounded,
                            size: compact ? 32 : 36,
                            iconSize: compact ? 16 : 18,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              vault!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        vault!.absolutePath,
                        maxLines: compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: vault == null ? 'Select vault' : 'Change vault',
                icon: Icons.folder_open_rounded,
                variant: AppButtonVariant.secondary,
                onPressed: isBusy ? null : onPickVault,
              ),
            ),
            if (vault != null) ...[
              const SizedBox(width: AppSpacing.xs),
              SizedBox(
                width: 42,
                child: IconButton(
                  onPressed: isBusy ? null : onClearVault,
                  tooltip: 'Clear saved vault',
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
              ),
            ],
          ],
        ),
        if (!compact) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'VaultWash scans markdown files recursively and never writes during the scan.',
            style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
          ),
        ],
      ],
    );
  }
}

class _VaultIcon extends StatelessWidget {
  const _VaultIcon({
    required this.colors,
    required this.icon,
    required this.size,
    required this.iconSize,
  });

  final AppColors colors;
  final IconData icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: AppRadius.sm,
        border: Border.all(color: colors.border),
      ),
      child: Icon(icon, size: iconSize, color: colors.textSecondary),
    );
  }
}
