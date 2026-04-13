class CleanupSession {
  const CleanupSession({
    required this.id,
    required this.timestamp,
    required this.ruleIds,
    required this.ruleLabels,
    required this.vaultPath,
    required this.vaultName,
    required this.filesChanged,
    required this.filesSkipped,
    required this.filesFailed,
    required this.backupsCreated,
    required this.changedRelativePaths,
  });

  final String id;
  final DateTime timestamp;
  final List<String> ruleIds;
  final List<String> ruleLabels;
  final String vaultPath;
  final String vaultName;
  final int filesChanged;
  final int filesSkipped;
  final int filesFailed;
  final bool backupsCreated;

  /// Relative paths of files that were successfully cleaned in this session.
  final List<String> changedRelativePaths;

  static String generateId() =>
      DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'ruleIds': ruleIds,
    'ruleLabels': ruleLabels,
    'vaultPath': vaultPath,
    'vaultName': vaultName,
    'filesChanged': filesChanged,
    'filesSkipped': filesSkipped,
    'filesFailed': filesFailed,
    'backupsCreated': backupsCreated,
    'changedRelativePaths': changedRelativePaths,
  };

  factory CleanupSession.fromJson(Map<String, dynamic> json) {
    return CleanupSession(
      id: json['id'] as String? ?? '',
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      ruleIds:
          (json['ruleIds'] as List<dynamic>?)?.cast<String>() ?? const [],
      ruleLabels:
          (json['ruleLabels'] as List<dynamic>?)?.cast<String>() ?? const [],
      vaultPath: json['vaultPath'] as String? ?? '',
      vaultName: json['vaultName'] as String? ?? '',
      filesChanged: json['filesChanged'] as int? ?? 0,
      filesSkipped: json['filesSkipped'] as int? ?? 0,
      filesFailed: json['filesFailed'] as int? ?? 0,
      backupsCreated: json['backupsCreated'] as bool? ?? false,
      changedRelativePaths:
          (json['changedRelativePaths'] as List<dynamic>?)?.cast<String>() ??
          const [],
    );
  }

  /// Formats a plain-text / markdown summary suitable for copying to clipboard.
  String toSummaryText() {
    final lines = <String>[
      '## VaultWash Cleanup — ${_formatTimestamp(timestamp)}',
      '',
      'Vault: $vaultName',
      'Rules applied: ${ruleLabels.isEmpty ? '(none)' : ruleLabels.join(', ')}',
      'Files cleaned: $filesChanged',
      if (filesSkipped > 0) 'Files skipped: $filesSkipped',
      if (filesFailed > 0) 'Errors: $filesFailed',
      if (backupsCreated)
        'Backups: .bak files created beside each changed file.',
      if (changedRelativePaths.isNotEmpty) ...[
        '',
        'Changed files:',
        ...changedRelativePaths.map((path) => '  - $path'),
      ],
    ];
    return lines.join('\n');
  }

  static String _formatTimestamp(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$y-$mo-$d $h:$mi';
  }
}
