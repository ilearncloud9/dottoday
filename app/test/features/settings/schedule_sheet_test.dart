import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/settings/wake_wind/schedule_sheet/schedule_sheet.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'settings_harness.dart';

// The schedule sheet (M20.7 part 4b; E-Phones Edit Weekdays, Weekend, New
// schedule checks; ED-084, ED-448): nothing is written before Save; a day
// from another schedule asks first; unticked or removed days go back to
// the default day with no alarm (owner 2026-11-24).

const _window = TimeWindow(start: '06:30', end: '23:00');
const _weekend = TimeWindow(start: '08:30', end: '24:30');

/// Weekdays 6:30–11:00 PM, Weekend 8:30 AM–12:30 AM, the alarm on.
Settings _week({bool alarm = true}) => Settings(
  use24h: false,
  wakeUpAlarm: alarm,
  sleepTargetMin: 8 * 60,
  dayBoundaries: {
    for (final d in Weekday.values) d: d.index < 5 ? _window : _weekend,
  },
);

Future<SettingsHarness> _pump(WidgetTester tester, Settings s) => pumpSettings(
  tester,
  settings: s,
  location: AppRoutes.settingsPage(SettingsPage.wakeWindDown),
);

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Finder _day(String label) => find.bySemanticsLabel(RegExp('^$label'));

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('Edit: the board rows; the dial moves Wind Down; Save writes', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final h = await _pump(tester, _week());
    await _tap(tester, find.text('Edit').first);
    for (final text in [
      'Weekdays',
      'Days',
      'Wind Down and Wake Up',
      '7 h 30',
      'of night',
      '30 min under your 8 h sleep target',
      'Ring on these days',
      'Mon–Fri at 6:30 AM',
      'Sound and snooze',
      'Reminders on these days',
      'Remove this schedule',
    ]) {
      expect(find.text(text), findsWidgets, reason: text);
    }
    final windDown = find.semantics.byPredicate(
      (n) => n.label == 'Wind Down' && n.flagsCollection.isSlider,
    );
    tester.semantics.increase(windDown);
    await tester.pumpAndSettle();
    // Nothing is written before Save.
    expect((await storedSettings(h)).boundaryFor(Weekday.mon).end, '23:00');
    await _tap(tester, find.text('Save'));
    final s = await storedSettings(h);
    for (final d in [Weekday.mon, Weekday.fri]) {
      expect(s.boundaryFor(d).end, '23:05');
    }
    expect(s.boundaryFor(Weekday.sat), _weekend);
    handle.dispose();
  });

  testWidgets('Cancel writes nothing', (tester) async {
    final handle = tester.ensureSemantics();
    final h = await _pump(tester, _week());
    await _tap(tester, find.text('Edit').first);
    await _tap(tester, _day('Monday'));
    await _tap(tester, find.text('Cancel'));
    expect(await storedSettings(h), _week());
    handle.dispose();
  });

  testWidgets('an unticked day: the default day, no alarm, the reminder', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final h = await _pump(
      tester,
      _week().copyWith(windDownReminderDays: {Weekday.mon}),
    );
    await _tap(tester, find.text('Edit').first);
    await _tap(tester, _day('Friday'));
    await _tap(tester, find.text('Save'));
    final s = await storedSettings(h);
    expect(s.boundaryFor(Weekday.fri), Settings.defaultDayBoundary);
    expect(s.boundaryFor(Weekday.thu), _window);
    expect(s.wakeUpAlarmDays, isNot(contains(Weekday.fri)));
    expect(s.windDownReminderDays, contains(Weekday.fri));
    handle.dispose();
  });

  testWidgets('New schedule: another schedule\'s day asks, Change takes it', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final h = await _pump(tester, _week());
    await _tap(tester, find.text('Add a schedule'));
    expect(find.text('New schedule'), findsOneWidget);
    // No day yet: Add stays off, and the note says why.
    expect(find.textContaining('Pick at least one day.'), findsOneWidget);
    await _tap(tester, _day('Saturday, in Weekend'));
    expect(find.text('This day already has a schedule'), findsOneWidget);
    expect(find.text('Would you like to change it?'), findsOneWidget);
    await _tap(tester, find.text('Cancel').last);
    expect(find.text('This day already has a schedule'), findsNothing);
    await _tap(tester, _day('Saturday, in Weekend'));
    await _tap(tester, find.text('Change'));
    await _tap(tester, find.text('Add'));
    final s = await storedSettings(h);
    expect(s.boundaryFor(Weekday.sat), Settings.defaultDayBoundary);
    expect(s.boundaryFor(Weekday.sun), _weekend);
    handle.dispose();
  });

  testWidgets('Remove: back to the default day with no alarm; Undo', (
    tester,
  ) async {
    final h = await _pump(tester, _week());
    await _tap(tester, find.text('Edit').last);
    expect(find.text('Weekend'), findsWidgets);
    expect(
      find.text(
        'Its days go back to 7:00 AM–10:00 PM with no alarm. Undo is offered.',
      ),
      findsOneWidget,
    );
    await _tap(tester, find.text('Remove this schedule'));
    var s = await storedSettings(h);
    expect(s.boundaryFor(Weekday.sun), Settings.defaultDayBoundary);
    expect(s.wakeUpAlarmDays, isNot(contains(Weekday.sun)));
    await _tap(tester, find.text('Undo'));
    s = await storedSettings(h);
    expect(s.boundaryFor(Weekday.sun), _weekend);
    expect(s.wakeUpAlarmDays, contains(Weekday.sun));
  });

  testWidgets('Weekend: Wind Down after midnight says whose evening it ends', (
    tester,
  ) async {
    await _pump(tester, _week());
    await _tap(tester, find.text('Edit').last);
    expect(
      find.text(
        "Wind Down 12:30 AM is after midnight, so it ends Saturday's and "
        "Sunday's day (shown on the day dot as their evening).",
      ),
      findsOneWidget,
    );
    expect(find.text('Matches your 8 h sleep target'), findsOneWidget);
  });

  testWidgets('Ring on these days: off saves the days without the alarm', (
    tester,
  ) async {
    final h = await _pump(tester, _week());
    await _tap(tester, find.text('Edit').first);
    await _tap(tester, find.text('Ring on these days'));
    await _tap(tester, find.text('Save'));
    final s = await storedSettings(h);
    expect(s.wakeUpAlarmDays, {Weekday.sat, Weekday.sun});
  });

  testWidgets('alarm off: Ring on these days is dimmed with why', (
    tester,
  ) async {
    await _pump(tester, _week(alarm: false));
    await _tap(tester, find.text('Edit').first);
    expect(find.text('Turn on Ring like an alarm first'), findsOneWidget);
    expect(find.text('Sound and snooze'), findsNothing);
    // The only switch on the sheet's alarm row: dimmed, not changeable.
    final toggle = tester.widget<DotSwitch>(
      find
          .descendant(
            of: find.byType(ScheduleSheet),
            matching: find.byType(DotSwitch),
          )
          .first,
    );
    expect(toggle.onChanged, isNull);
  });

  testWidgets('Sound and snooze opens the Wake Up sound picker', (
    tester,
  ) async {
    await _pump(tester, _week());
    await _tap(tester, find.text('Edit').first);
    await _tap(tester, find.text('Sound and snooze'));
    expect(find.text('Alarm sound'), findsWidgets);
  });
}
