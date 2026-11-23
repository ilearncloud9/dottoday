import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import 'settings_harness.dart';

// Settings › Your day › Wake Up and Wind Down (M20.7 part 4a, ED-084).

const _weekdays = TimeWindow(start: '06:30', end: '23:00');
const _weekend = TimeWindow(start: '08:30', end: '24:30');

final _split = Settings(
  use24h: true,
  wakeUpAlarm: true,
  dayBoundaries: {
    for (final d in Weekday.values) d: d.index < 5 ? _weekdays : _weekend,
  },
);

void main() {
  setUpAll(tz_data.initializeTimeZones);
  final page = AppRoutes.settingsPage(SettingsPage.wakeWindDown);

  testWidgets('Tonight, then the week as schedules', (tester) async {
    await pumpSettings(tester, settings: _split, location: page);
    // The demo day is a Wednesday: tonight's Wind Down, Thursday's Wake Up.
    expect(find.text('Tonight · Wednesday'), findsOneWidget);
    expect(find.text('Wind Down 23:00'), findsOneWidget);
    expect(find.text('Wake Up 06:30'), findsOneWidget);
    expect(find.text('7 h 30 of night · alarm on'), findsOneWidget);
    for (final text in ['Your week', 'Weekdays', 'Mon–Fri', 'Weekend']) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.text('Alarm on'), findsNWidgets(2));
    expect(find.text('8 h of night'), findsOneWidget);
    expect(find.text('Add a schedule'), findsOneWidget);
  });

  testWidgets('Wake Up options lands on the same page', (tester) async {
    await pumpSettings(
      tester,
      location: AppRoutes.settingsPage(SettingsPage.wakeUp),
    );
    expect(find.text('Your week'), findsOneWidget);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('a11y ${mode.name}', (tester) async {
      await pumpSettings(tester, settings: _split, location: page, mode: mode);
      await expectA11yGuidelines(tester);
    });
  }
}
