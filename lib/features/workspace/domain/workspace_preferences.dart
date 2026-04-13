import 'package:vaultwash/features/cleanup/domain/inspector_mode.dart';

class WorkspacePreferences {
  const WorkspacePreferences({
    this.desktopRailWidth,
    this.desktopPreviewFraction,
    this.summaryCollapsed = false,
    this.inspectorMode = InspectorMode.excerpts,
  });

  static const double minDesktopRailWidth = 224;
  static const double maxDesktopRailWidth = 360;
  static const double minDesktopPreviewFraction = 0.34;
  static const double maxDesktopPreviewFraction = 0.66;

  final double? desktopRailWidth;
  final double? desktopPreviewFraction;
  final bool summaryCollapsed;
  final InspectorMode inspectorMode;

  WorkspacePreferences copyWith({
    double? desktopRailWidth,
    bool clearDesktopRailWidth = false,
    double? desktopPreviewFraction,
    bool clearDesktopPreviewFraction = false,
    bool? summaryCollapsed,
    InspectorMode? inspectorMode,
  }) {
    return WorkspacePreferences(
      desktopRailWidth: clearDesktopRailWidth
          ? null
          : desktopRailWidth != null
          ? clampDesktopRailWidth(desktopRailWidth)
          : this.desktopRailWidth,
      desktopPreviewFraction: clearDesktopPreviewFraction
          ? null
          : desktopPreviewFraction != null
          ? clampDesktopPreviewFraction(desktopPreviewFraction)
          : this.desktopPreviewFraction,
      summaryCollapsed: summaryCollapsed ?? this.summaryCollapsed,
      inspectorMode: inspectorMode ?? this.inspectorMode,
    );
  }

  WorkspacePreferences normalized() {
    return WorkspacePreferences(
      desktopRailWidth: desktopRailWidth == null
          ? null
          : clampDesktopRailWidth(desktopRailWidth!),
      desktopPreviewFraction: desktopPreviewFraction == null
          ? null
          : clampDesktopPreviewFraction(desktopPreviewFraction!),
      summaryCollapsed: summaryCollapsed,
      inspectorMode: inspectorMode,
    );
  }

  static double clampDesktopRailWidth(double value) {
    return value.clamp(minDesktopRailWidth, maxDesktopRailWidth).toDouble();
  }

  static double clampDesktopPreviewFraction(double value) {
    return value
        .clamp(minDesktopPreviewFraction, maxDesktopPreviewFraction)
        .toDouble();
  }
}
