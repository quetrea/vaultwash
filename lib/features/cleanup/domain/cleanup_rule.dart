import 'package:vaultwash/features/cleanup/domain/cleanup_rule_category.dart';

class CleanupRule {
  const CleanupRule({
    required this.id,
    required this.label,
    required this.description,
    required this.pattern,
    required this.replacement,
    required this.enabledByDefault,
    this.category = CleanupRuleCategory.aiArtifact,
  });

  final String id;
  final String label;
  final String description;
  final RegExp pattern;
  final String replacement;
  final bool enabledByDefault;
  final CleanupRuleCategory category;
}
