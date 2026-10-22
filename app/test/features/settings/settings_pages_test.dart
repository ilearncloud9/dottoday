import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/data/search/recent_searches.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/account_fakes.dart';
import 'settings_harness.dart';

// Settings sub-pages (docs/09 M3f.7): Account, Calendars, Export, Help,
// Privacy, About.

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text(text).first);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('each row opens its page; ‹ comes back', (tester) async {
    await pumpSettings(tester);
    for (final (row, heading) in [
      ('Calendars', 'Calendars'),
      ('Export', 'Export'),
      ('Help', 'Help'),
      ('Privacy', 'Privacy'),
      ('About Dottoday', 'About Dottoday'),
      ('Kody · on this device', 'Account'),
    ]) {
      await _tap(tester, row);
      expect(find.text(heading), findsOneWidget, reason: row);
      await tester.tap(find.byTooltip('Back to Settings'));
      await tester.pumpAndSettle();
      expect(find.text('DAY SHAPE'), findsOneWidget, reason: row);
    }
  });

  group('Account', () {
    testWidgets('signed out: name, and sign-in off until sync', (tester) async {
      final h = await pumpSettings(tester, location: '/settings/account');
      expect(find.text('Continue with Apple'), findsOneWidget);
      final apple = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Continue with Apple'),
      );
      expect(apple.onPressed, isNull);
      expect(find.textContaining('arrives with sync'), findsOneWidget);
      await _tap(tester, 'Name');
      await tester.enterText(find.byType(TextField), '  Ada ');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect((await storedProfile(h)).displayName, 'Ada');
      expect(find.text('Ada'), findsOneWidget);
    });

    testWidgets('signed in: Delete needs the typed word', (tester) async {
      final service = FakeAccountService(
        account: const SignedIn(
          email: 'kody@example.com',
          method: SignInMethod.email,
        ),
      );
      await pumpSettings(
        tester,
        location: '/settings/account',
        overrides: [accountServiceProvider.overrideWithValue(service)],
      );
      expect(find.text('Signed in as kody@example.com'), findsOneWidget);
      await _tap(tester, 'Delete account');
      Finder confirm() => find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Delete account'),
      );
      expect(tester.widget<FilledButton>(confirm()).onPressed, isNull);
      await tester.enterText(find.byType(TextField), 'DELETE');
      await tester.pump();
      await tester.tap(confirm());
      await tester.pumpAndSettle();
      expect(service.calls, ['delete']);
      await _tap(tester, 'Sign out');
      expect(service.calls, ['delete', 'signOut']);
    });
  });

  testWidgets('Calendars: moving events when shifting is a real setting', (
    tester,
  ) async {
    final h = await pumpSettings(tester, location: '/settings/calendars');
    expect(find.text('No calendars connected yet'), findsOneWidget);
    await _tap(tester, 'Move calendar events too');
    expect((await storedSettings(h)).includeCalendarInShift, isTrue);
  });

  testWidgets('Privacy: Clear recent searches', (tester) async {
    final h = await pumpSettings(
      tester,
      location: '/settings/privacy',
      recentSearches: ['dentist'],
    );
    await _tap(tester, 'Clear recent searches');
    expect(find.text('Recent searches cleared'), findsOneWidget);
    expect(h.container.read(recentSearchesProvider).value, isEmpty);
  });

  testWidgets('Help opens an answer; About opens the licences', (tester) async {
    await pumpSettings(tester, location: '/settings/help');
    await _tap(tester, 'Can I add many tasks at once?');
    expect(find.textContaining('each line becomes a task'), findsOneWidget);
    await pumpSettings(tester, location: '/settings/about');
    expect(find.text('0.1.0 (1)'), findsOneWidget);
    await _tap(tester, 'Open-source licences');
    expect(find.byType(LicensePage), findsOneWidget);
  });

  for (final page in [
    'account',
    'calendars',
    'export',
    'help',
    'privacy',
    'about',
  ]) {
    testWidgets('$page meets a11y guidelines (R-12)', (tester) async {
      await pumpSettings(tester, location: '/settings/$page');
      await expectA11yGuidelines(tester);
    });
  }
}
