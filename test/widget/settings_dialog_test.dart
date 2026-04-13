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
      'settings.enabled_rule_ids': <String>['oaicite_content_reference'],
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

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Exclude .obsidian/'), findsOneWidget);
    expect(find.text('Exclude hidden folders'), findsOneWidget);
    expect(
      find.text('Remove broken oaicite contentReference artifacts'),
      findsOneWidget,
    );

    final switches = tester
        .widgetList<SwitchListTile>(find.byType(SwitchListTile))
        .toList();
    expect(switches[0].value, isTrue);
    expect(switches[1].value, isTrue);
    expect(switches[2].value, isFalse);

    final ruleTile = tester.widget<CheckboxListTile>(
      find.byType(CheckboxListTile),
    );
    expect(ruleTile.value, isTrue);
  });
}
