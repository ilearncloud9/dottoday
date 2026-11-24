import 'package:dottoday/core/l10n/generated/app_localizations.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/features/settings/settings_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import 'settings_harness.dart';

// Search settings on the Settings root (M20.7 part 1, E-Phones).

void main() {
  setUpAll(tz_data.initializeTimeZones);
  final l10n = lookupAppLocalizations(const Locale('en'));

  test('the index finds a row on its page, ignoring case', () {
    final index = settingsIndex(l10n);
    expect(searchSettings(index, 'quiet'), [
      (title: 'Quiet hours', page: SettingsPage.reminders),
    ]);
    expect(
      searchSettings(index, 'TIME FORMAT').single.page,
      SettingsPage.appearance,
    );
    expect(searchSettings(index, '  '), isEmpty);
  });

  test('every group page and the pages under them are found by title', () {
    final pages = {for (final e in settingsIndex(l10n)) e.page};
    expect(
      pages,
      SettingsPage.values.toSet().difference({SettingsPage.everything}),
    );
  });

  testWidgets('typing lists the matches; a match opens its page', (
    tester,
  ) async {
    await pumpSettings(tester);
    await tester.enterText(find.byType(EditableText), 'week');
    await tester.pumpAndSettle();
    expect(find.text('Week starts'), findsOneWidget);
    expect(find.text('Your day'), findsNothing, reason: 'groups give way');
    await tester.tap(find.text('Week starts'));
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsWidgets);
    expect(find.text('Format'), findsOneWidget);
  });

  testWidgets('no match says so; clearing brings the groups back', (
    tester,
  ) async {
    await pumpSettings(tester);
    await tester.enterText(find.byType(EditableText), 'zebra');
    await tester.pumpAndSettle();
    expect(find.text('No settings match “zebra”'), findsOneWidget);
    await expectA11yGuidelines(tester);
    await tester.enterText(find.byType(EditableText), '');
    await tester.pumpAndSettle();
    expect(find.text('Your day'), findsOneWidget);
  });

  testWidgets('Your day holds Wake Up and Wind Down, then Learn my day', (
    tester,
  ) async {
    final h = await pumpSettings(tester);
    await tester.tap(find.text('Your day'));
    await tester.pumpAndSettle();
    expect(find.text('The two ends of your day'), findsOneWidget);
    await tester.tap(find.text('Wake Up and Wind Down'));
    await tester.pumpAndSettle();
    // Tonight and the week as schedules (ED-084), not Day shape's rows.
    expect(find.text('Your week'), findsOneWidget);
    expect(find.text('Every day'), findsOneWidget);
    await tester.tap(settingsBack('Your day'));
    await tester.pumpAndSettle();
    expect(h.router.state.uri.path, '/settings/yourDay');
  });
}
