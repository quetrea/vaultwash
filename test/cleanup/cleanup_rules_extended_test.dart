import 'package:flutter_test/flutter_test.dart';
import 'package:vaultwash/features/cleanup/application/cleanup_engine.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_preset.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_rule.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_rule_category.dart';
import 'package:vaultwash/features/cleanup/infrastructure/cleanup_patterns.dart';

void main() {
  const engine = CleanupEngine();

  final oaiciteRule = CleanupRule(
    id: 'oaicite_content_reference',
    label: 'Remove oaicite contentReference artifacts',
    description: 'Removes :contentReference[oaicite:...]{...} patterns.',
    pattern: CleanupPatterns.oaiciteContentReference,
    replacement: '',
    enabledByDefault: true,
    category: CleanupRuleCategory.aiArtifact,
  );

  final standaloneRule = CleanupRule(
    id: 'oaicite_standalone',
    label: 'Remove standalone oaicite references',
    description: 'Removes leftover [oaicite:N] fragments.',
    pattern: CleanupPatterns.oaiciteStandalone,
    replacement: '',
    enabledByDefault: true,
    category: CleanupRuleCategory.aiArtifact,
  );

  final aiCitationRule = CleanupRule(
    id: 'ai_source_citation',
    label: 'Remove AI source citation markers',
    description: 'Removes ChatGPT-style 【N†source】 markers.',
    pattern: CleanupPatterns.aiSourceCitation,
    replacement: '',
    enabledByDefault: false,
    category: CleanupRuleCategory.aiArtifact,
  );

  final allRules = [oaiciteRule, standaloneRule, aiCitationRule];

  // ── CleanupRuleCategory ───────────────────────────────────────────────────

  group('CleanupRuleCategory', () {
    test('aiArtifact label is human-readable', () {
      expect(CleanupRuleCategory.aiArtifact.label, 'AI artifact');
    });

    test('formatting label is human-readable', () {
      expect(CleanupRuleCategory.formatting.label, 'Formatting');
    });
  });

  // ── oaicite_standalone pattern ────────────────────────────────────────────

  group('oaicite_standalone rule', () {
    test('removes bare [oaicite:N] reference', () {
      const input = 'Some text [oaicite:0] more text.';
      final preview = engine.generatePreview(input, [standaloneRule]);
      expect(preview.matchCount, 1);
      expect(preview.cleanedContent, 'Some text  more text.');
    });

    test('removes [oaicite:N]{index=N} reference', () {
      const input = 'Before [oaicite:5]{index=5} after.';
      final preview = engine.generatePreview(input, [standaloneRule]);
      expect(preview.matchCount, 1);
      expect(preview.cleanedContent, isNot(contains('[oaicite:')));
    });

    test('does not match contentReference prefix form', () {
      // The contentReference form is handled by the other rule, not this one.
      const input = ':contentReference[oaicite:0]{index=0}';
      final preview = engine.generatePreview(input, [standaloneRule]);
      // The pattern should still match the [oaicite:0]{index=0} portion.
      expect(preview.hasChanges, isTrue);
    });

    test('leaves clean markdown unchanged', () {
      const input = '# Heading\n\nNormal paragraph with [a real link](url).';
      final preview = engine.generatePreview(input, [standaloneRule]);
      expect(preview.hasChanges, isFalse);
    });

    test('removes multiple standalone oaicite references', () {
      const input = 'A [oaicite:1] B [oaicite:2]{index=2} C [oaicite:3] D';
      final preview = engine.generatePreview(input, [standaloneRule]);
      expect(preview.matchCount, 3);
      expect(preview.cleanedContent, isNot(contains('[oaicite:')));
    });
  });

  // ── ai_source_citation pattern ────────────────────────────────────────────

  group('ai_source_citation rule', () {
    test('removes ChatGPT unicode citation marker', () {
      const input = 'The sky is blue【1†source】 and water is wet.';
      final preview = engine.generatePreview(input, [aiCitationRule]);
      expect(preview.matchCount, 1);
      expect(preview.cleanedContent, isNot(contains('【')));
    });

    test('removes multiple citation markers', () {
      const input = 'Fact one【1†doc.pdf】. Fact two【2†other source】.';
      final preview = engine.generatePreview(input, [aiCitationRule]);
      expect(preview.matchCount, 2);
    });

    test('leaves square bracket links intact', () {
      const input = 'See [Wikipedia](https://en.wikipedia.org) for details.';
      final preview = engine.generatePreview(input, [aiCitationRule]);
      expect(preview.hasChanges, isFalse);
    });
  });

  // ── Multi-rule interaction ────────────────────────────────────────────────

  group('multi-rule cleanup', () {
    test('all three rules run sequentially without interfering', () {
      const input =
          'Text :contentReference[oaicite:0]{index=0} and [oaicite:1] and 【2†src】 end.';
      final preview = engine.generatePreview(input, allRules);
      expect(preview.matchCount, 3);
      expect(preview.cleanedContent, isNot(contains('oaicite')));
      expect(preview.cleanedContent, isNot(contains('【')));
    });
  });

  // ── CleanupPreset ─────────────────────────────────────────────────────────

  group('CleanupPreset', () {
    test('safeCleanup enables only oaicite_content_reference', () {
      final ids = CleanupPreset.safeCleanup.ruleIds(allRules);
      expect(ids, equals({'oaicite_content_reference'}));
    });

    test('aiArtifacts enables all aiArtifact-category rules', () {
      final ids = CleanupPreset.aiArtifacts.ruleIds(allRules);
      expect(ids, containsAll(['oaicite_content_reference', 'oaicite_standalone', 'ai_source_citation']));
      expect(ids.length, 3);
    });

    test('allRules enables every rule in the registry', () {
      final ids = CleanupPreset.allRules.ruleIds(allRules);
      expect(ids, equals(allRules.map((r) => r.id).toSet()));
    });

    test('storageValue round-trips through fromStorageValue', () {
      for (final preset in CleanupPreset.values) {
        expect(
          CleanupPreset.fromStorageValue(preset.storageValue),
          preset,
        );
      }
    });

    test('fromStorageValue returns null for unknown value', () {
      expect(CleanupPreset.fromStorageValue('unknown_preset'), isNull);
      expect(CleanupPreset.fromStorageValue(null), isNull);
    });

    test('every preset has a non-empty label and description', () {
      for (final preset in CleanupPreset.values) {
        expect(preset.label, isNotEmpty);
        expect(preset.description, isNotEmpty);
      }
    });
  });
}
