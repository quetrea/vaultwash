import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultwash/features/cleanup/domain/inspector_mode.dart';
import 'package:vaultwash/features/workspace/domain/workspace_preferences.dart';
import 'package:vaultwash/features/workspace/infrastructure/workspace_preferences_local_data_source.dart';

final workspacePreferencesControllerProvider =
    NotifierProvider<WorkspacePreferencesController, WorkspacePreferences>(
      WorkspacePreferencesController.new,
    );

class WorkspacePreferencesController extends Notifier<WorkspacePreferences> {
  @override
  WorkspacePreferences build() {
    return ref.watch(workspacePreferencesLocalDataSourceProvider).load();
  }

  Future<void> _persist(WorkspacePreferences next) async {
    final normalized = next.normalized();
    final previous = state;
    state = normalized;
    try {
      await ref
          .read(workspacePreferencesLocalDataSourceProvider)
          .save(normalized);
    } catch (_) {
      state = previous;
      rethrow;
    }
  }

  Future<void> setDesktopRailWidth(double width) async {
    await _persist(state.copyWith(desktopRailWidth: width));
  }

  Future<void> clearDesktopRailWidth() async {
    await _persist(state.copyWith(clearDesktopRailWidth: true));
  }

  Future<void> setDesktopPreviewFraction(double fraction) async {
    await _persist(state.copyWith(desktopPreviewFraction: fraction));
  }

  Future<void> clearDesktopPreviewFraction() async {
    await _persist(state.copyWith(clearDesktopPreviewFraction: true));
  }

  Future<void> setSummaryCollapsed(bool collapsed) async {
    await _persist(state.copyWith(summaryCollapsed: collapsed));
  }

  Future<void> toggleSummaryCollapsed() async {
    await setSummaryCollapsed(!state.summaryCollapsed);
  }

  Future<void> setInspectorMode(InspectorMode mode) async {
    await _persist(state.copyWith(inspectorMode: mode));
  }
}
