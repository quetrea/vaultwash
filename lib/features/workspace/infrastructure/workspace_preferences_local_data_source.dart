import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaultwash/features/cleanup/domain/inspector_mode.dart';
import 'package:vaultwash/features/settings/infrastructure/settings_local_data_source.dart';
import 'package:vaultwash/features/workspace/domain/workspace_preferences.dart';

const _desktopRailWidthKey = 'workspace.desktop_rail_width';
const _desktopPreviewFractionKey = 'workspace.desktop_preview_fraction';
const _summaryCollapsedKey = 'workspace.summary_collapsed';
const _inspectorModeKey = 'workspace.inspector_mode';

final workspacePreferencesLocalDataSourceProvider =
    Provider<WorkspacePreferencesLocalDataSource>(
      (ref) => WorkspacePreferencesLocalDataSource(
        ref.watch(sharedPreferencesProvider),
      ),
    );

class WorkspacePreferencesLocalDataSource {
  WorkspacePreferencesLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  WorkspacePreferences load() {
    return WorkspacePreferences(
      desktopRailWidth: _preferences.getDouble(_desktopRailWidthKey),
      desktopPreviewFraction: _preferences.getDouble(
        _desktopPreviewFractionKey,
      ),
      summaryCollapsed: _preferences.getBool(_summaryCollapsedKey) ?? false,
      inspectorMode: InspectorMode.fromStorageValue(
        _preferences.getString(_inspectorModeKey),
      ),
    ).normalized();
  }

  Future<void> save(WorkspacePreferences preferences) async {
    final normalized = preferences.normalized();

    if (normalized.desktopRailWidth == null) {
      await _preferences.remove(_desktopRailWidthKey);
    } else {
      await _preferences.setDouble(
        _desktopRailWidthKey,
        normalized.desktopRailWidth!,
      );
    }

    if (normalized.desktopPreviewFraction == null) {
      await _preferences.remove(_desktopPreviewFractionKey);
    } else {
      await _preferences.setDouble(
        _desktopPreviewFractionKey,
        normalized.desktopPreviewFraction!,
      );
    }

    await _preferences.setBool(
      _summaryCollapsedKey,
      normalized.summaryCollapsed,
    );
    await _preferences.setString(
      _inspectorModeKey,
      normalized.inspectorMode.storageValue,
    );
  }
}
