import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultwash/core/utils/file_hash.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_preview.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_rule.dart';

final cleanupEngineProvider = Provider<CleanupEngine>(
  (ref) => const CleanupEngine(),
);

class CleanupEngine {
  const CleanupEngine();

  CleanupPreview generatePreview(
    String originalContent,
    List<CleanupRule> enabledRules,
  ) {
    var workingContent = originalContent;
    final matches = <CleanupMatch>[];
    final excerpts = <PreviewExcerpt>[];
    final snippets = LinkedHashSet<String>();

    for (final rule in enabledRules) {
      final ruleMatches = rule.pattern.allMatches(workingContent).toList();
      if (ruleMatches.isEmpty) {
        continue;
      }

      for (final match in ruleMatches) {
        final snippet = _normalizeSnippet(match.group(0) ?? '');
        snippets.add(snippet);
        matches.add(
          CleanupMatch(
            ruleId: rule.id,
            snippet: snippet,
            start: match.start,
            end: match.end,
          ),
        );
        excerpts.add(
          _buildExcerpt(
            source: workingContent,
            rule: rule,
            start: match.start,
            end: match.end,
          ),
        );
      }

      workingContent = workingContent.replaceAll(
        rule.pattern,
        rule.replacement,
      );
    }

    return CleanupPreview(
      originalContent: originalContent,
      cleanedContent: workingContent,
      matchCount: matches.length,
      matchedSnippets: snippets.toList(),
      excerpts: excerpts.take(12).toList(),
      originalContentHash: hashContent(originalContent),
      matches: matches,
    );
  }

  PreviewExcerpt _buildExcerpt({
    required String source,
    required CleanupRule rule,
    required int start,
    required int end,
  }) {
    const contextWindow = 120;
    final excerptStart = math.max(0, start - contextWindow);
    final excerptEnd = math.min(source.length, end + contextWindow);
    final excerpt = source.substring(excerptStart, excerptEnd);
    final cleanedExcerpt = excerpt.replaceAll(rule.pattern, rule.replacement);

    return PreviewExcerpt(
      ruleId: rule.id,
      originalExcerpt: _clipContext(excerpt),
      cleanedExcerpt: _clipContext(
        cleanedExcerpt.trim().isEmpty ? '[artifact removed]' : cleanedExcerpt,
      ),
    );
  }

  String _normalizeSnippet(String snippet) {
    final compact = snippet.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.length <= 160) {
      return compact;
    }

    return '${compact.substring(0, 157)}...';
  }

  String _clipContext(String input) {
    final trimmed = input.trim();
    return trimmed.isEmpty ? '[empty]' : trimmed;
  }
}
