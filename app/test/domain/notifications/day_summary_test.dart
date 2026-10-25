import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/fake_clock.dart';
import '../fixtures.dart';

// The day-start summary (docs/02 F6.2, M8.4d): "Your day: 6 blocks, first
// at 08:00" at Wake Up on the chosen weekdays. Now: Wed 2026-10-21 04:00Z
// (06:00 in Berlin, summer time until Sun 2026-10-25), so Wake Up 07:00 is
// 05:00Z before the change and 06:00Z from that day on.

final _now = DateTime.utc(2026, 10, 21, 4);
const _every = {...Weekday.values};

List<PlannedNotification> _summaries(
  Settings settings, {
  Iterable<Occurrence> tasks = const [],
  DateTime? now,
  int? max,
}) => NotificationPlanner(clock: FakeClock(now ?? _now), maxPending: max)
    .plan(occurrences: tasks, tzId: 'Europe/Berlin', daily: settings)
    .where((n) => n.purpose == NotificationPurpose.daySummary)
    .toList();

Occurrence _task(String id, DateTime start, {int minutes = 30}) =>
    occurrenceFixture().copyWith(
      id: id,
      startUtc: start,
      durationMin: minutes,
      alerts: const [],
      tzId: 'Europe/Berlin',
    );

/// One 09:00-local block on each of the next 7 days.
final _week = [
  for (var d = 0; d < 7; d++)
    _task('t$d', DateTime.utc(2026, 10, 21 + d, d < 4 ? 7 : 8)),
];

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('off by default: none', () {
    expect(const Settings().daySummaryDays, isEmpty);
    expect(_summaries(const Settings(), tasks: _week), isEmpty);
  });

  test('at each chosen day\'s Wake Up, across the DST change', () {
    final fire = _summaries(
      const Settings(daySummaryDays: _every),
      tasks: _week,
    ).map((n) => n.fireAtUtc);
    expect(fire, [
      DateTime.utc(2026, 10, 21, 5),
      DateTime.utc(2026, 10, 22, 5),
      DateTime.utc(2026, 10, 23, 5),
      DateTime.utc(2026, 10, 24, 5),
      DateTime.utc(2026, 10, 25, 6),
      DateTime.utc(2026, 10, 26, 6),
      DateTime.utc(2026, 10, 27, 6),
    ]);
  });

  test('only the chosen weekdays, each on its own Wake Up', () {
    const late = TimeWindow(start: '09:30', end: '23:00');
    final n = _summaries(
      const Settings(
        daySummaryDays: {Weekday.fri, Weekday.mon},
        dayBoundaries: {Weekday.fri: late},
      ),
      tasks: [..._week, _task('fri-late', DateTime.utc(2026, 10, 23, 10))],
    );
    expect(n.map((x) => x.fireAtUtc), [
      DateTime.utc(2026, 10, 23, 7, 30),
      DateTime.utc(2026, 10, 26, 6),
    ]);
  });

  test('counts the day\'s blocks, carries the first; all-day items and '
      'other days do not count', () {
    final day = [
      _task('b', DateTime.utc(2026, 10, 21, 12)),
      _task('a', DateTime.utc(2026, 10, 21, 6)),
      _task('c', DateTime.utc(2026, 10, 21, 15)),
      _task('all-day', DateTime.utc(2026, 10, 20, 22), minutes: 1440),
      _task('tomorrow', DateTime.utc(2026, 10, 22, 6)),
    ];
    final n = _summaries(
      const Settings(daySummaryDays: {Weekday.wed}),
      tasks: day,
    );
    expect(n, hasLength(1));
    expect(n.single.blocks, 3);
    expect(n.single.occurrenceId, 'a');
    expect(n.single.timeSensitive, isFalse);
    expect(n.single.loud, isFalse);
  });

  test('an empty day has no summary', () {
    expect(_summaries(const Settings(daySummaryDays: _every)), isEmpty);
  });

  test('done and trashed tasks do not count', () {
    final n = _summaries(
      const Settings(daySummaryDays: {Weekday.wed}),
      tasks: [
        _task('a', DateTime.utc(2026, 10, 21, 6)),
        _task(
          'done',
          DateTime.utc(2026, 10, 21, 7),
        ).copyWith(status: OccurrenceStatus.done),
        _task(
          'gone',
          DateTime.utc(2026, 10, 21, 8),
        ).copyWith(deletedAt: DateTime.utc(2026, 10, 20)),
      ],
    );
    expect(n.single.blocks, 1);
  });

  test('silent in quiet hours', () {
    const quiet = TimeWindow(start: '22:00', end: '07:30');
    final n = _summaries(
      const Settings(daySummaryDays: _every, quietHours: quiet),
      tasks: _week,
    );
    expect(n, isNotEmpty);
    expect(n.every((x) => x.silent), isTrue);
  });

  test('stable when re-planned; a new block re-posts that day only', () {
    const s = Settings(daySummaryDays: _every);
    final a = _summaries(s, tasks: _week);
    final pending = {for (final n in a) n.id: n};
    final same = NotificationPlanner.diff(
      _summaries(s, tasks: _week, now: _now.add(const Duration(minutes: 30))),
      pending,
    );
    expect(same.isEmpty, isTrue);
    final more = [..._week, _task('x', DateTime.utc(2026, 10, 22, 12))];
    final diff = NotificationPlanner.diff(_summaries(s, tasks: more), pending);
    expect(diff.cancel, hasLength(1));
    expect(diff.schedule.single.blocks, 2);
    expect(diff.schedule.single.fireAtUtc, DateTime.utc(2026, 10, 22, 5));
  });

  test('the count round-trips through the payload', () {
    final n = _summaries(
      const Settings(daySummaryDays: _every),
      tasks: _week,
    ).first;
    expect(decodeNotificationPayload(n.id, encodeNotificationPayload(n)), n);
  });

  test('never collides with a task alert or Bedtime', () {
    final tasks = [
      for (final t in _week)
        t.copyWith(alerts: const [Alert(kind: AlertKind.atStart)]),
    ];
    final all = NotificationPlanner(clock: FakeClock(_now)).plan(
      occurrences: tasks,
      tzId: 'Europe/Berlin',
      daily: const Settings(daySummaryDays: _every),
    );
    expect(all.map((n) => n.id).toSet(), hasLength(all.length));
    expect(
      all.map((n) => n.purpose).toSet(),
      containsAll([
        NotificationPurpose.task,
        NotificationPurpose.bedtime,
        NotificationPurpose.daySummary,
      ]),
    );
  });
}
