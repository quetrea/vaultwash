import 'dart:math' as math;

import 'package:vaultwash/app/theme/app_tokens.dart';

enum WorkspaceLayoutVariant { constrained, compact, standard, wide }

class WorkspaceLayoutSpec {
  const WorkspaceLayoutSpec._({
    required this.variant,
    required this.leftRailWidth,
    required this.contentGap,
    required this.centerFlex,
    required this.previewFlex,
  });

  static const double wideMinWidth = 1440;
  static const double standardMinWidth = 1240;
  static const double compactMinWidth = 960;
  static const double resizeHandleWidth = 14;

  static const WorkspaceLayoutSpec wide = WorkspaceLayoutSpec._(
    variant: WorkspaceLayoutVariant.wide,
    leftRailWidth: 296,
    contentGap: AppSpacing.md,
    centerFlex: 12,
    previewFlex: 11,
  );

  static const WorkspaceLayoutSpec standard = WorkspaceLayoutSpec._(
    variant: WorkspaceLayoutVariant.standard,
    leftRailWidth: 272,
    contentGap: AppSpacing.md,
    centerFlex: 11,
    previewFlex: 10,
  );

  static const WorkspaceLayoutSpec compact = WorkspaceLayoutSpec._(
    variant: WorkspaceLayoutVariant.compact,
    leftRailWidth: 248,
    contentGap: AppSpacing.md,
    centerFlex: 1,
    previewFlex: 1,
  );

  static const WorkspaceLayoutSpec constrained = WorkspaceLayoutSpec._(
    variant: WorkspaceLayoutVariant.constrained,
    leftRailWidth: 248,
    contentGap: AppSpacing.md,
    centerFlex: 1,
    previewFlex: 1,
  );

  final WorkspaceLayoutVariant variant;
  final double leftRailWidth;
  final double contentGap;
  final int centerFlex;
  final int previewFlex;

  double get defaultPreviewFraction => previewFlex / (centerFlex + previewFlex);

  double get minDesktopRailWidth =>
      variant == WorkspaceLayoutVariant.wide ? 248 : 224;

  double get maxDesktopRailWidth =>
      variant == WorkspaceLayoutVariant.wide ? 360 : 320;

  double get minCenterPaneWidth =>
      variant == WorkspaceLayoutVariant.wide ? 360 : 320;

  double get minPreviewPaneWidth =>
      variant == WorkspaceLayoutVariant.wide ? 380 : 340;

  bool get showsTriPane =>
      variant == WorkspaceLayoutVariant.wide ||
      variant == WorkspaceLayoutVariant.standard;

  bool get usesCompactWorkspace =>
      variant == WorkspaceLayoutVariant.compact ||
      variant == WorkspaceLayoutVariant.constrained;

  bool get showsMinimumWidthFallback =>
      variant == WorkspaceLayoutVariant.constrained;

  WorkspaceDesktopGeometry resolveDesktopGeometry({
    required double totalWidth,
    required double desiredRailWidth,
    required double desiredPreviewFraction,
  }) {
    final maxRailByViewport =
        totalWidth -
        (resizeHandleWidth * 2) -
        minCenterPaneWidth -
        minPreviewPaneWidth;
    final railUpperBound = math
        .max(
          minDesktopRailWidth,
          math.min(maxDesktopRailWidth, maxRailByViewport),
        )
        .toDouble();
    final railLowerBound = math.min(minDesktopRailWidth, railUpperBound);
    final railWidth = desiredRailWidth
        .clamp(railLowerBound, railUpperBound)
        .toDouble();
    final contentWidth = math.max(
      0.0,
      totalWidth - railWidth - (resizeHandleWidth * 2),
    );
    final previewLowerBound = math.min(minPreviewPaneWidth, contentWidth);
    final previewUpperBound = math.max(
      previewLowerBound,
      contentWidth - minCenterPaneWidth,
    );
    final previewWidth = (contentWidth * desiredPreviewFraction)
        .clamp(previewLowerBound, previewUpperBound)
        .toDouble();

    return WorkspaceDesktopGeometry(
      railWidth: railWidth,
      centerWidth: math.max(0.0, contentWidth - previewWidth),
      previewWidth: previewWidth,
      resizeHandleWidth: resizeHandleWidth,
    );
  }

  static WorkspaceLayoutSpec resolve(double width) {
    if (width >= wideMinWidth) {
      return wide;
    }
    if (width >= standardMinWidth) {
      return standard;
    }
    if (width >= compactMinWidth) {
      return compact;
    }
    return constrained;
  }
}

class WorkspaceDesktopGeometry {
  const WorkspaceDesktopGeometry({
    required this.railWidth,
    required this.centerWidth,
    required this.previewWidth,
    required this.resizeHandleWidth,
  });

  final double railWidth;
  final double centerWidth;
  final double previewWidth;
  final double resizeHandleWidth;

  double get contentWidth => centerWidth + previewWidth;
}
