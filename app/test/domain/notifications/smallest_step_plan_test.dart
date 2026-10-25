import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/fake_clock.dart';
import '../fixtures.dart';

// Smallest step's reminder (11 B2, docs/09 M10.6): one per task with a
// step left, at planned start + 10 min; a real start, Done or a move
// re-plans it away, so it fires once or not at all.

final _now = DateTime.utc(2026, 10, 21, 8);
final _start = DateTime.utc(2026, 10, 21, 9);

Occurrence _task({DateTime? start, int minutes = 60}) =>
    occurrenceFixture().copyWith(
      startUtc: start ?? _start,
      durationMin: minutes,
      alerts: const [Alert(kind: AlertKind.atStart, offsetMin: 0)],
      tzId: 'UTC',
    );

List<PlannedNotification> _plan(
  Iterable<Occurrence> tasks, {
  Set<String>? withSteps,
  TimeWindow? quiet,
  FakeClock? clock,
}) => NotificationPlanner(clock: clock ?? FakeClock(_now)).plan(
  occurrences: tasks,
  tzId: 'UTC',
  quietHours: quiet,
  withSteps: withSteps ?? {for (final t in tasks) t.id},
);

List<PlannedNotification> _smallest(List<PlannedNotification> p) => [
  for (final n in p)
    if (n.purpose == NotificationPurpose.smallestStep) n,
];

/// Applies [desired] to the fake OS set as the scheduler does.
Map<int, PlannedNotification> _sync(
  Map<int, PlannedNotification> os,
  List<PlannedNotification> desired,
) {
  final diff = NotificationPlanner.diff(desired, os);
  final next = {...os}..removeWhere((id, _) => diff.cancel.contains(id));
  for (final n in diff.schedule) {
    next[n.id] = n;
  }
  return next;
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('one at start + 10 min, beside the task’s own alert', () {
    final plan = _plan([_task()]);
    final s = _smallest(plan).single;
    expect(s.fireAtUtc, _start.add(const Duration(minutes: 10)));
    expect(s.alertIndex, PlannedNotification.smallestStepIndex);
    expect(
      plan.where((n) => n.purpose == NotificationPurpose.task),
      hasLength(1),
    );
  });

  test('none without a step left, or once it has fired', () {
    expect(_smallest(_plan([_task()], withSteps: const {})), isEmpty);
    final after = FakeClock(_start.add(const Duration(minutes: 11)));
    expect(_smallest(_plan([_task()], clock: after)), isEmpty);
  });

  test('fires once: re-planning changes nothing', () {
    var os = _sync({}, _plan([_task()]));
    final again = NotificationPlanner.diff(_plan([_task()]), os);
    expect(again.schedule, isEmpty);
    expect(again.cancel, isEmpty);
    os = _sync(os, _plan([_task()]));
    expect(_smallest(os.values.toList()), hasLength(1));
  });

  test('a real start (Start, Focus, the live dot) cancels it', () {
    final os = _sync({}, _plan([_task()]));
    final started = _task().copyWith(actualStartUtc: _now);
    final diff = NotificationPlanner.diff(_plan([started]), os);
    final id = _smallest(os.values.toList()).single.id;
    expect(diff.cancel, contains(id));
  });

  test('Done cancels it', () {
    final os = _sync({}, _plan([_task()]));
    final done = _task().copyWith(status: OccurrenceStatus.done);
    final id = _smallest(os.values.toList()).single.id;
    expect(NotificationPlanner.diff(_plan([done]), os).cancel, contains(id));
  });

  test('a move replaces it at the new start + 10 min', () {
    var os = _sync({}, _plan([_task()]));
    final later = _start.add(const Duration(hours: 2));
    os = _sync(os, _plan([_task(start: later)]));
    final s = _smallest(os.values.toList()).single;
    expect(s.fireAtUtc, later.add(const Duration(minutes: 10)));
  });

  test('quiet hours keep it, silent', () {
    const quiet = TimeWindow(start: '08:30', end: '09:30');
    expect(_smallest(_plan([_task()], quiet: quiet)).single.silent, isTrue);
  });
}
