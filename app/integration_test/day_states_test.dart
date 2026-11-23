// Day states (docs/09 M20.6 part 3; E-R2-27 §1, ED-330): every task done
// after Wind Down (the Day review, no celebration); a past day (Mon 2 Nov:
// "· not done", a skipped task faded, no prompts); three tasks overlapping
// (a chain of knots); all-day chips above the day; today with nothing
// planned (ED-386's empty day); and on phones the Wake Up card on an empty
// day (R2-19's card, its own milestone). In-memory data:
//   tool/device_tests.sh ios <udid> day_states       (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> day_states
//   SWEEP_TARGET=integration_test/day_states_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/day_states_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=day_states node tool/slice/web_journey.mjs <url> compact|expanded <b>
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/domain/fixtures.dart';
import '../test/features/timeline/calendar/calendar_world.dart';
import 'support/device_shot.dart';

// l10n-ignore-start: fixture data
Occurrence _task(
  String id,
  String title,
  String color,
  String icon,
  DateTime startUtc,
  int minutes, {
  OccurrenceStatus status = OccurrenceStatus.planned,
}) => occurrenceFixture().copyWith(
  id: id,
  title: title,
  colorKey: color,
  iconKey: icon,
  startUtc: startUtc,
  tzId: 'Europe/Berlin',
  durationMin: minutes,
  status: status,
);

/// The month with, on Monday, a task not done and one skipped; today a
/// third task overlapping two (Quick sync) and two all-day items.
List<Occurrence> _busy() => [
  ...calendarMonth(),
  _task(
    'mon deep',
    'Deep work: roadmap',
    'indigo',
    'focus_block',
    DateTime.utc(2026, 11, 2, 15),
    60,
  ),
  _task(
    'mon lunch',
    'Lunch',
    'rose',
    'meal',
    DateTime.utc(2026, 11, 2, 17),
    45,
    status: OccurrenceStatus.skipped,
  ),
  _task(
    'quick sync',
    'Quick sync',
    'violet',
    'call',
    DateTime.utc(2026, 11, 3, 9, 45),
    30,
  ),
  _task(
    'birthday',
    "Mum's birthday",
    'sky',
    'meal',
    DateTime.utc(2026, 11, 2, 23),
    1440,
  ),
  _task(
    'rent',
    'Pay the rent',
    'amber',
    'mail',
    DateTime.utc(2026, 11, 2, 23),
    1440,
  ),
];

/// Today's nine, every one done.
List<Occurrence> _allDone() => [
  for (final o in calendarMonth())
    o.startUtc!.day == 3 ? o.copyWith(status: OccurrenceStatus.done) : o,
];

/// The month without today's tasks.
List<Occurrence> _emptyToday() => [
  for (final o in calendarMonth())
    if (o.startUtc!.day != 3) o,
];
// l10n-ignore-end

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets('day states, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'day_${mode.name}_$step');
      final width =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;

      // 1 · A past day: Monday, from today's strip.
      var router = await pumpCalendar(tester, mode: mode, rows: _busy());
      router.go(AppRoutes.day(DateTime(2026, 11, 2)));
      await tester.pumpAndSettle();
      // Phones: down to the afternoon (Deep work not done, Lunch
      // skipped); wider windows show the day at once.
      if (width < 600) {
        await tester.drag(
          find.text('Run').hitTestable().first, // l10n-ignore
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();
      }
      await shot('1_past_day');

      // 2 · Today: the all-day chips, and three tasks overlapping.
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
      // Phones: up past Deep work to the chain of three (10:00 to 11:15).
      if (width < 600) {
        await tester.drag(
          find.text('Morning run').hitTestable().first, // l10n-ignore
          const Offset(0, -350),
        );
        await tester.pumpAndSettle();
      }
      await shot('2_overlaps');

      // 3 · Every task done, after Wind Down: the Day review. A fresh app
      // each time (a new clock and data, not the last scope's).
      await tester.pumpWidget(const SizedBox());
      router = await pumpCalendar(
        tester,
        mode: mode,
        rows: _allDone(),
        now: DateTime.utc(2026, 11, 3, 21, 30),
      );
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
      await shot('3_all_done');

      // 4 · Today with nothing planned.
      await tester.pumpWidget(const SizedBox());
      router = await pumpCalendar(tester, mode: mode, rows: _emptyToday());
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
      expect(find.text('Copy a day…'), findsWidgets); // l10n-ignore
      await shot('4_empty');

      // 5 · Phones: the Wake Up card on an empty day.
      if (width < 600) {
        router.go(AppRoutes.wakeUp);
        await tester.pumpAndSettle();
        await shot('5_wake_up_empty');
      }
    });
  }
}
