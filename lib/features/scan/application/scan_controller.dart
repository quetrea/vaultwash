import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultwash/features/cleanup/application/cleanup_history_controller.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_execution_result.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_session.dart';
import 'package:vaultwash/features/cleanup/infrastructure/cleanup_writer.dart';
import 'package:vaultwash/features/cleanup/infrastructure/default_cleanup_rules.dart';
import 'package:vaultwash/features/scan/domain/scan_failure.dart';
import 'package:vaultwash/features/scan/domain/scan_file_result.dart';
import 'package:vaultwash/features/scan/domain/scan_request.dart';
import 'package:vaultwash/features/scan/domain/scan_summary.dart';
import 'package:vaultwash/features/scan/infrastructure/vault_scanner.dart';
import 'package:vaultwash/features/settings/application/app_settings_controller.dart';
import 'package:vaultwash/features/vault/application/vault_controller.dart';

final scanControllerProvider =
    AsyncNotifierProvider<ScanController, ScanWorkspaceState>(
      ScanController.new,
    );

const _unset = Object();

class ScanWorkspaceState {
  const ScanWorkspaceState({
    this.summary,
    this.affectedFiles = const [],
    this.failures = const [],
    this.selectedPaths = const {},
    this.focusedRelativePath,
    this.isScanning = false,
    this.isCleaning = false,
    this.lastExecutionResult,
    this.lastSession,
    this.lastScannedAt,
    this.statusMessage,
    this.errorMessage,
  });

  final ScanSummary? summary;
  final List<ScanFileResult> affectedFiles;
  final List<ScanFailure> failures;
  final Set<String> selectedPaths;
  final String? focusedRelativePath;
  final bool isScanning;
  final bool isCleaning;
  final CleanupExecutionResult? lastExecutionResult;

  /// The most recent cleanup session recorded to history.
  final CleanupSession? lastSession;

  final DateTime? lastScannedAt;
  final String? statusMessage;
  final String? errorMessage;

  ScanWorkspaceState copyWith({
    ScanSummary? summary,
    List<ScanFileResult>? affectedFiles,
    List<ScanFailure>? failures,
    Set<String>? selectedPaths,
    String? focusedRelativePath,
    bool clearFocusedPath = false,
    bool? isScanning,
    bool? isCleaning,
    CleanupExecutionResult? lastExecutionResult,
    bool clearExecutionResult = false,
    CleanupSession? lastSession,
    bool clearLastSession = false,
    DateTime? lastScannedAt,
    Object? statusMessage = _unset,
    Object? errorMessage = _unset,
  }) {
    return ScanWorkspaceState(
      summary: summary ?? this.summary,
      affectedFiles: affectedFiles ?? this.affectedFiles,
      failures: failures ?? this.failures,
      selectedPaths: selectedPaths ?? this.selectedPaths,
      focusedRelativePath: clearFocusedPath
          ? null
          : (focusedRelativePath ?? this.focusedRelativePath),
      isScanning: isScanning ?? this.isScanning,
      isCleaning: isCleaning ?? this.isCleaning,
      lastExecutionResult: clearExecutionResult
          ? null
          : (lastExecutionResult ?? this.lastExecutionResult),
      lastSession:
          clearLastSession ? null : (lastSession ?? this.lastSession),
      lastScannedAt: lastScannedAt ?? this.lastScannedAt,
      statusMessage: identical(statusMessage, _unset)
          ? this.statusMessage
          : statusMessage as String?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  ScanFileResult? get focusedFile {
    if (focusedRelativePath == null) {
      return affectedFiles.isEmpty ? null : affectedFiles.first;
    }

    for (final file in affectedFiles) {
      if (file.relativePath == focusedRelativePath) {
        return file;
      }
    }

    return affectedFiles.isEmpty ? null : affectedFiles.first;
  }
}

class ScanController extends AsyncNotifier<ScanWorkspaceState> {
  @override
  Future<ScanWorkspaceState> build() async {
    return const ScanWorkspaceState(
      statusMessage: 'Select an Obsidian vault, then run a scan.',
    );
  }

  Future<void> scanVault({bool preserveExecutionResult = true}) async {
    final current = state.asData?.value ?? const ScanWorkspaceState();
    final vault = await ref.read(vaultControllerProvider.future);

    if (vault == null) {
      state = AsyncData(
        current.copyWith(
          errorMessage: 'Choose a valid vault before starting a scan.',
          statusMessage: 'No vault selected.',
          isScanning: false,
        ),
      );
      return;
    }

    final settings = ref.read(appSettingsControllerProvider);
    final rules = ref.read(enabledCleanupRulesProvider);

    state = AsyncData(
      current.copyWith(
        isScanning: true,
        errorMessage: null,
        statusMessage: 'Scanning markdown files across the vault…',
        clearExecutionResult: !preserveExecutionResult,
      ),
    );

    final result = await ref
        .read(vaultScannerProvider)
        .scan(
          ScanRequest(
            vault: vault,
            enabledRules: rules,
            excludeObsidian: settings.excludeObsidian,
            excludeHiddenFolders: settings.excludeHiddenFolders,
            excludedFolderNames: settings.excludedFolderNames,
          ),
        );

    state = AsyncData(
      current.copyWith(
        summary: result.summary,
        affectedFiles: result.affectedFiles,
        failures: result.failures,
        selectedPaths: const {},
        focusedRelativePath: result.affectedFiles.isEmpty
            ? null
            : result.affectedFiles.first.relativePath,
        isScanning: false,
        lastScannedAt: DateTime.now(),
        statusMessage: result.summary.filesWithMatches == 0
            ? 'No broken citation artifacts were found in this scan.'
            : 'Scan complete. Review affected files before cleaning anything.',
        errorMessage: null,
      ),
    );
  }

  void focusFile(String relativePath) {
    final current = state.asData?.value;
    if (current == null) {
      return;
    }

    state = AsyncData(
      current.copyWith(focusedRelativePath: relativePath, errorMessage: null),
    );
  }

  void toggleSelection(String relativePath, bool selected) {
    final current = state.asData?.value;
    if (current == null) {
      return;
    }

    final nextSelected = <String>{...current.selectedPaths};
    if (selected) {
      nextSelected.add(relativePath);
    } else {
      nextSelected.remove(relativePath);
    }

    state = AsyncData(current.copyWith(selectedPaths: nextSelected));
  }

  List<ScanFileResult> selectedFiles() {
    final current = state.asData?.value ?? const ScanWorkspaceState();

    return current.affectedFiles
        .where((file) => current.selectedPaths.contains(file.relativePath))
        .toList();
  }

  List<ScanFileResult> allAffectedFiles() {
    final current = state.asData?.value ?? const ScanWorkspaceState();
    return current.affectedFiles;
  }

  Future<CleanupExecutionResult?> cleanFiles(List<ScanFileResult> files) async {
    if (files.isEmpty) {
      return null;
    }

    final current = state.asData?.value ?? const ScanWorkspaceState();
    final settings = ref.read(appSettingsControllerProvider);
    final rules = ref.read(enabledCleanupRulesProvider);
    final vault = await ref.read(vaultControllerProvider.future);

    state = AsyncData(
      current.copyWith(
        isCleaning: true,
        errorMessage: null,
        statusMessage: 'Applying approved cleanup to selected files…',
      ),
    );

    final result = await ref
        .read(cleanupWriterProvider)
        .execute(
          files: files,
          createBackups: settings.createBackupsBeforeWrite,
        );

    // Record the cleanup session in history.
    if (vault != null && result.successCount > 0) {
      final session = CleanupSession(
        id: CleanupSession.generateId(),
        timestamp: DateTime.now(),
        ruleIds: rules.map((r) => r.id).toList(),
        ruleLabels: rules.map((r) => r.label).toList(),
        vaultPath: vault.absolutePath,
        vaultName: vault.name,
        filesChanged: result.successCount,
        filesSkipped: result.skippedCount,
        filesFailed: result.failureCount,
        backupsCreated: settings.createBackupsBeforeWrite,
        changedRelativePaths: result.fileResults
            .where(
              (f) => f.status == CleanupFileStatus.success,
            )
            .map((f) => f.relativePath)
            .toList(),
      );

      await ref.read(cleanupHistoryControllerProvider.notifier).record(session);

      final updated = (state.asData?.value ?? current).copyWith(
        isCleaning: false,
        lastExecutionResult: result,
        lastSession: session,
        statusMessage: 'Cleanup finished. Refreshing the vault view…',
        errorMessage: null,
      );
      state = AsyncData(updated);
    } else {
      final updated = (state.asData?.value ?? current).copyWith(
        isCleaning: false,
        lastExecutionResult: result,
        statusMessage: 'Cleanup finished. Refreshing the vault view…',
        errorMessage: null,
      );
      state = AsyncData(updated);
    }

    await scanVault();

    final rescanned = state.asData?.value ?? current;
    state = AsyncData(
      rescanned.copyWith(
        lastExecutionResult: result,
        statusMessage:
            'Cleanup finished. Review remaining files or run another scan.',
      ),
    );

    return result;
  }
}
