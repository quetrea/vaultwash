abstract final class CleanupPatterns {
  /// Matches full `:contentReference[oaicite:N]{...}` artifacts inserted by
  /// AI writing assistants during document generation.
  static final oaiciteContentReference = RegExp(
    r':contentReference\[oaicite:[^\]]+\]\{[^}]*\}',
  );

  /// Matches standalone `[oaicite:N]` or `[oaicite:N]{index=N}` fragments that
  /// appear without a `:contentReference` prefix. These are leftover oaicite
  /// markers from partially-stripped or malformed AI output.
  static final oaiciteStandalone = RegExp(
    r'\[oaicite:\d+\](?:\{[^}]*\})?',
  );

  /// Matches ChatGPT-style unicode citation markers such as `【1†source】`.
  /// These are inserted by ChatGPT when citing uploaded-document sources.
  static final aiSourceCitation = RegExp(
    r'【\d+†[^】]*】',
  );
}
