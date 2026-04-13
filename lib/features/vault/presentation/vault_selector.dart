import 'package:flutter/material.dart';
import 'package:vaultwash/app/app_strings.dart';
import 'package:vaultwash/app/theme/app_tokens.dart';
import 'package:vaultwash/core/widgets/app_button.dart';
import 'package:vaultwash/core/widgets/app_input.dart';
import 'package:vaultwash/core/widgets/app_section_header.dart';
import 'package:vaultwash/features/vault/domain/vault_ref.dart';

class VaultSelector extends StatelessWidget {
  const VaultSelector({
    super.key,
    required this.vault,
    required this.isBusy,
    required this.onPickVault,
    required this.onClearVault,
  });

  final VaultRef? vault;
  final bool isBusy;
  final VoidCallback onPickVault;
  final VoidCallback onClearVault;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Vault',
          subtitle: 'Select the Obsidian vault you want VaultWash to review.',
        ),
        const SizedBox(height: AppSpacing.sm),
        AppInput(
          value: vault?.absolutePath,
          placeholder: 'No vault selected yet',
          maxLines: 2,
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
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppStrings.tagline,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}
