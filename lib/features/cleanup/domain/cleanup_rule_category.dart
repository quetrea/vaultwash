enum CleanupRuleCategory {
  aiArtifact,
  formatting;

  String get label => switch (this) {
    CleanupRuleCategory.aiArtifact => 'AI artifact',
    CleanupRuleCategory.formatting => 'Formatting',
  };
}
