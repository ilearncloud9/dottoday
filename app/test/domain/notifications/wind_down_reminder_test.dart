import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/fake_clock.dart';
import '../fixtures.dart';

// The Wind Down reminder (M3d.3, R-10). Now: Wed 2026-10-21 08:00Z; Berlin
// leaves summer time on Sun 2026-10-25, so 22:00 local is 20:00Z before
// and 21:00Z from that day on.

final _now = DateTime.utc(2026, 10, 21, 8);

List<PlannedNotification> _windDowns(
  Settings settings, {
  Iterable<Occurrence> tasks = const [],
  DateTime? now,
}) => NotificationPlanner(clock: FakeClock(now ?? _now))
    .plan(
      occurrences: tasks,
      tzId: 'Europe/Berlin',
      quietHours: settings.quietHours,
      daily: settings,
    )
    .where((n) => n.purpose == NotificationPurpose.windDown)
    .toList();

Occurrence _task(String id, DateTime start) => occurrenceFixture().copyWith(
  id: id,
  startUtc: start,
  alerts: const [],
  tzId: 'Europe/Berlin',
);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('one per day at local Wind Down, across the DST change', () {
    final fire = _windDowns(const Settings()).map((n) => n.fireAtUtc);
    expect(fire, [
      DateTime.utc(2026, 10, 21, 20),
      DateTime.utc(2026, 10, 22, 20),
      DateTime.utc(2026, 10, 23, 20),
      DateTime.utc(2026, 10, 24, 20),
      DateTime.utc(2026, 10, 25, 21),
      DateTime.utc(2026, 10, 26, 21),
      DateTime.utc(2026, 10, 27, 21),
    ]);
  });

  test('each weekday uses its own Wind Down', () {
    const late = TimeWindow(start: '09:00', end: '23:30');
    final fire = _windDowns(
      const Settings(dayBoundaries: {Weekday.fri: late}),
    ).map((n) => n.fireAtUtc);
    expect(fire, contains(DateTime.utc(2026, 10, 23, 21, 30)));
    expect(fire, isNot(contains(DateTime.utc(2026, 10, 23, 20))));
  });

  test('off: none', () {
    expect(_windDowns(const Settings(windDownReminder: false)), isEmpty);
  });

  test("carries tomorrow's first task, or none", () {
    final tasks = [
      _task('later', DateTime.utc(2026, 10, 22, 9)),
      _task('first', DateTime.utc(2026, 10, 22, 7)),
      _task('today', DateTime.utc(2026, 10, 21, 9)),
    ];
    final n = _windDowns(const Settings(), tasks: tasks);
    expect(n.first.occurrenceId, 'first');
    expect(n[1].occurrenceId, '');
  });

  test('silent in quiet hours, never time-sensitive', () {
    const quiet = TimeWindow(start: '21:30', end: '07:00');
    final n = _windDowns(const Settings(quietHours: quiet));
    expect(n.every((x) => x.silent), isTrue);
    expect(n.any((x) => x.timeSensitive), isFalse);
    expect(_windDowns(const Settings()).any((x) => x.silent), isFalse);
  });

  test('ids are stable when re-planned later: diff is empty', () {
    final a = _windDowns(const Settings());
    final b = _windDowns(
      const Settings(),
      now: _now.add(const Duration(hours: 1)),
    );
    final pending = {for (final n in a) n.id: n};
    final diff = NotificationPlanner.diff(b, pending);
    expect(diff.schedule, isEmpty);
    expect(diff.cancel, isEmpty);
  });

  test('past Wind Down today: starts tomorrow', () {
    final n = _windDowns(
      const Settings(),
      now: DateTime.utc(2026, 10, 21, 20, 1),
    );
    expect(n.first.fireAtUtc, DateTime.utc(2026, 10, 22, 20));
  });

  test('a sleep target pulls it earlier before an early tomorrow (15 W4)', () {
    // Thu 22 Oct: a task at 06:00 Berlin; Wake Up 05:30 that day.
    final early = const Settings(
      sleepTargetMin: 8 * 60,
      dayBoundaries: {Weekday.thu: TimeWindow(start: '05:30', end: '22:00')},
    );
    final fire = _windDowns(
      early,
      tasks: [_task('early', DateTime.utc(2026, 10, 22, 4))],
    ).map((n) => n.fireAtUtc);
    // Wed: 05:30 Thu − 8 h = 21:30 Wed (19:30Z), before 22:00.
    expect(fire.first, DateTime.utc(2026, 10, 21, 19, 30));
  });

  test('no target, or tomorrow free: the set Wind Down', () {
    final early = const Settings(
      dayBoundaries: {Weekday.thu: TimeWindow(start: '05:30', end: '22:00')},
    );
    expect(
      _windDowns(
        early,
        tasks: [_task('early', DateTime.utc(2026, 10, 22, 4))],
      ).first.fireAtUtc,
      DateTime.utc(2026, 10, 21, 20),
    );
    expect(
      _windDowns(early.copyWith(sleepTargetMin: 8 * 60)).first.fireAtUtc,
      DateTime.utc(2026, 10, 21, 20),
    );
  });
}
