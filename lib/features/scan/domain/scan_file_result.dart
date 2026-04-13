import 'package:vaultwash/features/cleanup/domain/cleanup_preview.dart';

class ScanFileResult {
  const ScanFileResult({
    required this.absolutePath,
    required this.relativePath,
    required this.matchCount,
    required this.matchedSnippets,
    required this.cleanedPreviewContent,
    required this.originalContentHash,
    required this.preview,
  });

  final String absolutePath;
  final String relativePath;
  final int matchCount;
  final List<String> matchedSnippets;
  final String cleanedPreviewContent;
  final String originalContentHash;
  final CleanupPreview preview;
}
