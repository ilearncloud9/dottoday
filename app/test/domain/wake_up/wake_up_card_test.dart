import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/domain/wake_up/wake_up_card.dart';
import 'package:dottoday/domain/wake_up/wake_up_day.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../fixtures.dart';

// When the Wake Up card opens by itself, and what it offers (docs/15 §5,
// §11, M17.3).

const _on = Settings(wakeUpAlarm: true);
const _today = WakeUpDay(date: '2026-11-02');

void main() {
  setUpAll(tz_data.initializeTimeZones);

  // Wake Up 07:00, Wind Down 23:00 (the default window), in UTC.
  late DayShape shape;
  setUp(
    () => shape = DayShape.on(
      tz.getLocation('UTC'),
      DateTime(2026, 11, 2),
      const Settings().boundaryFor(Weekday.mon),
    ),
  );
  DateTime at(int h, [int m = 0]) => DateTime.utc(2026, 11, 2, h, m);

  bool due({
    WakeUpDay? day,
    DateTime? now,
    Settings settings = _on,
    bool hasThread = true,
    bool firstOpen = true,
  }) => wakeUpCardDue(
    day: day,
    shape: shape,
    nowUtc: now ?? at(7, 20),
    settings: settings,
    hasThread: hasThread,
    firstOpen: firstOpen,
  );

  group('on', () {
    test('unset follows the Wake Up alarm; a choice wins (15 §11)', () {
      expect(wakeUpCardOn(const Settings()), isFalse);
      expect(wakeUpCardOn(_on), isTrue);
      expect(wakeUpCardOn(const Settings(wakeUpCard: true)), isTrue);
      expect(wakeUpCardOn(_on.copyWith(wakeUpCard: false)), isFalse);
    });
  });

  group('due', () {
    test('first open after Wake Up, on a day with a thread', () {
      expect(due(), isTrue);
      expect(due(now: at(6, 59)), isFalse, reason: 'before Wake Up');
      expect(due(now: at(10)), isFalse, reason: 'past Wake Up + 3 h');
      expect(due(hasThread: false), isFalse);
      expect(due(settings: _on.copyWith(wakeUpCardOnOpen: false)), isFalse);
    });

    test('never for anyone who has not said yes to Wake Up', () {
      expect(due(settings: const Settings()), isFalse);
    });

    test('once a day', () {
      expect(due(day: _today.copyWith(cardShownAtUtc: at(7, 5))), isFalse);
    });

    test("after I'm up: within 3 h of it, even without a thread", () {
      final up = _today.copyWith(stoppedAtUtc: at(8));
      expect(due(day: up, now: at(10, 30), hasThread: false), isTrue);
      expect(due(day: up, now: at(11, 1)), isFalse);
    });

    test("minimal mode: only after I'm up (15 §10)", () {
      expect(due(firstOpen: false), isFalse);
      expect(
        due(day: _today.copyWith(stoppedAtUtc: at(7, 10)), firstOpen: false),
        isTrue,
      );
    });

    test('never at or after Wind Down', () {
      expect(
        due(
          day: _today.copyWith(stoppedAtUtc: at(23)),
          now: at(23, 5),
        ),
        isFalse,
      );
    });
  });

  group('late start', () {
    test("from I'm up, at the threshold and over", () {
      int? late(WakeUpDay? day, {Settings settings = _on, DateTime? now}) =>
          lateStartMin(
            day: day,
            shape: shape,
            nowUtc: now ?? at(9),
            settings: settings,
          );
      expect(late(_today.copyWith(stoppedAtUtc: at(7, 9))), isNull);
      expect(late(_today.copyWith(stoppedAtUtc: at(7, 10))), 10);
      expect(late(_today.copyWith(stoppedAtUtc: at(7, 25))), 25);
      expect(late(null, now: at(7, 40)), 40, reason: 'nothing rang: now');
      expect(late(null, now: at(10)), 180, reason: 'the last minute');
      expect(late(null, now: at(22, 27)), isNull, reason: 'a morning offer');
      expect(
        late(
          _today.copyWith(stoppedAtUtc: at(7, 25)),
          settings: _on.copyWith(wakeUpLateOffer: false),
        ),
        isNull,
      );
      expect(
        late(
          _today.copyWith(stoppedAtUtc: at(7, 25)),
          settings: _on.copyWith(wakeUpLateMin: 30),
        ),
        isNull,
      );
    });
  });

  group('start', () {
    test('the first dot within 15 min, else the day is marked', () {
      final run = occurrenceFixture().copyWith(startUtc: at(7, 30));
      expect(startDot(run, at(7, 15)), run);
      expect(startDot(run, at(7, 40)), run, reason: 'already under way');
      expect(startDot(run, at(7, 14)), isNull);
      expect(startDot(null, at(7)), isNull);
    });
  });

  group('the mission an event leaves open (15 §8, iOS)', () {
    final at = DateTime.utc(2026, 11, 2, 6);
    AlarmEvent e(AlarmEventKind kind, {String? mission, int min = 0}) =>
        AlarmEvent(
          'wakeup:2026-11-02',
          kind,
          at.add(Duration(minutes: min)),
          mission: mission,
        );

    test('the last mission no stop ended', () {
      expect(
        openMission([
          e(AlarmEventKind.rang),
          e(AlarmEventKind.mission, mission: 'walk', min: 1),
        ]),
        ('2026-11-02', 'walk'),
      );
    });

    test('a later stop ends it; a ring alone opens nothing', () {
      expect(
        openMission([
          e(AlarmEventKind.mission, mission: 'walk'),
          e(AlarmEventKind.stopped, min: 3),
        ]),
        isNull,
      );
      expect(openMission([e(AlarmEventKind.rang)]), isNull);
    });

    test('a mission event leaves the day as it was', () {
      const day = WakeUpDay(date: '2026-11-02', snoozes: 1);
      expect(
        applyAlarmEvent(day, e(AlarmEventKind.mission, mission: 'walk')),
        day,
      );
    });
  });

  group('alarm events', () {
    test('first ring counts, snoozes add up, the last stop wins', () {
      var day = _today;
      for (final e in [
        AlarmEvent('wakeup:2026-11-02', AlarmEventKind.rang, at(7)),
        AlarmEvent('wakeup:2026-11-02', AlarmEventKind.snoozed, at(7, 1)),
        AlarmEvent('wakeup:2026-11-02', AlarmEventKind.rang, at(7, 10)),
        AlarmEvent('wakeup:2026-11-02', AlarmEventKind.snoozed, at(7, 11)),
        AlarmEvent('wakeup:2026-11-02', AlarmEventKind.stopped, at(7, 20)),
      ]) {
        day = applyAlarmEvent(day, e);
      }
      expect(day.rangAtUtc, at(7));
      expect(day.snoozes, 2);
      expect(day.stoppedAtUtc, at(7, 20));
    });

    test("the test alarm's events belong to no day", () {
      expect(
        AlarmEvent('wakeup:test', AlarmEventKind.stopped, at(7)).date,
        isNull,
      );
      expect(
        AlarmEvent('wakeup:2026-11-02', AlarmEventKind.stopped, at(7)).date,
        '2026-11-02',
      );
    });
  });
}
