class CleanupRule {
  const CleanupRule({
    required this.id,
    required this.label,
    required this.description,
    required this.pattern,
    required this.replacement,
    required this.enabledByDefault,
  });

  final String id;
  final String label;
  final String description;
  final RegExp pattern;
  final String replacement;
  final bool enabledByDefault;
}
