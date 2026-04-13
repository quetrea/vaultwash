import 'package:vaultwash/features/cleanup/domain/cleanup_rule.dart';
import 'package:vaultwash/features/vault/domain/vault_ref.dart';

class ScanRequest {
  const ScanRequest({
    required this.vault,
    required this.enabledRules,
    required this.excludeObsidian,
    required this.excludeHiddenFolders,
    this.excludedFolderNames = const [],
  });

  final VaultRef vault;
  final List<CleanupRule> enabledRules;
  final bool excludeObsidian;
  final bool excludeHiddenFolders;

  /// Additional exact folder basenames to skip during scanning.
  final List<String> excludedFolderNames;
}
