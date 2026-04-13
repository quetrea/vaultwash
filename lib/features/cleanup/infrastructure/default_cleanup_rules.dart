import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_rule.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_rule_category.dart';
import 'package:vaultwash/features/cleanup/infrastructure/cleanup_patterns.dart';
import 'package:vaultwash/features/settings/application/app_settings_controller.dart';

/// All cleanup rules registered in VaultWash.
///
/// Rules are applied in list order during a scan. Each rule must be:
/// - deterministic: same input always yields same output
/// - conservative: never removes content that could be intentional
/// - explainable: label and description fully describe what is cleaned
final cleanupRulesProvider = Provider<List<CleanupRule>>(
  (ref) => [
    CleanupRule(
      id: 'oaicite_content_reference',
      label: 'Remove oaicite contentReference artifacts',
      description:
          'Removes :contentReference[oaicite:...]{...} patterns left by AI '
          'writing assistants. These are never valid Markdown.',
      pattern: CleanupPatterns.oaiciteContentReference,
      replacement: '',
      enabledByDefault: true,
      category: CleanupRuleCategory.aiArtifact,
    ),
    CleanupRule(
      id: 'oaicite_standalone',
      label: 'Remove standalone oaicite references',
      description:
          'Removes leftover [oaicite:N] or [oaicite:N]{index=N} fragments '
          'that appear without a contentReference prefix.',
      pattern: CleanupPatterns.oaiciteStandalone,
      replacement: '',
      enabledByDefault: true,
      category: CleanupRuleCategory.aiArtifact,
    ),
    CleanupRule(
      id: 'ai_source_citation',
      label: 'Remove AI source citation markers',
      description:
          'Removes 【N†source】 citation markers inserted by ChatGPT when '
          'citing sources from uploaded documents.',
      pattern: CleanupPatterns.aiSourceCitation,
      replacement: '',
      enabledByDefault: false,
      category: CleanupRuleCategory.aiArtifact,
    ),
  ],
);

final enabledCleanupRulesProvider = Provider<List<CleanupRule>>((ref) {
  final settings = ref.watch(appSettingsControllerProvider);
  final rules = ref.watch(cleanupRulesProvider);

  return rules
      .where((rule) => settings.enabledRuleIds.contains(rule.id))
      .toList();
});
