import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultwash/app/theme/app_tokens.dart';
import 'package:vaultwash/features/scan/presentation/workspace_layout.dart';
import 'package:vaultwash/features/workspace/application/workspace_preferences_controller.dart';

class DesktopWorkspaceLayout extends ConsumerStatefulWidget {
  const DesktopWorkspaceLayout({
    super.key,
    required this.layout,
    required this.leftRail,
    required this.centerPane,
    required this.previewPane,
  });

  final WorkspaceLayoutSpec layout;
  final Widget leftRail;
  final Widget centerPane;
  final Widget previewPane;

  @override
  ConsumerState<DesktopWorkspaceLayout> createState() =>
      _DesktopWorkspaceLayoutState();
}

class _DesktopWorkspaceLayoutState
    extends ConsumerState<DesktopWorkspaceLayout> {
  double? _dragRailWidth;
  double? _dragPreviewFraction;

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(workspacePreferencesControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final geometry = widget.layout.resolveDesktopGeometry(
            totalWidth: constraints.maxWidth,
            desiredRailWidth:
                _dragRailWidth ??
                preferences.desktopRailWidth ??
                widget.layout.leftRailWidth,
            desiredPreviewFraction:
                _dragPreviewFraction ??
                preferences.desktopPreviewFraction ??
                widget.layout.defaultPreviewFraction,
          );

          return Row(
            key: ValueKey('workspace-layout-${widget.layout.variant.name}'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                key: const ValueKey('workspace-left-rail-host'),
                width: geometry.railWidth,
                child: widget.leftRail,
              ),
              _WorkspaceResizeHandle(
                key: const ValueKey('workspace-rail-resize-handle'),
                tooltip: 'Resize utility rail',
                onDragUpdate: (delta) {
                  setState(() {
                    _dragRailWidth =
                        (_dragRailWidth ?? geometry.railWidth) + delta;
                  });
                },
                onDragEnd: () {
                  final controller = ref.read(
                    workspacePreferencesControllerProvider.notifier,
                  );
                  final committedGeometry = widget.layout
                      .resolveDesktopGeometry(
                        totalWidth: constraints.maxWidth,
                        desiredRailWidth:
                            _dragRailWidth ??
                            preferences.desktopRailWidth ??
                            widget.layout.leftRailWidth,
                        desiredPreviewFraction:
                            _dragPreviewFraction ??
                            preferences.desktopPreviewFraction ??
                            widget.layout.defaultPreviewFraction,
                      );
                  unawaited(
                    controller.setDesktopRailWidth(committedGeometry.railWidth),
                  );
                  setState(() {
                    _dragRailWidth = null;
                  });
                },
                onDragCancel: () {
                  setState(() {
                    _dragRailWidth = null;
                  });
                },
              ),
              SizedBox(
                key: const ValueKey('workspace-center-pane-host'),
                width: geometry.centerWidth,
                child: widget.centerPane,
              ),
              _WorkspaceResizeHandle(
                key: const ValueKey('workspace-preview-resize-handle'),
                tooltip: 'Resize review pane',
                onDragCancel: () {
                  setState(() {
                    _dragPreviewFraction = null;
                  });
                },
                onDragUpdate: (delta) {
                  if (geometry.contentWidth == 0) {
                    return;
                  }

                  setState(() {
                    _dragPreviewFraction =
                        (_dragPreviewFraction ??
                            (geometry.previewWidth / geometry.contentWidth)) -
                        (delta / geometry.contentWidth);
                  });
                },
                onDragEnd: () {
                  final controller = ref.read(
                    workspacePreferencesControllerProvider.notifier,
                  );
                  final committedGeometry = widget.layout
                      .resolveDesktopGeometry(
                        totalWidth: constraints.maxWidth,
                        desiredRailWidth:
                            _dragRailWidth ??
                            preferences.desktopRailWidth ??
                            widget.layout.leftRailWidth,
                        desiredPreviewFraction:
                            _dragPreviewFraction ??
                            preferences.desktopPreviewFraction ??
                            widget.layout.defaultPreviewFraction,
                      );
                  if (committedGeometry.contentWidth > 0) {
                    unawaited(
                      controller.setDesktopPreviewFraction(
                        committedGeometry.previewWidth /
                            committedGeometry.contentWidth,
                      ),
                    );
                  }
                  setState(() {
                    _dragPreviewFraction = null;
                  });
                },
              ),
              SizedBox(
                key: const ValueKey('workspace-preview-pane-host'),
                width: geometry.previewWidth,
                child: widget.previewPane,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WorkspaceResizeHandle extends StatefulWidget {
  const _WorkspaceResizeHandle({
    super.key,
    required this.tooltip,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
  });

  final String tooltip;
  final ValueChanged<double> onDragUpdate;
  final VoidCallback onDragEnd;
  final VoidCallback onDragCancel;

  @override
  State<_WorkspaceResizeHandle> createState() => _WorkspaceResizeHandleState();
}

class _WorkspaceResizeHandleState extends State<_WorkspaceResizeHandle> {
  bool _hovered = false;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isActive = _hovered || _dragging;

    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.tooltip,
        waitDuration: const Duration(milliseconds: 500),
        child: Semantics(
          label: widget.tooltip,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: (_) => setState(() => _dragging = true),
            onHorizontalDragUpdate: (details) {
              widget.onDragUpdate(details.delta.dx);
            },
            onHorizontalDragEnd: (_) {
              setState(() => _dragging = false);
              widget.onDragEnd();
            },
            onHorizontalDragCancel: () {
              setState(() => _dragging = false);
              widget.onDragCancel();
            },
            child: SizedBox(
              width: WorkspaceLayoutSpec.resizeHandleWidth,
              child: Center(
                child: AnimatedContainer(
                  duration: AppDurations.quick,
                  curve: Curves.easeOut,
                  width: isActive ? 3 : 2,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isActive ? colors.accent : colors.borderStrong,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
