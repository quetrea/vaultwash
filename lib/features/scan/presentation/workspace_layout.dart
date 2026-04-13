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

  bool get showsTriPane =>
      variant == WorkspaceLayoutVariant.wide ||
      variant == WorkspaceLayoutVariant.standard;

  bool get usesCompactWorkspace =>
      variant == WorkspaceLayoutVariant.compact ||
      variant == WorkspaceLayoutVariant.constrained;

  bool get showsMinimumWidthFallback =>
      variant == WorkspaceLayoutVariant.constrained;

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
