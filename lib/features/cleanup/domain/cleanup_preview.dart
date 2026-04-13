class CleanupMatch {
  const CleanupMatch({
    required this.ruleId,
    required this.snippet,
    required this.start,
    required this.end,
  });

  final String ruleId;
  final String snippet;
  final int start;
  final int end;
}

class PreviewExcerpt {
  const PreviewExcerpt({
    required this.ruleId,
    required this.originalExcerpt,
    required this.cleanedExcerpt,
  });

  final String ruleId;
  final String originalExcerpt;
  final String cleanedExcerpt;
}

class CleanupPreview {
  const CleanupPreview({
    required this.originalContent,
    required this.cleanedContent,
    required this.matchCount,
    required this.matchedSnippets,
    required this.excerpts,
    required this.originalContentHash,
    required this.matches,
  });

  final String originalContent;
  final String cleanedContent;
  final int matchCount;
  final List<String> matchedSnippets;
  final List<PreviewExcerpt> excerpts;
  final String originalContentHash;
  final List<CleanupMatch> matches;

  bool get hasChanges => matchCount > 0 && originalContent != cleanedContent;
}
