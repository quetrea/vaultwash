import 'package:vaultwash/features/cleanup/domain/cleanup_rule.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_rule_category.dart';

enum CleanupPreset {
  safeCleanup,
  aiArtifacts,
  allRules;

  String get label => switch (this) {
    CleanupPreset.safeCleanup => 'Safe cleanup',
    CleanupPreset.aiArtifacts => 'AI artifact cleanup',
    CleanupPreset.allRules => 'All rules',
  };

  String get description => switch (this) {
    CleanupPreset.safeCleanup =>
      'Removes only the most conservative, clearly-broken oaicite citation patterns.',
    CleanupPreset.aiArtifacts =>
      'Removes all known AI-inserted citation and reference artifacts.',
    CleanupPreset.allRules => 'Enables every supported cleanup rule.',
  };

  String get storageValue => switch (this) {
    CleanupPreset.safeCleanup => 'safe_cleanup',
    CleanupPreset.aiArtifacts => 'ai_artifacts',
    CleanupPreset.allRules => 'all_rules',
  };

  static CleanupPreset? fromStorageValue(String? value) => switch (value) {
    'safe_cleanup' => CleanupPreset.safeCleanup,
    'ai_artifacts' => CleanupPreset.aiArtifacts,
    'all_rules' => CleanupPreset.allRules,
    _ => null,
  };

  /// Returns the rule IDs that this preset enables from [allRules].
  Set<String> ruleIds(List<CleanupRule> allRules) => switch (this) {
    CleanupPreset.safeCleanup => const {'oaicite_content_reference'},
    CleanupPreset.aiArtifacts => allRules
        .where((r) => r.category == CleanupRuleCategory.aiArtifact)
        .map((r) => r.id)
        .toSet(),
    CleanupPreset.allRules => allRules.map((r) => r.id).toSet(),
  };
}
