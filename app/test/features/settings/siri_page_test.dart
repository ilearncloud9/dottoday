import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/intents/siri_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import 'settings_harness.dart';

// Settings › Siri & Shortcuts (docs/09 M14.3, D3): listed only where Siri
// runs (iPhone), the five phrases, how to ask, and Open Shortcuts.

const _phrases = [
  'Add a task in Dottoday',
  "What's next in Dottoday",
  'Mark my task done in Dottoday',
  'Give my task 15 more minutes in Dottoday',
  'Start focus in Dottoday',
];

void main() {
  for (final siri in [true, false]) {
    testWidgets('the row is ${siri ? 'listed' : 'hidden'}', (tester) async {
      await pumpSettings(
        tester,
        overrides: [siriAvailableProvider.overrideWithValue(siri)],
      );
      expect(
        find.text('Siri & Shortcuts'),
        siri ? findsOneWidget : findsNothing,
      );
    });
  }

  testWidgets('the row opens the page', (tester) async {
    await pumpSettings(
      tester,
      overrides: [siriAvailableProvider.overrideWithValue(true)],
    );
    await tester.tap(find.text('Siri & Shortcuts'));
    await tester.pumpAndSettle();
    expect(find.text('What you can say'.toUpperCase()), findsOneWidget);
  });

  testWidgets('the page: five phrases, how to ask, Open Shortcuts', (
    tester,
  ) async {
    final h = await pumpSettings(
      tester,
      location: AppRoutes.settingsPage(SettingsPage.siri),
      overrides: [siriAvailableProvider.overrideWithValue(true)],
    );
    for (final p in _phrases) {
      expect(find.text(p), findsOneWidget, reason: p);
    }
    expect(find.textContaining('hold the side button'), findsOneWidget);
    await tester.tap(find.text('Open Shortcuts'));
    await tester.pumpAndSettle();
    expect(h.links.opened, [Uri.parse('shortcuts://')]);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('meets a11y guidelines (${mode.name})', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSettings(
        tester,
        mode: mode,
        location: AppRoutes.settingsPage(SettingsPage.siri),
        overrides: [siriAvailableProvider.overrideWithValue(true)],
      );
      await expectA11yGuidelines(tester);
      handle.dispose();
    });
  }
}
