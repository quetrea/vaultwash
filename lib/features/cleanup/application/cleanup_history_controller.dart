import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_session.dart';
import 'package:vaultwash/features/cleanup/infrastructure/cleanup_history_local_data_source.dart';

final cleanupHistoryControllerProvider =
    AsyncNotifierProvider<CleanupHistoryController, List<CleanupSession>>(
      CleanupHistoryController.new,
    );

class CleanupHistoryController extends AsyncNotifier<List<CleanupSession>> {
  @override
  Future<List<CleanupSession>> build() async {
    return ref.read(cleanupHistoryLocalDataSourceProvider).load();
  }

  Future<void> record(CleanupSession session) async {
    await ref.read(cleanupHistoryLocalDataSourceProvider).append(session);

    final current = state.asData?.value ?? [];
    state = AsyncData([session, ...current].take(50).toList());
  }
}
