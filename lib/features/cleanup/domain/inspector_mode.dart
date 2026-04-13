import 'dart:math';

/// Inspection modes available in the review pane.
enum InspectorMode {
  /// Side-by-side before/after view of each excerpt window.
  excerpts,

  /// Compact inline diff highlighting exactly what changes.
  changes;

  String get storageValue => name;

  String get label => switch (this) {
    InspectorMode.excerpts => 'Excerpts',
    InspectorMode.changes => 'Changes',
  };

  static InspectorMode fromStorageValue(String? value) {
    return InspectorMode.values.firstWhere(
      (mode) => mode.storageValue == value,
      orElse: () => InspectorMode.excerpts,
    );
  }
}

/// Decomposed inline diff between two strings.
///
/// Finds the longest common prefix and suffix, reducing the changed
/// region to the smallest possible middle segment.  This works well
/// for VaultWash excerpt windows where only the matched artifact text
/// changes and the surrounding context is identical.
class InlineDiff {
  const InlineDiff({
    required this.prefix,
    required this.removed,
    required this.added,
    required this.suffix,
  });

  /// Text before any change (shared by both sides).
  final String prefix;

  /// Text only in the original (to be removed/highlighted as deleted).
  final String removed;

  /// Text only in the cleaned result (to be added/highlighted as inserted).
  final String added;

  /// Text after the change (shared by both sides).
  final String suffix;

  bool get hasChange => removed.isNotEmpty || added.isNotEmpty;

  /// Computes the inline diff between [original] and [cleaned].
  factory InlineDiff.compute(String original, String cleaned) {
    if (original == cleaned) {
      return InlineDiff(prefix: original, removed: '', added: '', suffix: '');
    }

    final minLen = min(original.length, cleaned.length);

    // Longest common prefix
    int prefixLen = 0;
    while (prefixLen < minLen &&
        original.codeUnitAt(prefixLen) == cleaned.codeUnitAt(prefixLen)) {
      prefixLen++;
    }

    // Longest common suffix (not overlapping the prefix region)
    int suffixLen = 0;
    final origTail = original.length - prefixLen;
    final cleanTail = cleaned.length - prefixLen;
    final maxSuffix = min(origTail, cleanTail);
    while (suffixLen < maxSuffix &&
        original.codeUnitAt(original.length - 1 - suffixLen) ==
            cleaned.codeUnitAt(cleaned.length - 1 - suffixLen)) {
      suffixLen++;
    }

    return InlineDiff(
      prefix: original.substring(0, prefixLen),
      removed: original.substring(prefixLen, original.length - suffixLen),
      added: cleaned.substring(prefixLen, cleaned.length - suffixLen),
      suffix: suffixLen > 0
          ? original.substring(original.length - suffixLen)
          : '',
    );
  }
}
