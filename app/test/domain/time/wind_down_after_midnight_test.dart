import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/scheduling/low_energy.dart' as energy;
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/domain/time/wind_down.dart';
import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../support/fake_clock.dart';
import '../fixtures.dart';

// Wind Down after midnight (Q8, docs/05 "Day boundaries"): the window end
// counts from the day's own midnight, so 00:30 the next morning is 24:30,
// and it still belongs to the day it closes.

const _late = TimeWindow(start: '07:00', end: '24:30');

void main() {
  setUpAll(tz_data.initializeTimeZones);
  late tz.Location berlin;
  late tz.Location newYork;
  setUp(() {
    berlin = tz.getLocation('Europe/Berlin');
    newYork = tz.getLocation('America/New_York');
  });

  group('stored form', () {
    test('a pick at or before Wake Up is stored a day on', () {
      expect(windDownMinute(420, 30), 1470);
      expect(windDownMinute(420, 420), 1860);
      expect(windDownMinute(420, 1320), 1320);
      expect(windDownMinute(420, 1440), 1440);
      expect(windowTime(1470), '24:30');
      expect(windowMinutes('24:30'), 1470);
    });

    test('dayWindow keeps every edit valid', () {
      expect(dayWindow(420, 30), _late);
      expect(dayWindow(420, 1320).end, '22:00');
      // Wake Up moved past an after-midnight Wind Down's wall clock.
      expect(dayWindow(600, 1470).end, '24:30');
      expect(checkDayWindow(dayWindow(1380, 60)), isNull); // 23:00–25:00
    });

    test('a Wind Down cap picked after midnight belongs to that day', () {
      final s = withCapAt(
        const Settings(),
        Weekday.fri,
        windDown: true,
        minute: 45,
        everyDay: false,
      );
      expect(
        s.boundaryFor(Weekday.fri),
        const TimeWindow(start: '07:00', end: '24:45'),
      );
      expect(s.boundaryFor(Weekday.thu).end, '22:00');
    });

    test('only an end past midnight is "next day"', () {
      expect(windDownNextDay(1320), isFalse);
      expect(windDownNextDay(1440), isFalse);
      expect(windDownNextDay(1470), isTrue);
    });

    test('tryWindowMinutes refuses malformed text', () {
      expect(tryWindowMinutes('24:30'), 1470);
      expect(tryWindowMinutes('7:00'), isNull);
      expect(tryWindowMinutes('48:00'), isNull);
      expect(tryWindowMinutes('22:60'), isNull);
    });

    test('validation: after Wake Up and under 24 h later', () {
      expect(checkDayWindow(_late), isNull);
      expect(
        checkDayWindow(const TimeWindow(start: '07:00', end: '24:00')),
        isNull,
      );
      expect(
        checkDayWindow(const TimeWindow(start: '07:00', end: '06:00')),
        isNotNull,
      );
      expect(
        checkDayWindow(const TimeWindow(start: '07:00', end: '31:00')),
        isNotNull,
      );
      expect(
        checkDayWindow(const TimeWindow(start: '24:00', end: '25:00')),
        isNotNull,
      );
    });
  });

  group('DayShape', () {
    test('24:30 falls at 00:30 the next morning', () {
      final s = DayShape.on(berlin, DateTime(2026, 10, 21), _late);
      expect(s.wakeUtc, DateTime.utc(2026, 10, 21, 5));
      expect(s.bedUtc, DateTime.utc(2026, 10, 21, 22, 30));
      expect(s.awakeMinutes, 17 * 60 + 30);
    });

    test('24:00 is midnight, no longer read as 22:00', () {
      final s = DayShape.on(
        berlin,
        DateTime(2026, 10, 21),
        const TimeWindow(start: '07:00', end: '24:00'),
      );
      expect(s.bedUtc, DateTime.utc(2026, 10, 21, 22));
    });

    test('an older end at or before Wake Up is read as after midnight', () {
      final s = DayShape.on(
        berlin,
        DateTime(2026, 10, 21),
        const TimeWindow(start: '07:00', end: '00:30'),
      );
      expect(s.bedUtc, DateTime.utc(2026, 10, 21, 22, 30));
    });

    test('Berlin spring forward: a Wind Down in the gap moves on', () {
      // Sun 2026-03-29 02:00 CET → 03:00 CEST.
      final s = DayShape.on(
        berlin,
        DateTime(2026, 3, 28),
        const TimeWindow(start: '07:00', end: '26:30'),
      );
      expect(s.wakeUtc, DateTime.utc(2026, 3, 28, 6));
      expect(s.bedUtc, DateTime.utc(2026, 3, 29, 1, 30)); // 03:30 CEST
    });

    test('Berlin fall back: the earlier 01:30 wins', () {
      // Sun 2026-10-25 03:00 CEST → 02:00 CET.
      final s = DayShape.on(
        berlin,
        DateTime(2026, 10, 24),
        const TimeWindow(start: '07:00', end: '25:30'),
      );
      expect(s.bedUtc, DateTime.utc(2026, 10, 24, 23, 30)); // 01:30 CEST
    });

    test('New York spring forward and fall back', () {
      final spring = DayShape.on(
        newYork,
        DateTime(2026, 3, 7),
        const TimeWindow(start: '08:00', end: '26:15'),
      );
      expect(spring.bedUtc, DateTime.utc(2026, 3, 8, 7, 15)); // 03:15 EDT
      final fall = DayShape.on(
        newYork,
        DateTime(2026, 10, 31),
        const TimeWindow(start: '08:00', end: '25:00'),
      );
      expect(fall.bedUtc, DateTime.utc(2026, 11, 1, 5)); // 01:00 EDT
    });
  });

  group('the day the clock belongs to', () {
    // Wed 2026-10-21 has Wind Down 24:30; Thursday keeps 07:00–22:00.
    const settings = Settings(dayBoundaries: {Weekday.wed: _late});

    test('after midnight, before the late Wind Down: still Wednesday', () {
      final at0015 = DateTime.utc(2026, 10, 21, 22, 15);
      expect(DayShape.dayOf(berlin, at0015, settings), DateTime(2026, 10, 21));
      final shape = DayShape.containing(berlin, at0015, settings);
      expect(shape.bedUtc, DateTime.utc(2026, 10, 21, 22, 30));
    });

    test('at the Wind Down itself, still Wednesday; after it, Thursday', () {
      expect(
        DayShape.dayOf(berlin, DateTime.utc(2026, 10, 21, 22, 30), settings),
        DateTime(2026, 10, 21),
      );
      expect(
        DayShape.dayOf(berlin, DateTime.utc(2026, 10, 21, 23), settings),
        DateTime(2026, 10, 22),
      );
    });

    test("low-energy mode still ends at Thursday's Wake Up", () {
      final at0015 = DateTime.utc(2026, 10, 21, 22, 15);
      expect(
        energy.nextWakeUtc(berlin, at0015, settings),
        DateTime.utc(2026, 10, 22, 5),
      );
    });
  });

  group('effective Wind Down', () {
    test('a late Wind Down is held at the next Wake Up', () {
      // Wednesday ends 30:00 (06:00 Thu); Thursday wakes at 05:00.
      const s = Settings(
        dayBoundaries: {
          Weekday.wed: TimeWindow(start: '07:00', end: '30:00'),
          Weekday.thu: TimeWindow(start: '05:00', end: '22:00'),
        },
      );
      final shape = effectiveDayShape(
        berlin,
        DateTime(2026, 10, 21),
        s,
        nowUtc: DateTime.utc(2026, 10, 21, 8),
        tomorrowHasThread: false,
      );
      expect(shape.bedUtc, DateTime.utc(2026, 10, 22, 3)); // 05:00 Thu
      expect(
        nightMinutes(
          shape.bedUtc,
          nextWakeUtc(berlin, DateTime(2026, 10, 21), s),
        ),
        0,
      );
    });

    test('a sleep target can pull a late Wind Down to before midnight', () {
      // Wake Thu 06:00 − 8 h = 22:00 Wed, earlier than 24:30.
      const s = Settings(
        sleepTargetMin: 480,
        dayBoundaries: {
          Weekday.wed: _late,
          Weekday.thu: TimeWindow(start: '06:00', end: '22:00'),
        },
      );
      final shape = effectiveDayShape(
        berlin,
        DateTime(2026, 10, 21),
        s,
        nowUtc: DateTime.utc(2026, 10, 21, 8),
        tomorrowHasThread: true,
      );
      expect(shape.bedUtc, DateTime.utc(2026, 10, 21, 20));
    });
  });

  group('the Wind Down reminder', () {
    List<PlannedNotification> windDowns(Settings s, DateTime now) =>
        NotificationPlanner(clock: FakeClock(now))
            .plan(
              occurrences: const <Occurrence>[],
              tzId: 'Europe/Berlin',
              quietHours: s.quietHours,
              daily: s,
            )
            .where((n) => n.purpose == NotificationPurpose.windDown)
            .toList();

    const s = Settings(dayBoundaries: {Weekday.wed: _late});

    test('fires once, at 00:30, for the day it closes', () {
      final fire = windDowns(
        s,
        DateTime.utc(2026, 10, 21, 8),
      ).map((n) => n.fireAtUtc).toList();
      expect(
        fire.where((f) => f == DateTime.utc(2026, 10, 21, 22, 30)),
        hasLength(1),
      );
      expect(fire, isNot(contains(DateTime.utc(2026, 10, 21, 20))));
    });

    test('planned after midnight, it is still there, with the same id', () {
      final before = windDowns(s, DateTime.utc(2026, 10, 21, 8));
      final after = windDowns(s, DateTime.utc(2026, 10, 21, 22, 10));
      final late = DateTime.utc(2026, 10, 21, 22, 30);
      final a = before.singleWhere((n) => n.fireAtUtc == late);
      final b = after.singleWhere((n) => n.fireAtUtc == late);
      expect(b.id, a.id);
    });

    test('Wake Up alarms are not doubled by looking a day back', () {
      final wakeUps =
          NotificationPlanner(
            clock: FakeClock(DateTime.utc(2026, 10, 21, 8)),
          ).wakeUps(
            occurrences: [
              occurrenceFixture().copyWith(
                id: 'thu',
                startUtc: DateTime.utc(2026, 10, 22, 7),
                tzId: 'Europe/Berlin',
              ),
            ],
            tzId: 'Europe/Berlin',
            daily: s.copyWith(wakeUpAlarm: true),
            ringsWakeUp: true,
          );
      expect(wakeUps.map((n) => n.fireAtUtc), [DateTime.utc(2026, 10, 22, 5)]);
    });
  });
}
