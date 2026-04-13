import 'package:flutter_test/flutter_test.dart';
import 'package:vaultwash/features/scan/presentation/workspace_layout.dart';

void main() {
  test('desktop geometry clamps pane sizes to keep review panes usable', () {
    final layout = WorkspaceLayoutSpec.standard;
    final geometry = layout.resolveDesktopGeometry(
      totalWidth: 1200,
      desiredRailWidth: 720,
      desiredPreviewFraction: 0.95,
    );

    expect(geometry.railWidth, layout.maxDesktopRailWidth);
    expect(
      geometry.centerWidth,
      greaterThanOrEqualTo(layout.minCenterPaneWidth),
    );
    expect(
      geometry.previewWidth,
      greaterThanOrEqualTo(layout.minPreviewPaneWidth),
    );
  });

  test(
    'desktop geometry honors minimum rail width when users drag too far',
    () {
      final layout = WorkspaceLayoutSpec.wide;
      final geometry = layout.resolveDesktopGeometry(
        totalWidth: 1460,
        desiredRailWidth: 80,
        desiredPreviewFraction: 0.10,
      );

      expect(geometry.railWidth, layout.minDesktopRailWidth);
      expect(
        geometry.centerWidth,
        greaterThanOrEqualTo(layout.minCenterPaneWidth),
      );
      expect(
        geometry.previewWidth,
        greaterThanOrEqualTo(layout.minPreviewPaneWidth),
      );
    },
  );
}
