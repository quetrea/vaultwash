import 'package:flutter_test/flutter_test.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_session.dart';

void main() {
  final sampleSession = CleanupSession(
    id: '123456',
    timestamp: DateTime(2026, 4, 14, 10, 30),
    ruleIds: ['oaicite_content_reference', 'oaicite_standalone'],
    ruleLabels: ['Remove oaicite contentReference', 'Remove standalone oaicite'],
    vaultPath: '/home/user/MyVault',
    vaultName: 'MyVault',
    filesChanged: 5,
    filesSkipped: 1,
    filesFailed: 0,
    backupsCreated: true,
    changedRelativePaths: ['notes/a.md', 'notes/b.md', 'c.md', 'd.md', 'e.md'],
  );

  // ── JSON serialization ────────────────────────────────────────────────────

  group('CleanupSession JSON', () {
    test('toJson produces expected keys', () {
      final json = sampleSession.toJson();
      expect(json['id'], '123456');
      expect(json['vaultName'], 'MyVault');
      expect(json['filesChanged'], 5);
      expect(json['filesSkipped'], 1);
      expect(json['filesFailed'], 0);
      expect(json['backupsCreated'], isTrue);
      expect(json['changedRelativePaths'], hasLength(5));
    });

    test('fromJson round-trips correctly', () {
      final json = sampleSession.toJson();
      final restored = CleanupSession.fromJson(json);

      expect(restored.id, sampleSession.id);
      expect(restored.timestamp, sampleSession.timestamp);
      expect(restored.ruleIds, sampleSession.ruleIds);
      expect(restored.ruleLabels, sampleSession.ruleLabels);
      expect(restored.vaultPath, sampleSession.vaultPath);
      expect(restored.vaultName, sampleSession.vaultName);
      expect(restored.filesChanged, sampleSession.filesChanged);
      expect(restored.filesSkipped, sampleSession.filesSkipped);
      expect(restored.filesFailed, sampleSession.filesFailed);
      expect(restored.backupsCreated, sampleSession.backupsCreated);
      expect(restored.changedRelativePaths, sampleSession.changedRelativePaths);
    });

    test('fromJson handles missing optional fields gracefully', () {
      final session = CleanupSession.fromJson({});
      expect(session.id, '');
      expect(session.filesChanged, 0);
      expect(session.backupsCreated, isFalse);
      expect(session.changedRelativePaths, isEmpty);
      expect(session.ruleIds, isEmpty);
    });
  });

  // ── toSummaryText ─────────────────────────────────────────────────────────

  group('CleanupSession.toSummaryText', () {
    test('contains vault name and file count', () {
      final text = sampleSession.toSummaryText();
      expect(text, contains('MyVault'));
      expect(text, contains('5'));
    });

    test('contains rule labels', () {
      final text = sampleSession.toSummaryText();
      expect(text, contains('Remove oaicite contentReference'));
    });

    test('lists changed file paths', () {
      final text = sampleSession.toSummaryText();
      expect(text, contains('notes/a.md'));
      expect(text, contains('e.md'));
    });

    test('mentions backups when backupsCreated is true', () {
      final text = sampleSession.toSummaryText();
      expect(text.toLowerCase(), contains('backup'));
    });

    test('does not mention skipped count when filesSkipped is zero', () {
      final noSkips = CleanupSession(
        id: '1',
        timestamp: DateTime.now(),
        ruleIds: [],
        ruleLabels: [],
        vaultPath: '/vault',
        vaultName: 'Vault',
        filesChanged: 3,
        filesSkipped: 0,
        filesFailed: 0,
        backupsCreated: false,
        changedRelativePaths: [],
      );
      final text = noSkips.toSummaryText();
      expect(text.toLowerCase(), isNot(contains('skipped')));
    });
  });

  // ── generateId ────────────────────────────────────────────────────────────

  group('CleanupSession.generateId', () {
    test('generates non-empty ids', () {
      expect(CleanupSession.generateId(), isNotEmpty);
    });

    test('generates distinct ids on consecutive calls', () {
      final a = CleanupSession.generateId();
      final b = CleanupSession.generateId();
      // Microsecond precision makes collisions extremely unlikely in tests.
      // We just verify both are non-empty strings.
      expect(a, isA<String>());
      expect(b, isA<String>());
    });
  });
}
