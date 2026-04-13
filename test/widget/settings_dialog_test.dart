import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaultwash/app/theme/app_theme.dart';
import 'package:vaultwash/features/settings/infrastructure/settings_local_data_source.dart';
import 'package:vaultwash/features/settings/presentation/settings_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('reflects persisted settings and cleanup rule toggles', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'settings.create_backups': true,
      'settings.exclude_obsidian': true,
      'settings.exclude_hidden_folders': false,
      'settings.enabled_rule_ids': <String>[
        'oaicite_content_reference',
        'oaicite_standalone',
      ],
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: const Scaffold(body: SettingsDialog()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // ── Static structure ────────────────────────────────────────────────────
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Exclude .obsidian/'), findsOneWidget);
    expect(find.text('Exclude hidden folders'), findsOneWidget);
    expect(find.text('Cleanup history'), findsOneWidget);

    // ── Rule labels visible ─────────────────────────────────────────────────
    expect(
      find.text('Remove oaicite contentReference artifacts'),
      findsOneWidget,
    );
    expect(find.text('Remove standalone oaicite references'), findsOneWidget);
    expect(find.text('Remove AI source citation markers'), findsOneWidget);

    // ── Switches: backups on, obsidian on, hidden off ───────────────────────
    final switches = tester
        .widgetList<SwitchListTile>(find.byType(SwitchListTile))
        .toList();
    expect(switches.length, 3);
    expect(switches[0].value, isTrue);  // create backups
    expect(switches[1].value, isTrue);  // exclude obsidian
    expect(switches[2].value, isFalse); // exclude hidden folders

    // ── Checkboxes: first two enabled, third disabled ───────────────────────
    final checkboxes = tester
        .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
        .toList();
    expect(checkboxes.length, 3);
    expect(checkboxes[0].value, isTrue);  // oaicite_content_reference
    expect(checkboxes[1].value, isTrue);  // oaicite_standalone
    expect(checkboxes[2].value, isFalse); // ai_source_citation
  });
}
