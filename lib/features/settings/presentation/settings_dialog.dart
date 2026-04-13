import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultwash/app/theme/app_tokens.dart';
import 'package:vaultwash/core/widgets/app_section_header.dart';
import 'package:vaultwash/features/cleanup/infrastructure/default_cleanup_rules.dart';
import 'package:vaultwash/features/settings/application/app_settings_controller.dart';

class SettingsDialog extends ConsumerWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsControllerProvider);
    final rules = ref.watch(cleanupRulesProvider);
    final notifier = ref.read(appSettingsControllerProvider.notifier);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: AppSectionHeader(
                        title: 'Settings',
                        subtitle:
                            'Local desktop defaults for VaultWash scans and cleanup.',
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Write behavior',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: settings.createBackupsBeforeWrite,
                  title: const Text('Create .bak backups before writing'),
                  subtitle: const Text(
                    'Writes a sibling backup beside each cleaned markdown file.',
                  ),
                  onChanged: notifier.setCreateBackupsBeforeWrite,
                ),
                const Divider(height: AppSpacing.xl),
                Text(
                  'Scan exclusions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: settings.excludeObsidian,
                  title: const Text('Exclude .obsidian/'),
                  subtitle: const Text(
                    'Skip Obsidian metadata and workspace files.',
                  ),
                  onChanged: notifier.setExcludeObsidian,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: settings.excludeHiddenFolders,
                  title: const Text('Exclude hidden folders'),
                  subtitle: const Text(
                    'Skip dot-prefixed folders outside the main vault content.',
                  ),
                  onChanged: notifier.setExcludeHiddenFolders,
                ),
                const Divider(height: AppSpacing.xl),
                Text(
                  'Cleanup rules',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                ...rules.map(
                  (rule) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: settings.enabledRuleIds.contains(rule.id),
                    title: Text(rule.label),
                    subtitle: Text(rule.description),
                    onChanged: (enabled) {
                      if (enabled == null) {
                        return;
                      }

                      notifier.setRuleEnabled(rule.id, enabled);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
