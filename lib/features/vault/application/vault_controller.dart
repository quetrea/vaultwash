import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultwash/core/error/app_exception.dart';
import 'package:vaultwash/features/settings/application/app_settings_controller.dart';
import 'package:vaultwash/features/vault/domain/vault_ref.dart';
import 'package:vaultwash/features/vault/infrastructure/vault_picker_service.dart';

final vaultControllerProvider =
    AsyncNotifierProvider<VaultController, VaultRef?>(VaultController.new);

class VaultController extends AsyncNotifier<VaultRef?> {
  @override
  Future<VaultRef?> build() async {
    final lastVaultPath = ref
        .watch(appSettingsControllerProvider)
        .lastVaultPath;

    if (lastVaultPath == null || lastVaultPath.isEmpty) {
      return null;
    }

    final directory = Directory(lastVaultPath);
    if (await directory.exists()) {
      return VaultRef.fromPath(lastVaultPath);
    }

    await ref.read(appSettingsControllerProvider.notifier).clearLastVaultPath();
    return null;
  }

  Future<void> pickVault() async {
    final selectedPath = await ref
        .read(vaultPickerServiceProvider)
        .pickVaultDirectory();

    if (selectedPath == null || selectedPath.isEmpty) {
      return;
    }

    await setVaultPath(selectedPath);
  }

  Future<void> setVaultPath(String path) async {
    final normalized = VaultRef.fromPath(path);
    final directory = Directory(normalized.absolutePath);

    if (!await directory.exists()) {
      throw const AppException('The selected vault path no longer exists.');
    }

    await ref
        .read(appSettingsControllerProvider.notifier)
        .setLastVaultPath(normalized.absolutePath);

    state = AsyncData(normalized);
  }

  Future<void> clearVault() async {
    await ref.read(appSettingsControllerProvider.notifier).clearLastVaultPath();
    state = const AsyncData(null);
  }
}
