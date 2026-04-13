import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultwash/app/theme/app_tokens.dart';
import 'package:vaultwash/core/widgets/app_section_header.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_preset.dart';
import 'package:vaultwash/features/cleanup/infrastructure/default_cleanup_rules.dart';
import 'package:vaultwash/features/cleanup/presentation/cleanup_history_dialog.dart';
import 'package:vaultwash/features/settings/application/app_settings_controller.dart';
import 'package:vaultwash/features/settings/domain/app_appearance_mode.dart';

class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({super.key});

  @override
  ConsumerState<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<SettingsDialog> {
  final _folderNameController = TextEditingController();

  @override
  void dispose() {
    _folderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final settings = ref.watch(appSettingsControllerProvider);
    final rules = ref.watch(cleanupRulesProvider);
    final notifier = ref.read(appSettingsControllerProvider.notifier);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────────
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

                // ── Appearance ──────────────────────────────────────────────
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Follow the system appearance or keep VaultWash in a fixed light or dark mode.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<AppAppearanceMode>(
                  showSelectedIcon: false,
                  segments: AppAppearanceMode.values
                      .map(
                        (mode) => ButtonSegment<AppAppearanceMode>(
                          value: mode,
                          label: Text(mode.label),
                        ),
                      )
                      .toList(),
                  selected: {settings.appearanceMode},
                  onSelectionChanged: (selection) {
                    notifier.setAppearanceMode(selection.first);
                  },
                ),

                // ── Write behaviour ─────────────────────────────────────────
                const Divider(height: AppSpacing.xl),
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

                // ── Scan exclusions ─────────────────────────────────────────
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
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Excluded folder names',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Exact folder basenames to skip during scanning (e.g. archive, old-notes).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _ExcludedFolderNamesList(
                  names: settings.excludedFolderNames,
                  controller: _folderNameController,
                  onAdd: (name) => notifier.addExcludedFolderName(name),
                  onRemove: (name) => notifier.removeExcludedFolderName(name),
                ),

                // ── Cleanup rules ───────────────────────────────────────────
                const Divider(height: AppSpacing.xl),
                Text(
                  'Cleanup rules',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Choose a preset to configure rules quickly, or enable them individually.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _PresetSelector(
                  activePreset: settings.activePreset,
                  onSelect: (preset) => notifier.applyPreset(preset, rules),
                ),
                const SizedBox(height: AppSpacing.sm),
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

                // ── History ─────────────────────────────────────────────────
                const Divider(height: AppSpacing.xl),
                Text(
                  'Cleanup history',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Review past cleanup sessions and restore from backups.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () => _openHistory(context),
                    icon: const Icon(Icons.history_rounded, size: 16),
                    label: const Text('View history'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openHistory(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => const CleanupHistoryDialog(),
    );
  }
}

// ── Preset selector ────────────────────────────────────────────────────────────

class _PresetSelector extends StatelessWidget {
  const _PresetSelector({
    required this.activePreset,
    required this.onSelect,
  });

  final CleanupPreset? activePreset;
  final ValueChanged<CleanupPreset> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: CleanupPreset.values.map((preset) {
        final isActive = activePreset == preset;
        return Tooltip(
          message: preset.description,
          waitDuration: const Duration(milliseconds: 400),
          child: FilterChip(
            label: Text(preset.label),
            selected: isActive,
            showCheckmark: false,
            onSelected: (_) => onSelect(preset),
            backgroundColor: colors.surfaceMuted,
            selectedColor: colors.accentSoft,
            labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isActive ? colors.accent : colors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
            side: BorderSide(
              color: isActive ? colors.accent : colors.border,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Excluded folder names list ─────────────────────────────────────────────────

class _ExcludedFolderNamesList extends StatelessWidget {
  const _ExcludedFolderNamesList({
    required this.names,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> names;
  final TextEditingController controller;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Folder name to exclude…',
                  hintStyle: TextStyle(color: colors.textMuted),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.sm,
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.sm,
                    borderSide: BorderSide(color: colors.border),
                  ),
                ),
                onSubmitted: _handleAdd,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            IconButton(
              onPressed: () => _handleAdd(controller.text),
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Add folder',
            ),
          ],
        ),
        if (names.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: names
                .map(
                  (name) => Chip(
                    label: Text(name),
                    labelStyle: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                    deleteIcon: const Icon(Icons.close_rounded, size: 14),
                    onDeleted: () => onRemove(name),
                    backgroundColor: colors.surfaceMuted,
                    side: BorderSide(color: colors.border),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  void _handleAdd(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      onAdd(trimmed);
      controller.clear();
    }
  }
}
