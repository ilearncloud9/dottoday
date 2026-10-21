import 'dart:math';

import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/notification_id.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/fake_clock.dart';
import '../fixtures.dart';

// Critical cases from docs/08 §2 `notification_planner_test` (R-10).
// Now: 2026-10-21 08:00Z; zone UTC unless stated.

final _now = DateTime.utc(2026, 10, 21, 8);

NotificationPlanner _planner({int? max, FakeClock? clock}) =>
    NotificationPlanner(clock: clock ?? FakeClock(_now), maxPending: max);

Occurrence _task(
  String id,
  DateTime start, {
  List<Alert>? alerts = const [Alert(kind: AlertKind.before, offsetMin: 10)],
  int minutes = 30,
}) =>
    occurrenceFixture().copyWith(
      id: id,
      startUtc: start,
      durationMin: minutes,
      alerts: alerts,
      tzId: 'UTC',
    );

List<PlannedNotification> _plan(
  Iterable<Occurrence> tasks, {
  NotificationPlanner? planner,
  Map<String, List<Alert>> seriesAlerts = const {},
  TimeWindow? quiet,
  String tzId = 'UTC',
}) =>
    (planner ?? _planner()).plan(
      occurrences: tasks,
      tzId: tzId,
      seriesAlerts: seriesAlerts,
      quietHours: quiet,
    );

/// Applies a diff to a fake OS pending set, as the scheduler will.
Map<int, PlannedNotification> _apply(
  Map<int, PlannedNotification> os,
  List<PlannedNotification> desired,
) {
  final d = NotificationPlanner.diff(desired, os);
  final next = Map.of(os)..removeWhere((id, _) => d.cancel.contains(id));
  for (final n in d.schedule) {
    expect(next.containsKey(n.id), isFalse, reason: 'scheduled over a live id');
    next[n.id] = n;
  }
  return next;
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('fire times for every alert kind', () {
    final t = _task(
      'a',
      DateTime.utc(2026, 10, 21, 10),
      alerts: const [
        Alert(kind: AlertKind.before, offsetMin: 15),
        Alert(kind: AlertKind.atStart),
        Alert(kind: AlertKind.atEnd),
        Alert(kind: AlertKind.overdue, offsetMin: 5),
      ],
    );
    expect(
        _plan([t]).map((n) => (n.alertIndex, n.fireAtUtc.toIso8601String())), [
      (0, '2026-10-21T09:45:00.000Z'),
      (1, '2026-10-21T10:00:00.000Z'),
      (2, '2026-10-21T10:30:00.000Z'),
      (3, '2026-10-21T10:35:00.000Z'),
    ]);
    expect(_plan([t]).map((n) => n.timeSensitive), [false, true, false, false]);
  });

  test('exactly one pending per (occurrence, alert), with stable ids', () {
    final tasks = [
      for (var i = 0; i < 20; i++)
        _task(
          't$i',
          _now.add(Duration(hours: i + 1)),
          alerts: const [
            Alert(kind: AlertKind.before, offsetMin: 10),
            Alert(kind: AlertKind.atStart),
          ],
        ),
    ];
    final plan = _plan(tasks);
    expect(plan.length, 40);
    expect(plan.map((n) => n.id).toSet().length, 40);
    expect(plan.map((n) => (n.occurrenceId, n.alertIndex)).toSet().length, 40);
    expect(_plan(tasks.reversed), plan, reason: 'input order is irrelevant');
    expect(plan.first.id, notificationIdFor('t0', 0));
  });

  test('replanning unchanged tasks is a no-op diff', () {
    final tasks = [_task('a', _now.add(const Duration(hours: 2)))];
    final os = _apply({}, _plan(tasks));
    expect(NotificationPlanner.diff(_plan(tasks), os).isEmpty, isTrue);
  });

  test('an edit reschedules: old id cancelled, same id re-added', () {
    final a = _task('a', _now.add(const Duration(hours: 2)));
    var os = _apply({}, _plan([a]));
    final moved = a.copyWith(startUtc: _now.add(const Duration(hours: 3)));
    final d = NotificationPlanner.diff(_plan([moved]), os);
    expect(d.cancel, [notificationIdFor('a', 0)]);
    expect(d.schedule.single.fireAtUtc, _now.add(const Duration(minutes: 170)));
    os = _apply(os, _plan([moved]));
    expect(os.length, 1);
  });

  test('delete, done and skip cancel; inbox never alerts', () {
    final a = _task('a', _now.add(const Duration(hours: 2)));
    final os = _apply({}, _plan([a]));
    for (final gone in [
      a.copyWith(deletedAt: _now),
      a.copyWith(status: OccurrenceStatus.done),
      a.copyWith(status: OccurrenceStatus.skipped),
      a.copyWith(startUtc: null),
    ]) {
      expect(
        NotificationPlanner.diff(_plan([gone]), os).cancel,
        [notificationIdFor('a', 0)],
      );
    }
  });

  test('past and beyond-horizon alerts are not planned', () {
    final past = _task('p', _now.add(const Duration(minutes: 5))); // 07:55 fire
    final far = _task('f', _now.add(const Duration(days: 8)));
    final edge = _task('e', _now.add(const Duration(days: 7, minutes: 10)));
    expect(_plan([past, far, edge]).map((n) => n.occurrenceId), ['e']);
  });

  test('alerts: null inherits the series; [] means none', () {
    final inherit = _task('i', _now.add(const Duration(hours: 1)), alerts: null)
        .copyWith(seriesId: 's1');
    final none =
        _task('n', _now.add(const Duration(hours: 1)), alerts: const [])
            .copyWith(seriesId: 's1');
    final plan = _plan(
      [inherit, none],
      seriesAlerts: {
        's1': const [Alert(kind: AlertKind.atStart, sound: 'chime')],
      },
    );
    expect(plan.map((n) => (n.occurrenceId, n.sound)), [('i', 'chime')]);
  });

  group('quiet hours', () {
    const quiet = TimeWindow(start: '22:00', end: '07:00');

    test('alerts inside are kept but silent, never dropped', () {
      final late = _task('late', DateTime.utc(2026, 10, 21, 23));
      final early = _task('early', DateTime.utc(2026, 10, 22, 7, 5));
      final day = _task('day', DateTime.utc(2026, 10, 21, 12));
      final plan = {
        for (final n in _plan([late, early, day], quiet: quiet))
          n.occurrenceId: n,
      };
      expect(plan['late']!.silent, isTrue);
      expect(plan['early']!.silent, isTrue, reason: '06:55 is inside');
      expect(plan['day']!.silent, isFalse);
      expect(plan['late']!.timeSensitive, isFalse);
    });

    test('measured on the user wall clock', () {
      // 20:30Z is 22:30 in Berlin (CEST).
      final t = _task('t', DateTime.utc(2026, 10, 21, 20, 40));
      expect(_plan([t], quiet: quiet).single.silent, isFalse);
      expect(
        _plan([t], quiet: quiet, tzId: 'Europe/Berlin').single.silent,
        isTrue,
      );
    });

    test('non-wrapping window', () {
      const lunch = TimeWindow(start: '12:00', end: '13:00');
      final t = _task('t', DateTime.utc(2026, 10, 21, 12, 40));
      expect(_plan([t], quiet: lunch).single.silent, isTrue);
    });
  });

  test('snooze replaces earlier alerts with one reminder', () {
    final t = _task(
      't',
      _now.add(const Duration(hours: 1)),
      alerts: const [
        Alert(kind: AlertKind.before, offsetMin: 10),
        Alert(kind: AlertKind.atEnd),
      ],
    ).copyWith(snoozedUntilUtc: _now.add(const Duration(minutes: 55)));
    expect(_plan([t]).map((n) => n.alertIndex), [
      PlannedNotification.snoozeIndex,
      1,
    ]);
  });

  test('64-limit windowing keeps the earliest (iOS)', () {
    final tasks = [
      for (var i = 0; i < 100; i++)
        _task('t$i', _now.add(Duration(minutes: 30 + i * 60))),
    ];
    final plan = _plan(
      tasks,
      planner: _planner(max: NotificationPlanner.iosMaxPending),
    );
    expect(plan.length, 64);
    expect(plan.last.occurrenceId, 't63');
    // As time passes, the window slides; nothing fires twice.
    final clock = FakeClock(_now);
    var os = _apply({}, plan);
    clock.advance(const Duration(hours: 10));
    os.removeWhere((_, n) => !n.fireAtUtc.isAfter(clock.nowUtc()));
    os = _apply(os, _plan(tasks, planner: _planner(max: 64, clock: clock)));
    expect(os.length, 64);
    expect(os.values.map((n) => n.occurrenceId), contains('t72'));
  });

  test('ids never collide within a plan (probing)', () {
    final ids = <int>{};
    final plan = _plan([
      for (var i = 0; i < 2000; i++)
        _task('x$i', _now.add(Duration(minutes: 20 + i))),
    ]);
    for (final n in plan) {
      expect(ids.add(n.id), isTrue);
      expect(n.id, inInclusiveRange(0, 0x7FFFFFFF));
    }
  });

  test('property: random edits never leave >1 pending per alert', () {
    final rnd = Random(10);
    final tasks = {
      for (var i = 0; i < 15; i++)
        'o$i':
            _task('o$i', _now.add(Duration(minutes: 30 + rnd.nextInt(3000)))),
    };
    var os = <int, PlannedNotification>{};
    for (var step = 0; step < 200; step++) {
      final id = 'o${rnd.nextInt(15)}';
      final t = tasks[id]!;
      tasks[id] = switch (rnd.nextInt(5)) {
        0 => t.copyWith(
            startUtc: _now.add(Duration(minutes: 20 + rnd.nextInt(5000))),
          ),
        1 => t.copyWith(status: OccurrenceStatus.done),
        2 => t.copyWith(status: OccurrenceStatus.planned),
        3 => t.copyWith(
            alerts: [
              for (var k = 0; k <= rnd.nextInt(5); k++)
                Alert(
                  kind: AlertKind.values[rnd.nextInt(4)],
                  offsetMin: rnd.nextInt(120),
                ),
            ],
          ),
        _ => t.copyWith(deletedAt: rnd.nextBool() ? _now : null),
      };
      final desired = _plan(tasks.values);
      os = _apply(os, desired);
      expect(os.values.toSet(), desired.toSet());
      final keys = os.values.map((n) => (n.occurrenceId, n.alertIndex));
      expect(keys.toSet().length, os.length);
    }
  });
}
