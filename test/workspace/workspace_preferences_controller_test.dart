import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaultwash/features/cleanup/domain/inspector_mode.dart';
import 'package:vaultwash/features/settings/infrastructure/settings_local_data_source.dart';
import 'package:vaultwash/features/workspace/application/workspace_preferences_controller.dart';
import 'package:vaultwash/features/workspace/domain/workspace_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads and persists controlled workspace preferences', () async {
    SharedPreferences.setMockInitialValues({
      'workspace.desktop_rail_width': 332.0,
      'workspace.desktop_preview_fraction': 0.58,
      'workspace.summary_collapsed': true,
      'workspace.inspector_mode': 'changes',
    });

    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
    );
    addTearDown(container.dispose);

    final initial = container.read(workspacePreferencesControllerProvider);
    expect(initial.desktopRailWidth, 332);
    expect(initial.desktopPreviewFraction, 0.58);
    expect(initial.summaryCollapsed, isTrue);
    expect(initial.inspectorMode, InspectorMode.changes);

    await container
        .read(workspacePreferencesControllerProvider.notifier)
        .setDesktopRailWidth(520);
    await container
        .read(workspacePreferencesControllerProvider.notifier)
        .setDesktopPreviewFraction(0.12);
    await container
        .read(workspacePreferencesControllerProvider.notifier)
        .setSummaryCollapsed(false);
    await container
        .read(workspacePreferencesControllerProvider.notifier)
        .setInspectorMode(InspectorMode.excerpts);

    expect(
      preferences.getDouble('workspace.desktop_rail_width'),
      WorkspacePreferences.maxDesktopRailWidth,
    );
    expect(
      preferences.getDouble('workspace.desktop_preview_fraction'),
      WorkspacePreferences.minDesktopPreviewFraction,
    );
    expect(preferences.getBool('workspace.summary_collapsed'), isFalse);
    expect(preferences.getString('workspace.inspector_mode'), 'excerpts');
  });
}
