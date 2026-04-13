import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultwash/app/theme/app_tokens.dart';
import 'package:vaultwash/core/widgets/app_surface_card.dart';
import 'package:vaultwash/core/widgets/empty_state_view.dart';
import 'package:vaultwash/features/cleanup/application/inspector_controller.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_preview.dart';
import 'package:vaultwash/features/cleanup/domain/inspector_mode.dart';
import 'package:vaultwash/features/scan/application/scan_controller.dart';
import 'package:vaultwash/features/scan/domain/scan_file_result.dart';

// ─── Main panel ───────────────────────────────────────────────────────────────

class PreviewPanel extends ConsumerWidget {
  const PreviewPanel({super.key, required this.fileResult});

  final ScanFileResult? fileResult;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inspector = ref.watch(inspectorControllerProvider);

    // Reset match navigation when the focused file changes so position
    // never carries over from a previous selection.
    ref.listen(
      scanControllerProvider.select(
        (s) => s.asData?.value.focusedRelativePath,
      ),
      (prev, next) {
        if (prev != next) {
          ref.read(inspectorControllerProvider.notifier).resetNavigation();
        }
      },
    );

    final excerpts = fileResult?.preview.excerpts ?? const [];
    final totalMatches = excerpts.length;
    final focusedIndex =
        totalMatches > 0 ? inspector.focusedMatchIndex.clamp(0, totalMatches - 1) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InspectorHeader(fileResult: fileResult),
        const SizedBox(height: AppSpacing.sm),
        if (fileResult == null)
          const Expanded(
            child: EmptyStateView(
              eyebrow: 'Inspector',
              title: 'Select a file to review',
              message:
                  'Choose an affected file from the list to inspect its citation artifacts and preview the cleaned result.',
              icon: Icons.manage_search_rounded,
            ),
          )
        else ...[
          _InspectorToolbar(
            inspector: inspector,
            totalMatches: totalMatches,
            onSetMode:
                ref.read(inspectorControllerProvider.notifier).setMode,
            onPreviousMatch: () => ref
                .read(inspectorControllerProvider.notifier)
                .previousMatch(totalMatches),
            onNextMatch: () => ref
                .read(inspectorControllerProvider.notifier)
                .nextMatch(totalMatches),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: _InspectorContent(
              fileResult: fileResult!,
              mode: inspector.mode,
              focusedIndex: focusedIndex,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Inspector header ─────────────────────────────────────────────────────────

class _InspectorHeader extends StatelessWidget {
  const _InspectorHeader({required this.fileResult});

  final ScanFileResult? fileResult;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'INSPECTOR',
                style: textTheme.labelSmall?.copyWith(
                  color: colors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              if (fileResult == null)
                Text(
                  'Review pane',
                  style: textTheme.titleSmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                )
              else
                Tooltip(
                  message: fileResult!.relativePath,
                  waitDuration: const Duration(milliseconds: 400),
                  child: Text(
                    _filename(fileResult!.relativePath),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall,
                  ),
                ),
            ],
          ),
        ),
        if (fileResult != null) ...[
          const SizedBox(width: AppSpacing.sm),
          _ArtifactBadge(count: fileResult!.matchCount),
        ],
      ],
    );
  }

  String _filename(String path) {
    final normalized = path.replaceAll('\\', '/');
    final parts = normalized.split('/');
    final name = parts.last;
    return name.isNotEmpty ? name : normalized;
  }
}

// ─── Artifact count badge ─────────────────────────────────────────────────────

class _ArtifactBadge extends StatelessWidget {
  const _ArtifactBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: AppRadius.sm,
        border: Border.all(color: colors.border),
      ),
      child: Text(
        '$count ${count == 1 ? 'artifact' : 'artifacts'}',
        style: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
      ),
    );
  }
}

// ─── Toolbar: mode toggle + match navigation ──────────────────────────────────

class _InspectorToolbar extends StatelessWidget {
  const _InspectorToolbar({
    required this.inspector,
    required this.totalMatches,
    required this.onSetMode,
    required this.onPreviousMatch,
    required this.onNextMatch,
  });

  final InspectorState inspector;
  final int totalMatches;
  final void Function(InspectorMode) onSetMode;
  final VoidCallback onPreviousMatch;
  final VoidCallback onNextMatch;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    final displayIndex = totalMatches > 0
        ? inspector.focusedMatchIndex.clamp(0, totalMatches - 1) + 1
        : 0;

    return Row(
      children: [
        _ModeToggle(current: inspector.mode, onSelect: onSetMode),
        const Spacer(),
        if (totalMatches > 0) ...[
          _NavButton(
            icon: Icons.chevron_left_rounded,
            onPressed: onPreviousMatch,
            tooltip: 'Previous match',
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$displayIndex of $totalMatches',
            style: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.xs),
          _NavButton(
            icon: Icons.chevron_right_rounded,
            onPressed: onNextMatch,
            tooltip: 'Next match',
          ),
        ] else
          Text(
            'No excerpts',
            style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
          ),
      ],
    );
  }
}

// ─── Mode toggle ──────────────────────────────────────────────────────────────

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.current, required this.onSelect});

  final InspectorMode current;
  final void Function(InspectorMode) onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      height: 28,
      decoration: BoxDecoration(
        borderRadius: AppRadius.sm,
        border: Border.all(color: colors.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeChip(
            label: 'Excerpts',
            isSelected: current == InspectorMode.excerpts,
            onTap: () => onSelect(InspectorMode.excerpts),
          ),
          Container(width: 1, color: colors.border),
          _ModeChip(
            label: 'Changes',
            isSelected: current == InspectorMode.changes,
            onTap: () => onSelect(InspectorMode.changes),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.quick,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        color: isSelected ? colors.accent : colors.surfaceMuted,
        child: Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: isSelected ? colors.background : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Navigation button ────────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 600),
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.sm,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xxs + 2),
          decoration: BoxDecoration(
            color: colors.surfaceMuted,
            borderRadius: AppRadius.sm,
            border: Border.all(color: colors.border),
          ),
          child: Icon(icon, size: 16, color: colors.textSecondary),
        ),
      ),
    );
  }
}

// ─── Content dispatcher ───────────────────────────────────────────────────────

class _InspectorContent extends StatelessWidget {
  const _InspectorContent({
    required this.fileResult,
    required this.mode,
    required this.focusedIndex,
  });

  final ScanFileResult fileResult;
  final InspectorMode mode;
  final int focusedIndex;

  @override
  Widget build(BuildContext context) {
    final excerpts = fileResult.preview.excerpts;

    if (excerpts.isEmpty) {
      return const _NoExcerptsPlaceholder();
    }

    return switch (mode) {
      InspectorMode.excerpts => _MatchListScrollable(
        key: const ValueKey('excerpts'),
        itemCount: excerpts.length,
        focusedIndex: focusedIndex,
        itemBuilder: (context, index, isFocused, globalKey) => KeyedSubtree(
          key: globalKey,
          child: _ExcerptCard(
            index: index,
            excerpt: excerpts[index],
            isFocused: isFocused,
          ),
        ),
      ),
      InspectorMode.changes => _MatchListScrollable(
        key: const ValueKey('changes'),
        itemCount: excerpts.length,
        focusedIndex: focusedIndex,
        separatorHeight: AppSpacing.xs,
        itemBuilder: (context, index, isFocused, globalKey) {
          final diff = InlineDiff.compute(
            excerpts[index].originalExcerpt,
            excerpts[index].cleanedExcerpt,
          );
          return KeyedSubtree(
            key: globalKey,
            child: _ChangesCard(
              index: index,
              excerpt: excerpts[index],
              diff: diff,
              isFocused: isFocused,
            ),
          );
        },
      ),
    };
  }
}

class _NoExcerptsPlaceholder extends StatelessWidget {
  const _NoExcerptsPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return AppSurfaceCard(
      backgroundColor: colors.surfaceMuted,
      child: Text(
        'This file has artifacts, but no excerpt preview is available. Re-run the scan to refresh.',
        style: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
      ),
    );
  }
}

// ─── Shared scrollable match list ─────────────────────────────────────────────
//
// Handles scroll controller lifecycle and auto-scrolls to the focused item
// whenever focusedIndex changes.  The itemBuilder receives a GlobalKey that
// the caller should attach to its root widget via KeyedSubtree.

typedef _MatchItemBuilder =
    Widget Function(BuildContext context, int index, bool isFocused, GlobalKey key);

class _MatchListScrollable extends StatefulWidget {
  const _MatchListScrollable({
    super.key,
    required this.itemCount,
    required this.focusedIndex,
    required this.itemBuilder,
    this.separatorHeight = AppSpacing.sm,
  });

  final int itemCount;
  final int focusedIndex;
  final _MatchItemBuilder itemBuilder;
  final double separatorHeight;

  @override
  State<_MatchListScrollable> createState() => _MatchListScrollableState();
}

class _MatchListScrollableState extends State<_MatchListScrollable> {
  late final ScrollController _scrollController;
  late List<GlobalKey> _keys;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _keys = List.generate(widget.itemCount, (_) => GlobalKey());
    if (widget.focusedIndex > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToFocused());
    }
  }

  @override
  void didUpdateWidget(_MatchListScrollable old) {
    super.didUpdateWidget(old);
    if (old.itemCount != widget.itemCount) {
      _keys = List.generate(widget.itemCount, (_) => GlobalKey());
    }
    if (old.focusedIndex != widget.focusedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToFocused());
    }
  }

  void _scrollToFocused() {
    if (_keys.isEmpty || widget.focusedIndex >= _keys.length) return;
    final ctx = _keys[widget.focusedIndex].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: AppDurations.standard,
      curve: Curves.easeInOut,
      alignment: 0.1,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _scrollController,
      itemCount: widget.itemCount,
      separatorBuilder: (_, _) => SizedBox(height: widget.separatorHeight),
      itemBuilder: (context, index) {
        return widget.itemBuilder(
          context,
          index,
          index == widget.focusedIndex,
          _keys[index],
        );
      },
    );
  }
}

// ─── Excerpts mode card ───────────────────────────────────────────────────────

class _ExcerptCard extends StatelessWidget {
  const _ExcerptCard({
    required this.index,
    required this.excerpt,
    required this.isFocused,
  });

  final int index;
  final PreviewExcerpt excerpt;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final monoStyle = textTheme.bodySmall?.copyWith(
      fontFamily: 'monospace',
      color: colors.textPrimary,
      height: 1.5,
    );

    return AnimatedContainer(
      duration: AppDurations.quick,
      decoration: BoxDecoration(
        borderRadius: AppRadius.sm,
        border: Border.all(
          color: isFocused ? colors.accent : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: AppSurfaceCard(
        backgroundColor: colors.surfaceRaised,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Match ${index + 1}',
                  style: textTheme.labelLarge?.copyWith(
                    color: isFocused ? colors.accent : colors.textSecondary,
                  ),
                ),
                const Spacer(),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: _RuleChip(ruleId: excerpt.ruleId),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _PreviewColumn(
                    label: 'Before',
                    value: excerpt.originalExcerpt,
                    backgroundColor: colors.surfaceSunken,
                    textStyle: monoStyle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _PreviewColumn(
                    label: 'After',
                    value: excerpt.cleanedExcerpt,
                    backgroundColor: colors.accentSoft,
                    textStyle: monoStyle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Changes mode card ────────────────────────────────────────────────────────

class _ChangesCard extends StatelessWidget {
  const _ChangesCard({
    required this.index,
    required this.excerpt,
    required this.diff,
    required this.isFocused,
  });

  final int index;
  final PreviewExcerpt excerpt;
  final InlineDiff diff;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: AppDurations.quick,
      decoration: BoxDecoration(
        borderRadius: AppRadius.sm,
        border: Border.all(
          color: isFocused ? colors.accent : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: AppSurfaceCard(
        backgroundColor: colors.surfaceRaised,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Match ${index + 1}',
                  style: textTheme.labelLarge?.copyWith(
                    color: isFocused ? colors.accent : colors.textSecondary,
                  ),
                ),
                const Spacer(),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: _RuleChip(ruleId: excerpt.ruleId),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (!diff.hasChange)
              Text(
                'No visible diff in this excerpt window.',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              _InlineDiffView(diff: diff),
          ],
        ),
      ),
    );
  }
}

// ─── Inline diff view (Changes mode rendering) ────────────────────────────────

class _InlineDiffView extends StatelessWidget {
  const _InlineDiffView({required this.diff});

  final InlineDiff diff;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final monoBase = textTheme.bodySmall?.copyWith(
      fontFamily: 'monospace',
      height: 1.5,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: AppRadius.sm,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (diff.removed.isNotEmpty) ...[
            _DiffLine(
              label: '−',
              labelColor: colors.danger,
              prefix: diff.prefix,
              changed: diff.removed,
              suffix: diff.suffix,
              monoBase: monoBase,
              highlightColor: colors.dangerSoft,
              textColor: colors.textPrimary,
              isAddition: false,
            ),
            if (diff.added.isNotEmpty) const SizedBox(height: AppSpacing.xxs),
          ],
          if (diff.added.isNotEmpty)
            _DiffLine(
              label: '+',
              labelColor: colors.accent,
              prefix: diff.prefix,
              changed: diff.added,
              suffix: diff.suffix,
              monoBase: monoBase,
              highlightColor: colors.accentSoft,
              textColor: colors.textPrimary,
              isAddition: true,
            ),
        ],
      ),
    );
  }
}

class _DiffLine extends StatelessWidget {
  const _DiffLine({
    required this.label,
    required this.labelColor,
    required this.prefix,
    required this.changed,
    required this.suffix,
    required this.monoBase,
    required this.highlightColor,
    required this.textColor,
    required this.isAddition,
  });

  final String label;
  final Color labelColor;
  final String prefix;
  final String changed;
  final String suffix;
  final TextStyle? monoBase;
  final Color highlightColor;
  final Color textColor;
  final bool isAddition;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 14,
          child: Text(
            label,
            style: monoBase?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: SelectableText.rich(
            TextSpan(
              children: [
                if (prefix.isNotEmpty)
                  TextSpan(
                    text: prefix,
                    style: monoBase?.copyWith(color: textColor),
                  ),
                TextSpan(
                  text: changed,
                  style: monoBase?.copyWith(
                    color: labelColor,
                    backgroundColor: highlightColor,
                    decoration: isAddition ? null : TextDecoration.lineThrough,
                    decorationColor: labelColor,
                  ),
                ),
                if (suffix.isNotEmpty)
                  TextSpan(
                    text: suffix,
                    style: monoBase?.copyWith(color: textColor),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

class _RuleChip extends StatelessWidget {
  const _RuleChip({required this.ruleId});

  final String ruleId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: AppRadius.sm,
        border: Border.all(color: colors.border),
      ),
      child: Text(
        ruleId,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.labelSmall?.copyWith(
          color: colors.textMuted,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class _PreviewColumn extends StatelessWidget {
  const _PreviewColumn({
    required this.label,
    required this.value,
    required this.backgroundColor,
    required this.textStyle,
  });

  final String label;
  final String value;
  final Color backgroundColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.sm,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SelectableText(value, style: textStyle),
        ],
      ),
    );
  }
}
