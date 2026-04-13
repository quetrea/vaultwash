import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaultwash/app/app.dart';
import 'package:vaultwash/features/settings/infrastructure/settings_local_data_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows intentional empty state and disabled cleanup actions', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const VaultWashApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Select an Obsidian vault to begin'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Scan vault'))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Clean selected files'),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Clean all affected files'),
          )
          .onPressed,
      isNull,
    );
  });
}
