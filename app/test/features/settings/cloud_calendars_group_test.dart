import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/data/calendar/cloud_calendar_providers.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/calendar/cloud_calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/calendar_fakes.dart';
import '../../support/cloud_calendar_fakes.dart';
import 'settings_harness.dart';

// Settings › Calendars › Google and Microsoft (docs/09 M7.4, R-02, R-13):
// sign in first, connect through the provider's page, per-calendar
// switches, Disconnect after a confirm, Reconnect when revoked.

const _page = '/settings/calendars';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  List<Override> cloud(FakeCloudCalendars fake, {bool signedIn = true}) => [
    cloudCalendarsProvider.overrideWithValue(fake),
    accountProvider.overrideWith(
      (ref) => Stream.value(
        signedIn
            ? const SignedIn(
                email: 'kody@example.com',
                method: SignInMethod.email,
              )
            : const LocalOnly(),
      ),
    ),
  ];

  testWidgets('signed out: sign in first, from the Account page', (
    tester,
  ) async {
    final fake = FakeCloudCalendars(list: [sampleCloudAccount]);
    await pumpSettings(
      tester,
      location: _page,
      overrides: cloud(fake, signedIn: false),
    );
    expect(find.text('GOOGLE AND MICROSOFT'), findsOne);
    expect(find.text('Connect Google Calendar'), findsNothing);
    await tester.tap(find.text('Sign in to connect Google or Microsoft'));
    await tester.pumpAndSettle();
    expect(find.text('Account'), findsWidgets);
  });

  testWidgets('connect opens the provider page (web parity: no device)', (
    tester,
  ) async {
    final fake = FakeCloudCalendars();
    final h = await pumpSettings(
      tester,
      location: _page,
      overrides: cloud(fake),
    );
    expect(find.text('No calendars connected yet'), findsNothing);
    await tester.tap(find.text('Connect Microsoft Outlook'));
    await tester.pumpAndSettle();
    expect(fake.connected, [CalendarProvider.microsoft]);
    expect(h.links.opened.single.host, 'accounts.example.com');
  });

  testWidgets('an account: its calendars, switches, write-back', (
    tester,
  ) async {
    final fake = FakeCloudCalendars(list: [sampleCloudAccount]);
    final sources = FakeCalendarSourceRepository();
    final import = FakeCalendarImport();
    await pumpSettings(
      tester,
      location: _page,
      overrides: cloud(fake),
      calendarSources: sources,
      cloudCalendarImport: import,
    );
    expect(find.text('KODY@GMAIL.COM'), findsOne);
    expect(find.text('Holidays in Germany'), findsOne, reason: 'read-only');
    expect(find.text('Kody'), findsNWidgets(2), reason: 'and send back');
    await tester.tap(find.text('Kody').first);
    await tester.pumpAndSettle();
    final row = sources.rows.single;
    expect(row.provider, CalendarProvider.google);
    expect(row.enabled, isFalse);
    expect(import.runs, isNotEmpty, reason: 'the switch imports at once');
  });

  testWidgets('disconnect asks first, then removes the account', (
    tester,
  ) async {
    final fake = FakeCloudCalendars(list: [sampleCloudAccount]);
    await pumpSettings(tester, location: _page, overrides: cloud(fake));
    await tester.ensureVisible(find.text('Disconnect'));
    await tester.tap(find.text('Disconnect'));
    await tester.pumpAndSettle();
    expect(find.text('Disconnect kody@gmail.com?'), findsOne);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(fake.disconnected, isEmpty);
    await tester.tap(find.text('Disconnect'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Disconnect'));
    await tester.pumpAndSettle();
    expect(fake.disconnected, [sampleCloudAccount.id]);
    expect(find.text('KODY@GMAIL.COM'), findsNothing);
  });

  testWidgets('a revoked account offers Reconnect', (tester) async {
    final fake = FakeCloudCalendars(
      list: [
        CloudAccount(
          id: sampleCloudAccount.id,
          provider: CalendarProvider.google,
          label: 'kody@gmail.com',
          status: CloudAccountStatus.reconnect,
        ),
      ],
    );
    await pumpSettings(tester, location: _page, overrides: cloud(fake));
    await tester.tap(find.text('Reconnect'));
    await tester.pumpAndSettle();
    expect(fake.connected, [CalendarProvider.google]);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final (width, size) in [
      ('compact', const Size(390, 1800)),
      ('expanded', const Size(1280, 1800)),
    ]) {
      for (final signedIn in [true, false]) {
        testWidgets('a11y: ${signedIn ? 'connected' : 'signed out'} '
            '${mode.name} $width', (tester) async {
          await pumpSettings(
            tester,
            location: _page,
            mode: mode,
            size: size,
            overrides: cloud(
              FakeCloudCalendars(list: [sampleCloudAccount]),
              signedIn: signedIn,
            ),
          );
          await expectA11yGuidelines(tester);
        });
      }
    }
  }
}
