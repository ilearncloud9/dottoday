import 'dart:math';

import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/alarm_policy.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/time/wall_clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../support/fake_clock.dart';
import '../fixtures.dart';

// Alarm-loud dot-starts (docs/09 M6.5.3, 11-standout-roadmap A0): the
// first dot of each day and routine starts; quiet hours never silence them.

const _atStart = [Alert(kind: AlertKind.atStart)];

Occurrence _task(String id, DateTime start, {String tzId = 'UTC'}) =>
    occurrenceFixture().copyWith(
      id: id,
      startUtc: start,
      durationMin: 30,
      alerts: _atStart,
      tzId: tzId,
    );

List<PlannedNotification> _plan(
  Iterable<Occurrence> tasks, {
  DateTime? now,
  String tzId = 'UTC',
  TimeWindow? quiet,
  Set<String> routines = const {},
}) =>
    NotificationPlanner(
      clock: FakeClock(now ?? DateTime.utc(2026, 10, 21, 5)),
    ).plan(
      occurrences: tasks,
      tzId: tzId,
      quietHours: quiet,
      routineStartIds: routines,
    );

Set<String> _loud(List<PlannedNotification> plan) => {
  for (final n in plan)
    if (n.loud) n.occurrenceId,
};

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('only the first dot of each day is loud', () {
    final tasks = [
      _task('wed-1', DateTime.utc(2026, 10, 21, 7)),
      _task('wed-2', DateTime.utc(2026, 10, 21, 9)),
      _task('thu-1', DateTime.utc(2026, 10, 22, 6, 30)),
      _task('thu-2', DateTime.utc(2026, 10, 22, 8)),
    ];
    expect(_loud(_plan(tasks)), {'wed-1', 'thu-1'});
  });

  test('loud ignores quiet hours; normal pings there stay silent', () {
    const quiet = TimeWindow(start: '22:00', end: '08:00');
    final plan = _plan([
      _task('first', DateTime.utc(2026, 10, 21, 6)),
      _task('second', DateTime.utc(2026, 10, 21, 7)),
    ], quiet: quiet);
    final first = plan.firstWhere((n) => n.occurrenceId == 'first');
    final second = plan.firstWhere((n) => n.occurrenceId == 'second');
    expect(
      (first.loud, first.silent, first.timeSensitive),
      (true, false, true),
    );
    expect((second.loud, second.silent), (false, true));
  });

  test('only the at-start alert rings loud, not "before" or the end', () {
    final task = _task('t', DateTime.utc(2026, 10, 21, 7)).copyWith(
      alerts: const [
        Alert(kind: AlertKind.before, offsetMin: 10),
        Alert(kind: AlertKind.atStart),
        Alert(kind: AlertKind.atEnd),
      ],
    );
    final plan = _plan([task]);
    expect([for (final n in plan) n.loud], [false, true, false]);
  });

  test('a day whose first dot is done gets no alarm', () {
    final tasks = [
      _task(
        'early',
        DateTime.utc(2026, 10, 21, 6),
      ).copyWith(status: OccurrenceStatus.done),
      _task('later', DateTime.utc(2026, 10, 21, 9)),
    ];
    expect(_loud(_plan(tasks)), isEmpty);
    // Trashed rows and the Inbox don't count as the first dot.
    final trashed = [
      _task(
        'gone',
        DateTime.utc(2026, 10, 21, 6),
      ).copyWith(deletedAt: DateTime.utc(2026, 10, 21)),
      _task('later', DateTime.utc(2026, 10, 21, 9)),
    ];
    expect(_loud(_plan(trashed)), {'later'});
  });

  test('days are the user\'s local days, across midnight and travel', () {
    // 23:30 Berlin on the 21st is 21:30Z; 00:30 Berlin on the 22nd 22:30Z.
    final late = _task('late', DateTime.utc(2026, 10, 21, 21, 30));
    final night = _task('night', DateTime.utc(2026, 10, 21, 22, 30));
    final morning = _task('morning', DateTime.utc(2026, 10, 22, 6));
    final berlin = _plan([late, night, morning], tzId: 'Europe/Berlin');
    expect(_loud(berlin), {'late', 'night'});
    // From New York (after travel) late and night are both evening of the
    // 21st, and morning (02:00 on the 22nd) is that day's first.
    final ny = _plan([late, night, morning], tzId: 'America/New_York');
    expect(_loud(ny), {'late', 'morning'});
  });

  test('routine-start dots are loud too', () {
    final tasks = [
      _task('first', DateTime.utc(2026, 10, 21, 7)),
      _task('routine', DateTime.utc(2026, 10, 21, 18)),
    ];
    expect(_loud(_plan(tasks, routines: {'routine'})), {'first', 'routine'});
  });

  test('the test alarm: loud, its own slot, only while ahead (M6.5.9)', () {
    final at = DateTime.utc(2026, 10, 21, 5, 1);
    final planned =
        NotificationPlanner(
          clock: FakeClock(DateTime.utc(2026, 10, 21, 5)),
        ).plan(
          occurrences: [_task('first', DateTime.utc(2026, 10, 21, 5, 1))],
          tzId: 'UTC',
          quietHours: const TimeWindow(start: '00:00', end: '23:59'),
          testAlarmAtUtc: at,
        );
    final test = planned.singleWhere(
      (n) => n.purpose == NotificationPurpose.testAlarm,
    );
    expect((test.loud, test.silent, test.timeSensitive), (true, false, true));
    expect(test.fireAtUtc, at);
    expect(planned.map((n) => n.id).toSet(), hasLength(planned.length));
    final later = NotificationPlanner(
      clock: FakeClock(at.add(const Duration(seconds: 1))),
    ).plan(occurrences: const [], tzId: 'UTC', testAlarmAtUtc: at);
    expect(later, isEmpty, reason: 'once it is due it is never re-posted');
  });

  test('property: one loud per day and one pending per alert, DST week', () {
    final rnd = Random(653);
    final berlin = tz.getLocation('Europe/Berlin');
    // The week over the end of summer time (25 Oct 2026).
    final now = DateTime.utc(2026, 10, 22);
    for (var round = 0; round < 50; round++) {
      final tasks = [
        for (var i = 0; i < 20; i++)
          _task(
            'o$round-$i',
            now.add(Duration(minutes: 30 + rnd.nextInt(6 * 24 * 60))),
            tzId: 'Europe/Berlin',
          ).copyWith(
            status: rnd.nextInt(6) == 0
                ? OccurrenceStatus.done
                : OccurrenceStatus.planned,
          ),
      ];
      final plan = _plan(tasks, now: now, tzId: 'Europe/Berlin');
      final keys = plan.map((n) => (n.occurrenceId, n.alertIndex));
      expect(keys.toSet().length, plan.length);
      final loudDays = <DateTime>[
        for (final n in plan)
          if (n.loud) _day(utcToWallClock(berlin, n.fireAtUtc)),
      ];
      expect(loudDays.toSet().length, loudDays.length, reason: 'round $round');
      expect(
        loudStartIds(tasks, berlin).length,
        greaterThanOrEqualTo(loudDays.length),
      );
    }
  });
}

DateTime _day(DateTime wall) => DateTime(wall.year, wall.month, wall.day);
