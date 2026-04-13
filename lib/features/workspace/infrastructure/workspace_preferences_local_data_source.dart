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

    final bool railOk;
    if (normalized.desktopRailWidth == null) {
      railOk = await _preferences.remove(_desktopRailWidthKey);
    } else {
      railOk = await _preferences.setDouble(
        _desktopRailWidthKey,
        normalized.desktopRailWidth!,
      );
    }
    if (!railOk) throw Exception('Failed to persist $_desktopRailWidthKey');

    final bool previewOk;
    if (normalized.desktopPreviewFraction == null) {
      previewOk = await _preferences.remove(_desktopPreviewFractionKey);
    } else {
      previewOk = await _preferences.setDouble(
        _desktopPreviewFractionKey,
        normalized.desktopPreviewFraction!,
      );
    }
    if (!previewOk) {
      throw Exception('Failed to persist $_desktopPreviewFractionKey');
    }

    final collapsedOk = await _preferences.setBool(
      _summaryCollapsedKey,
      normalized.summaryCollapsed,
    );
    if (!collapsedOk) {
      throw Exception('Failed to persist $_summaryCollapsedKey');
    }

    final modeOk = await _preferences.setString(
      _inspectorModeKey,
      normalized.inspectorMode.storageValue,
    );
    if (!modeOk) throw Exception('Failed to persist $_inspectorModeKey');
  }
}
