import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultwash/features/cleanup/domain/cleanup_rule.dart';
import 'package:vaultwash/features/cleanup/infrastructure/cleanup_patterns.dart';
import 'package:vaultwash/features/settings/application/app_settings_controller.dart';

final cleanupRulesProvider = Provider<List<CleanupRule>>(
  (ref) => [
    CleanupRule(
      id: 'oaicite_content_reference',
      label: 'Remove broken oaicite contentReference artifacts',
      description:
          'Removes patterns such as :contentReference[oaicite:...]{...} from markdown files.',
      pattern: CleanupPatterns.oaiciteContentReference,
      replacement: '',
      enabledByDefault: true,
    ),
  ],
);

final enabledCleanupRulesProvider = Provider<List<CleanupRule>>((ref) {
  final settings = ref.watch(appSettingsControllerProvider);
  final rules = ref.watch(cleanupRulesProvider);

  return rules
      .where((rule) => settings.enabledRuleIds.contains(rule.id))
      .toList();
});
