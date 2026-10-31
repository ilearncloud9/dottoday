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

// The Wake Up alarm on the existing path (docs/15 W1a, M17.1): loud at
// Wake Up on each planned day, phones only, off until chosen; the first
// dot within 30 min of it rings as a normal notification (owner,
// 2026-10-31).

const _atStart = [Alert(kind: AlertKind.atStart)];

/// Wake Up 07:00 (UTC) every day: the default window.
const _on = Settings(wakeUpAlarm: true, bedtimeReminder: false);

Occurrence _task(String id, DateTime start, {bool routine = false}) =>
    occurrenceFixture().copyWith(
      id: id,
      startUtc: start,
      durationMin: 30,
      alerts: _atStart,
      tzId: 'UTC',
      routineStart: routine,
    );

List<PlannedNotification> _plan(
  Iterable<Occurrence> tasks, {
  Settings settings = _on,
  bool phone = true,
  DateTime? now,
}) =>
    NotificationPlanner(
      clock: FakeClock(now ?? DateTime.utc(2026, 10, 21, 5)),
      horizon: const Duration(days: 2),
    ).plan(
      occurrences: tasks,
      tzId: 'UTC',
      daily: settings,
      quietHours: settings.quietHours,
      startSound: settings.startSoundId,
      ringsWakeUp: phone,
    );

List<PlannedNotification> _wakeUps(List<PlannedNotification> plan) => [
  for (final n in plan)
    if (n.purpose == NotificationPurpose.wakeUp) n,
];

bool _loudTask(List<PlannedNotification> plan, String id) => plan
    .firstWhere(
      (n) => n.occurrenceId == id && n.purpose == NotificationPurpose.task,
    )
    .loud;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  final wed = [_task('wed-1', DateTime.utc(2026, 10, 21, 9))];

  test('off by default: an existing profile gets no Wake Up alarm', () {
    final plan = _plan(wed, settings: const Settings());
    expect(_wakeUps(plan), isEmpty);
    expect(_loudTask(plan, 'wed-1'), isTrue);
  });

  test('on a phone: loud at Wake Up, with the Start sound', () {
    final alarms = _wakeUps(_plan(wed));
    expect(alarms, hasLength(1));
    final alarm = alarms.single;
    expect(alarm.fireAtUtc, DateTime.utc(2026, 10, 21, 7));
    expect(alarm.occurrenceId, 'wed-1');
    expect(
      (alarm.loud, alarm.silent, alarm.timeSensitive),
      (true, false, true),
    );
    expect(alarm.sound, 'dot_alarm');
  });

  test('never on the Mac or the web', () {
    expect(_wakeUps(_plan(wed, phone: false)), isEmpty);
  });

  test('only on days with a block; a past Wake Up is not planned', () {
    final plan = _plan([
      _task('thu-1', DateTime.utc(2026, 10, 22, 10)),
    ], now: DateTime.utc(2026, 10, 21, 8));
    expect(_wakeUps(plan).map((n) => n.fireAtUtc), [
      DateTime.utc(2026, 10, 22, 7),
    ]);
  });

  test('quiet hours and low-energy mode never silence it', () {
    final plan = _plan(
      wed,
      settings: _on.copyWith(
        quietHours: const TimeWindow(start: '22:00', end: '08:00'),
        lowEnergyUntil: DateTime.utc(2026, 10, 21, 12),
      ),
    );
    expect(_wakeUps(plan).single.silent, isFalse);
  });

  test('a first dot within 30 min of Wake Up is a normal notification', () {
    for (final (minute, loud) in [
      (-31, true),
      (-30, false),
      (0, false),
      (30, false),
      (31, true),
    ]) {
      final start = DateTime.utc(
        2026,
        10,
        21,
        7,
      ).add(Duration(minutes: minute));
      final plan = _plan([_task('first', start)]);
      expect(_loudTask(plan, 'first'), loud, reason: '$minute min');
    }
  });

  test('a later routine start near Wake Up stays loud', () {
    final plan = _plan([
      _task('first', DateTime.utc(2026, 10, 21, 7, 10)),
      _task('routine', DateTime.utc(2026, 10, 21, 7, 20), routine: true),
    ]);
    expect(_loudTask(plan, 'first'), isFalse);
    expect(_loudTask(plan, 'routine'), isTrue);
  });

  test('with the alarm off the first dot still rings loud', () {
    final plan = _plan([
      _task('first', DateTime.utc(2026, 10, 21, 7, 10)),
    ], settings: const Settings());
    expect(_loudTask(plan, 'first'), isTrue);
  });

  test('ids are stable and the payload round-trips its purpose', () {
    final a = _wakeUps(_plan(wed)).single;
    final b = _wakeUps(_plan(wed)).single;
    expect(a, b);
    final decoded = decodeNotificationPayload(
      a.id,
      encodeNotificationPayload(a),
    );
    expect(decoded, a);
  });
}
