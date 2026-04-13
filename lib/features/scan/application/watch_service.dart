import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watcher/watcher.dart';

final vaultWatchServiceProvider = Provider<VaultWatchService>(
  (ref) => const NoOpVaultWatchService(),
);

abstract class VaultWatchService {
  const VaultWatchService();

  Stream<WatchEvent> watch(String path);
}

class NoOpVaultWatchService extends VaultWatchService {
  const NoOpVaultWatchService();

  @override
  Stream<WatchEvent> watch(String path) => const Stream.empty();
}
