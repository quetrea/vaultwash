import 'package:flutter/material.dart';
import 'package:vaultwash/app/theme/app_tokens.dart';
import 'package:vaultwash/core/widgets/app_section_header.dart';
import 'package:vaultwash/core/widgets/empty_state_view.dart';
import 'package:vaultwash/features/scan/domain/scan_file_result.dart';

class AffectedFilesList extends StatelessWidget {
  const AffectedFilesList({
    super.key,
    required this.files,
    required this.selectedPaths,
    required this.focusedRelativePath,
    required this.onToggleSelection,
    required this.onFocusFile,
  });

  final List<ScanFileResult> files;
  final Set<String> selectedPaths;
  final String? focusedRelativePath;
  final ValueChanged<String> onFocusFile;
  final void Function(String relativePath, bool selected) onToggleSelection;

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return const EmptyStateView(
        title: 'No files need cleanup',
        message:
            'This scan did not find broken citation artifacts in the markdown files that were checked.',
        icon: Icons.task_alt_rounded,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Files to review',
          subtitle:
              '${files.length} markdown files are ready for preview before cleanup.',
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: ListView.separated(
            itemCount: files.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
            itemBuilder: (context, index) {
              final file = files[index];
              final isFocused = file.relativePath == focusedRelativePath;
              final isSelected = selectedPaths.contains(file.relativePath);

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: AppRadius.sm,
                  onTap: () => onFocusFile(file.relativePath),
                  child: AnimatedContainer(
                    duration: AppDurations.quick,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isFocused
                          ? AppColors.accentSoft
                          : AppColors.surfaceRaised,
                      borderRadius: AppRadius.sm,
                      border: Border.all(
                        color: isFocused ? AppColors.accent : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            onToggleSelection(
                              file.relativePath,
                              value ?? false,
                            );
                          },
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                file.relativePath,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                file.matchedSnippets.isEmpty
                                    ? 'Broken citation artifact detected.'
                                    : file.matchedSnippets.first,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Chip(label: Text('${file.matchCount}')),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
