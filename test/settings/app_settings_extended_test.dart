import 'package:flutter_test/flutter_test.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_preset.dart';
import 'package:vaultwash/features/settings/domain/app_settings.dart';

void main() {
  // ── excludedFolderNames ───────────────────────────────────────────────────

  group('AppSettings.excludedFolderNames', () {
    test('defaults to empty list', () {
      const settings = AppSettings();
      expect(settings.excludedFolderNames, isEmpty);
    });

    test('copyWith preserves unmodified fields', () {
      const settings = AppSettings(
        excludedFolderNames: ['archive', 'old'],
        createBackupsBeforeWrite: false,
      );
      final copy = settings.copyWith(excludeObsidian: false);
      expect(copy.excludedFolderNames, ['archive', 'old']);
      expect(copy.createBackupsBeforeWrite, isFalse);
    });

    test('copyWith replaces excludedFolderNames', () {
      const settings = AppSettings(excludedFolderNames: ['archive']);
      final copy = settings.copyWith(excludedFolderNames: ['archive', 'temp']);
      expect(copy.excludedFolderNames, ['archive', 'temp']);
    });

    test('copyWith can clear to empty list', () {
      const settings = AppSettings(excludedFolderNames: ['archive']);
      final copy = settings.copyWith(excludedFolderNames: []);
      expect(copy.excludedFolderNames, isEmpty);
    });
  });

  // ── activePreset ──────────────────────────────────────────────────────────

  group('AppSettings.activePreset', () {
    test('defaults to null', () {
      const settings = AppSettings();
      expect(settings.activePreset, isNull);
    });

    test('copyWith sets activePreset', () {
      const settings = AppSettings();
      final copy = settings.copyWith(activePreset: CleanupPreset.aiArtifacts);
      expect(copy.activePreset, CleanupPreset.aiArtifacts);
    });

    test('clearActivePreset resets to null', () {
      const settings = AppSettings(activePreset: CleanupPreset.allRules);
      final copy = settings.copyWith(clearActivePreset: true);
      expect(copy.activePreset, isNull);
    });

    test('clearActivePreset ignores any provided activePreset value', () {
      const settings = AppSettings(activePreset: CleanupPreset.safeCleanup);
      final copy = settings.copyWith(
        activePreset: CleanupPreset.allRules,
        clearActivePreset: true,
      );
      expect(copy.activePreset, isNull);
    });
  });

  // ── default enabledRuleIds ────────────────────────────────────────────────

  group('AppSettings default enabledRuleIds', () {
    test('includes oaicite_content_reference by default', () {
      const settings = AppSettings();
      expect(
        settings.enabledRuleIds,
        contains('oaicite_content_reference'),
      );
    });

    test('includes oaicite_standalone by default', () {
      const settings = AppSettings();
      expect(settings.enabledRuleIds, contains('oaicite_standalone'));
    });

    test('does not include ai_source_citation by default', () {
      const settings = AppSettings();
      expect(settings.enabledRuleIds, isNot(contains('ai_source_citation')));
    });
  });
}
