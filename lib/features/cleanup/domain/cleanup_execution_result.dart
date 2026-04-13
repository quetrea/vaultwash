enum CleanupFileStatus { success, failure, skipped }

class CleanupFileExecution {
  const CleanupFileExecution({
    required this.absolutePath,
    required this.relativePath,
    required this.status,
    required this.message,
    this.backupCreated = false,
  });

  final String absolutePath;
  final String relativePath;
  final CleanupFileStatus status;
  final String message;
  final bool backupCreated;
}

class CleanupExecutionResult {
  const CleanupExecutionResult({required this.fileResults});

  final List<CleanupFileExecution> fileResults;

  int get attemptedCount => fileResults.length;

  int get successCount => fileResults
      .where((result) => result.status == CleanupFileStatus.success)
      .length;

  int get failureCount => fileResults
      .where((result) => result.status == CleanupFileStatus.failure)
      .length;

  int get skippedCount => fileResults
      .where((result) => result.status == CleanupFileStatus.skipped)
      .length;

  bool get hasFailures => failureCount > 0;
}
