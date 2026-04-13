import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultwash/features/cleanup/domain/inspector_mode.dart';
import 'package:vaultwash/features/workspace/application/workspace_preferences_controller.dart';

final inspectorControllerProvider =
    NotifierProvider<InspectorController, InspectorState>(
      InspectorController.new,
    );

/// Local UI state for the inspector / review pane.
///
/// Deliberately separate from [ScanWorkspaceState] so that review-specific
/// concerns (mode, focused match, etc.) never bleed into the scan controller.
class InspectorState {
  const InspectorState({
    this.mode = InspectorMode.excerpts,
    this.focusedMatchIndex = 0,
  });

  final InspectorMode mode;

  /// 0-based index of the currently focused match within the selected file.
  final int focusedMatchIndex;

  InspectorState copyWith({InspectorMode? mode, int? focusedMatchIndex}) {
    return InspectorState(
      mode: mode ?? this.mode,
      focusedMatchIndex: focusedMatchIndex ?? this.focusedMatchIndex,
    );
  }
}

/// Controls inspection mode and match navigation for the review pane.
class InspectorController extends Notifier<InspectorState> {
  @override
  InspectorState build() {
    final preferences = ref.read(workspacePreferencesControllerProvider);
    return InspectorState(mode: preferences.inspectorMode);
  }

  /// Switch the active inspection mode.
  void setMode(InspectorMode mode) {
    state = state.copyWith(mode: mode);
    unawaited(
      ref
          .read(workspacePreferencesControllerProvider.notifier)
          .setInspectorMode(mode),
    );
  }

  /// Advance to the next match, wrapping around at the end.
  void nextMatch(int totalMatches) {
    if (totalMatches == 0) return;
    state = state.copyWith(
      focusedMatchIndex: (state.focusedMatchIndex + 1) % totalMatches,
    );
  }

  /// Go back to the previous match, wrapping around at the start.
  void previousMatch(int totalMatches) {
    if (totalMatches == 0) return;
    state = state.copyWith(
      focusedMatchIndex:
          (state.focusedMatchIndex - 1 + totalMatches) % totalMatches,
    );
  }

  /// Reset navigation to the first match.
  ///
  /// Called automatically when the focused file changes so match position
  /// does not carry over between different files.
  void resetNavigation() {
    if (state.focusedMatchIndex != 0) {
      state = state.copyWith(focusedMatchIndex: 0);
    }
  }
}
