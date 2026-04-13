class ScanFailure {
  const ScanFailure({
    required this.absolutePath,
    required this.relativePath,
    required this.message,
  });

  final String absolutePath;
  final String relativePath;
  final String message;
}
