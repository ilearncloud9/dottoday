import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:dottoday/domain/notifications/wake_up_alarm.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/fake_clock.dart';
import '../fixtures.dart';

// The Wake Up alarm at alarm grade (docs/15 W1b, M17.2): the instants
// AlarmGateway armed never ring a second time on the notification path,
// and the day's cue is the same for a given date.

const _on = Settings(wakeUpAlarm: true, bedtimeReminder: false);

Occurrence _task(String id, DateTime start) => occurrenceFixture().copyWith(
  id: id,
  startUtc: start,
  durationMin: 30,
  alerts: const [Alert(kind: AlertKind.atStart)],
  tzId: 'UTC',
);

final _planner = NotificationPlanner(
  clock: FakeClock(DateTime.utc(2026, 10, 21, 5)),
  horizon: const Duration(days: 2),
);

final _days = [
  _task('wed', DateTime.utc(2026, 10, 21, 9)),
  _task('thu', DateTime.utc(2026, 10, 22, 9)),
];

List<PlannedNotification> _plan({Set<DateTime> armed = const {}}) =>
    _planner.plan(
      occurrences: _days,
      tzId: 'UTC',
      daily: _on,
      startSound: _on.startSoundId,
      ringsWakeUp: true,
      armedWakeUps: armed,
    );

Iterable<PlannedNotification> _wakeUps(List<PlannedNotification> plan) =>
    plan.where((n) => n.purpose == NotificationPurpose.wakeUp);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  group('planner', () {
    test('wakeUps() is what plan() rings', () {
      final listed = _planner.wakeUps(
        occurrences: _days,
        tzId: 'UTC',
        daily: _on,
        ringsWakeUp: true,
      );
      expect(
        listed.map((w) => w.fireAtUtc),
        _wakeUps(_plan()).map((w) => w.fireAtUtc),
      );
    });

    test('an armed instant is left out; the rest still ring', () {
      final plan = _plan(armed: {DateTime.utc(2026, 10, 21, 7)});
      expect(_wakeUps(plan).map((w) => w.fireAtUtc), [
        DateTime.utc(2026, 10, 22, 7),
      ]);
    });

    test('armed or not, the first dot near Wake Up stays a normal ping', () {
      final plan = _plan(
        armed: {DateTime.utc(2026, 10, 21, 7), DateTime.utc(2026, 10, 22, 7)},
      );
      expect(_wakeUps(plan), isEmpty);
      final wed = _planner.plan(
        occurrences: [_task('wed', DateTime.utc(2026, 10, 21, 7, 20))],
        tzId: 'UTC',
        daily: _on,
        ringsWakeUp: true,
        armedWakeUps: {DateTime.utc(2026, 10, 21, 7)},
      );
      expect(wed.where((n) => n.loud), isEmpty);
    });

    test('off, or not a phone: wakeUps() is empty', () {
      expect(
        _planner.wakeUps(
          occurrences: _days,
          tzId: 'UTC',
          daily: const Settings(),
          ringsWakeUp: true,
        ),
        isEmpty,
      );
      expect(
        _planner.wakeUps(occurrences: _days, tzId: 'UTC', daily: _on),
        isEmpty,
      );
    });
  });

  group('sound', () {
    final day = DateTime(2026, 11, 2);

    test('unset follows the Start sound; set wins', () {
      expect(
        wakeUpSound(const Settings(startSoundId: 'start.bells'), day).id,
        'start.bells',
      );
      expect(
        wakeUpSound(
          const Settings(
            startSoundId: 'start.bells',
            wakeUpSoundId: 'start.sunrise',
          ),
          day,
        ).id,
        'start.sunrise',
      );
    });

    test('varied: the same date always gets the same cue', () {
      const vary = Settings(wakeUpVarySound: true);
      expect(wakeUpSound(vary, day), wakeUpSound(vary, DateTime(2026, 11, 2)));
    });

    test('varied: each next day the next cue, never the insistent one', () {
      const vary = Settings(wakeUpVarySound: true);
      final week = [
        for (var i = 0; i < wakeUpRotation.length; i++)
          wakeUpSound(vary, day.add(Duration(days: i))),
      ];
      expect(week.toSet(), hasLength(wakeUpRotation.length));
      expect(week.map((s) => s.id), isNot(contains(insistentStartSoundId)));
      final first = wakeUpRotation.indexOf(week.first);
      expect(week[1], wakeUpRotation[(first + 1) % wakeUpRotation.length]);
    });

    test('the planner rings each day with its own cue', () {
      final varied = _planner.wakeUps(
        occurrences: _days,
        tzId: 'UTC',
        daily: _on.copyWith(wakeUpVarySound: true),
        ringsWakeUp: true,
      );
      expect(varied.map((w) => w.sound).toSet(), hasLength(2));
    });
  });
}
