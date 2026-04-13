import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final vaultPickerServiceProvider = Provider<VaultPickerService>(
  (ref) => const VaultPickerService(),
);

class VaultPickerService {
  const VaultPickerService();

  Future<String?> pickVaultDirectory() {
    return FilePicker.getDirectoryPath(dialogTitle: 'Choose Obsidian vault');
  }
}
