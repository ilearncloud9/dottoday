import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/calendar_fakes.dart';
import 'settings_harness.dart';

// Settings › Calendars (docs/02 F5, docs/09 M7.1, R-02): explain, ask,
// denied → explain + Settings, then one switch per calendar.

const _page = '/settings/calendars';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('not asked: explains, then Connect asks the OS once', (
    tester,
  ) async {
    final os = FakeDeviceCalendarGateway(list: sampleCalendars);
    await pumpSettings(tester, location: _page, calendarGateway: os);
    expect(find.text('No calendars connected yet'), findsOneWidget);
    expect(find.textContaining('asks your device once'), findsOneWidget);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Connect a calendar'));
    await tester.pumpAndSettle();
    expect(os.asked, 1);
    // Allowed: the device's calendars, grouped by account, all on.
    for (final name in ['Home', 'Work', 'Holidays', 'Gym']) {
      expect(find.text(name), findsOneWidget, reason: name);
    }
    expect(find.text('ICLOUD'), findsOneWidget);
    expect(find.text('Read-only'), findsOneWidget);
    expect(find.text('Connect a calendar'), findsNothing);
  });

  testWidgets('a switch is stored per calendar', (tester) async {
    final os = FakeDeviceCalendarGateway(
      state: PermissionState.granted,
      list: sampleCalendars,
    );
    final sources = FakeCalendarSourceRepository();
    await pumpSettings(
      tester,
      location: _page,
      calendarGateway: os,
      calendarSources: sources,
    );
    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();
    expect(sources.rows.single.externalAccountId, 'work');
    expect(sources.rows.single.enabled, isFalse);
    final work = tester.widget<DotSwitch>(
      find.descendant(
        of: find.ancestor(
          of: find.text('Work'),
          matching: find.byType(SettingsRow),
        ),
        matching: find.byType(DotSwitch),
      ),
    );
    expect(work.value, isFalse);
  });

  testWidgets('denied: the notice, and Open settings', (tester) async {
    final os = FakeDeviceCalendarGateway(
      answer: PermissionState.denied,
      settingsOpen: true,
    );
    await pumpSettings(tester, location: _page, calendarGateway: os);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Connect a calendar'));
    await tester.pumpAndSettle();
    expect(find.text('Calendar access is off'), findsOneWidget);
    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();
    expect(os.openedSettings, 1);
  });

  testWidgets('denied where Settings cannot open: says where to go', (
    tester,
  ) async {
    final os = FakeDeviceCalendarGateway(state: PermissionState.denied);
    await pumpSettings(tester, location: _page, calendarGateway: os);
    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();
    expect(find.textContaining('allow access to Calendars'), findsOneWidget);
  });

  testWidgets('allowed but unreadable: the error state, then Try again', (
    tester,
  ) async {
    final os = FakeDeviceCalendarGateway(
      state: PermissionState.granted,
      list: sampleCalendars,
      failure: const UnexpectedFailure(),
    );
    await pumpSettings(tester, location: _page, calendarGateway: os);
    expect(find.text('Try again'), findsOneWidget);
    os.failure = null;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('allowed, no calendars on the device', (tester) async {
    final os = FakeDeviceCalendarGateway(state: PermissionState.granted);
    await pumpSettings(tester, location: _page, calendarGateway: os);
    expect(find.text('No calendars on this device'), findsOneWidget);
  });

  testWidgets('no device calendars here (web)', (tester) async {
    await pumpSettings(tester, location: _page);
    expect(find.text('Calendar import arrives in a later update.'), findsOne);
    final connect = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(connect.onPressed, isNull);
  });

  // Every state, both themes, compact and expanded (R-12).
  for (final state in PermissionState.values) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      for (final (width, size) in [
        ('compact', const Size(390, 1400)),
        ('expanded', const Size(1280, 1400)),
      ]) {
        testWidgets('a11y: ${state.name} ${mode.name} $width', (tester) async {
          await pumpSettings(
            tester,
            location: _page,
            mode: mode,
            size: size,
            calendarGateway: FakeDeviceCalendarGateway(
              state: state,
              list: sampleCalendars,
            ),
          );
          await expectA11yGuidelines(tester);
        });
      }
    }
  }
}
