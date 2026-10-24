import 'package:dottoday/core/env/env.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/data/release/whats_new_seen.dart';
import 'package:dottoday/data/search/recent_searches.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/account_fakes.dart';
import '../../support/sync_fakes.dart';
import 'settings_harness.dart';

// Settings sub-pages (docs/09 M3f.7): Account, Calendars, Export, Help,
// Privacy, About, What's new (M8.2).

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
      await _tap(tester, 'Sign out everywhere');
      expect(service.calls.last, 'signOutEverywhere');
      // M6.5: a copy first, if wanted.
      await _tap(tester, 'Delete account');
      await _tap(tester, 'Export my data first');
      expect(find.text('Export'), findsWidgets);
      expect(service.calls.where((c) => c == 'delete'), hasLength(1));
    });

    // M6.3: the header says how sync stands (`A-ios-settings`).
    testWidgets('the header: "Kody · synced just now" once signed in', (
      tester,
    ) async {
      final sync = FakeSyncService(
        SyncStatus(
          state: SyncState.synced,
          lastSyncedUtc: DateTime.utc(2026, 10, 21, 9),
        ),
      );
      await pumpSettings(
        tester,
        overrides: [syncServiceProvider.overrideWithValue(sync)],
      );
      expect(find.text('Kody · synced just now'), findsOneWidget);
    });

    // M6.1: email asks for the address here too, then "Check your mail".
    testWidgets('signed out with a server: email, the link, check mail', (
      tester,
    ) async {
      final service = FakeAccountService();
      addTearDown(service.restore.close);
      addTearDown(service.accounts.close);
      await pumpSettings(
        tester,
        location: '/settings/account',
        overrides: [accountServiceProvider.overrideWithValue(service)],
      );
      await _tap(tester, 'Continue with email');
      await tester.enterText(find.byType(TextField), 'not-an-address');
      await _tap(tester, 'Send me a link');
      expect(service.calls, isEmpty);
      await tester.enterText(find.byType(TextField), 'kody@example.com');
      await _tap(tester, 'Send me a link');
      expect(service.calls, ['link:kody@example.com']);
      expect(find.text('Check your mail'), findsOneWidget);
      await expectA11yGuidelines(tester);
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

  testWidgets('Calendars: travel time is off until chosen, then a length', (
    tester,
  ) async {
    final h = await pumpSettings(tester, location: '/settings/calendars');
    expect((await storedSettings(h)).suggestTravelTime, isFalse);
    await _tap(tester, 'Suggest travel time');
    expect((await storedSettings(h)).suggestTravelTime, isTrue);
    await _tap(tester, '15 min');
    await _tap(tester, '30 min');
    expect((await storedSettings(h)).travelTimeMin, 30);
    await expectA11yGuidelines(tester);
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

  testWidgets('Privacy: crash reports and the policy only when configured', (
    tester,
  ) async {
    await pumpSettings(tester, location: '/settings/privacy');
    expect(find.text('Crash reports'), findsNothing);
    expect(find.text('Read the privacy policy'), findsNothing);
    final policy = Uri.parse('https://dottoday.example/privacy.html');
    final h = await pumpSettings(
      tester,
      location: '/settings/privacy',
      env: Env(
        supabaseUrl: Uri.parse('https://example.supabase.co'),
        supabaseAnonKey: 'anon',
        sentryDsn: 'https://key@sentry.example/1',
        privacyPolicyUrl: policy,
      ),
    );
    expect(find.text('Crash reports'), findsOneWidget);
    expect(find.textContaining('Never your tasks'), findsOneWidget);
    await _tap(tester, 'Read the privacy policy');
    expect(h.links.opened, [policy]);
    await expectA11yGuidelines(tester);
  });

  // A platform without a device check (the web): the lock group says what
  // protects the tasks instead of a switch (07 Web, M5.8).
  testWidgets('Privacy: no lock switch without a device check', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    await pumpSettings(tester, location: '/settings/privacy');
    expect(find.text("Uses your computer's lock"), findsOneWidget);
    expect(find.text('Lock Dottoday'), findsNothing);
    debugDefaultTargetPlatformOverride = null;
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

  testWidgets("About › What's new opens the changelog and marks it seen", (
    tester,
  ) async {
    final h = await pumpSettings(
      tester,
      location: '/settings/about',
      whatsNewSeen: '0.0.9',
    );
    await _tap(tester, "What's new");
    expect(find.text('VERSION 0.1.0 · ON THIS DEVICE'), findsOneWidget);
    // One bullet per line of the notes (PRD F11).
    expect(find.textContaining('shift everything after it'), findsOneWidget);
    expect(find.textContaining('Send feedback from Settings'), findsOneWidget);
    expect(h.container.read(whatsNewSeenProvider).value, '0.1.0');
  });

  for (final page in [
    'account',
    'calendars',
    'export',
    'help',
    'privacy',
    'about',
    'changelog',
  ]) {
    testWidgets('$page meets a11y guidelines (R-12)', (tester) async {
      await pumpSettings(tester, location: '/settings/$page');
      await expectA11yGuidelines(tester);
    });
  }
}
