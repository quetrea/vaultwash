class ScanSummary {
  const ScanSummary({
    required this.totalFilesScanned,
    required this.filesWithMatches,
    required this.totalMatchesFound,
    required this.failureCount,
  });

  final int totalFilesScanned;
  final int filesWithMatches;
  final int totalMatchesFound;
  final int failureCount;
}
