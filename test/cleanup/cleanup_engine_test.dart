import 'package:flutter_test/flutter_test.dart';
import 'package:vaultwash/features/cleanup/application/cleanup_engine.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_rule.dart';
import 'package:vaultwash/features/cleanup/infrastructure/cleanup_patterns.dart';

void main() {
  const engine = CleanupEngine();
  final oaiciteRule = CleanupRule(
    id: 'oaicite_content_reference',
    label: 'Remove broken oaicite contentReference artifacts',
    description:
        'Removes patterns such as :contentReference[oaicite:...]{...} from markdown files.',
    pattern: CleanupPatterns.oaiciteContentReference,
    replacement: '',
    enabledByDefault: true,
  );

  test('removes single and repeated oaicite artifacts', () {
    const original =
        'Before :contentReference[oaicite:10]{index=10} middle :contentReference[oaicite:11]{index=11} after';

    final preview = engine.generatePreview(original, [oaiciteRule]);

    expect(preview.matchCount, 2);
    expect(
      preview.cleanedContent,
      isNot(contains(':contentReference[oaicite:')),
    );
    expect(preview.matchedSnippets, isNotEmpty);
  });

  test('leaves unaffected markdown unchanged', () {
    const original = '# Notes\n\nThis file is already clean.';

    final preview = engine.generatePreview(original, [oaiciteRule]);

    expect(preview.matchCount, 0);
    expect(preview.cleanedContent, original);
    expect(preview.hasChanges, isFalse);
  });

  test('applies multiple rules deterministically in order', () {
    final ruleOne = CleanupRule(
      id: 'rule_one',
      label: 'Alpha to beta',
      description: 'Transforms alpha to beta.',
      pattern: RegExp('alpha'),
      replacement: 'beta',
      enabledByDefault: true,
    );
    final ruleTwo = CleanupRule(
      id: 'rule_two',
      label: 'Beta to gamma',
      description: 'Transforms beta to gamma.',
      pattern: RegExp('beta'),
      replacement: 'gamma',
      enabledByDefault: true,
    );

    final preview = engine.generatePreview('alpha', [ruleOne, ruleTwo]);

    expect(preview.cleanedContent, 'gamma');
    expect(preview.matchCount, 2);
  });

  test('computes different hashes for different content', () {
    final first = engine.generatePreview('first', [oaiciteRule]);
    final second = engine.generatePreview('second', [oaiciteRule]);

    expect(first.originalContentHash, isNot(second.originalContentHash));
  });
}
