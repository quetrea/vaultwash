import 'package:vaultwash/features/scan/domain/scan_failure.dart';
import 'package:vaultwash/features/scan/domain/scan_file_result.dart';
import 'package:vaultwash/features/scan/domain/scan_summary.dart';

class ScanResult {
  const ScanResult({
    required this.summary,
    required this.affectedFiles,
    required this.failures,
  });

  final ScanSummary summary;
  final List<ScanFileResult> affectedFiles;
  final List<ScanFailure> failures;
}
