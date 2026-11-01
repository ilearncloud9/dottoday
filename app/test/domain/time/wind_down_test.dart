import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/day_dot_geometry.dart';
import 'package:dottoday/domain/time/wind_down.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// Wind Down from tomorrow's Wake Up and the night on the day dot (docs/15
// W4, W6): pure, derived, never stored.

void main() {
  // Zones are read while the groups are declared.
  tz_data.initializeTimeZones();

  group('effective Wind Down (15 W4 AC table)', () {
    final berlin = tz.getLocation('Europe/Berlin');
    // Wed 21 Oct 2026, CEST (UTC+2): Wake Up 07:00, Wind Down 22:00.
    final wed = DateTime(2026, 10, 21);
    final noon = DateTime.utc(2026, 10, 21, 10);
    const day = Settings();
    DateTime windDown(
      Settings s, {
      DateTime? date,
      DateTime? now,
      bool tomorrow = true,
    }) => effectiveDayShape(
      berlin,
      date ?? wed,
      s,
      nowUtc: now ?? noon,
      tomorrowHasThread: tomorrow,
    ).bedUtc;
    DateTime local(int d, int h, [int m = 0]) =>
        DateTime.fromMillisecondsSinceEpoch(
          tz.TZDateTime(berlin, 2026, 10, d, h, m).millisecondsSinceEpoch,
          isUtc: true,
        );

    for (final (target, expected, why) in [
      (null, local(21, 22), 'no target: as set'),
      (8 * 60, local(21, 22), 'tomorrow 07:00 − 8 h = 23:00, later: as set'),
      (9 * 60 + 30, local(21, 21, 30), '07:00 − 9 h 30 = 21:30'),
      (10 * 60, local(21, 21), '07:00 − 10 h'),
    ]) {
      test(why, () {
        expect(windDown(day.copyWith(sleepTargetMin: target)), expected);
      });
    }

    test('tomorrow has no thread: as set', () {
      expect(
        windDown(day.copyWith(sleepTargetMin: 10 * 60), tomorrow: false),
        local(21, 22),
      );
    });

    test('derived within an hour of now: as set, nothing said', () {
      expect(
        windDown(day.copyWith(sleepTargetMin: 10 * 60), now: local(21, 20, 30)),
        local(21, 22),
      );
    });

    test('across the DST change (Sun 25 Oct 2026, CEST → CET)', () {
      // Sat 24 Oct: tomorrow's 07:00 is CET (UTC+1) = 06:00Z; − 9 h 15 =
      // 20:45Z = 22:45 CEST the night before, earlier than 23:00.
      final sat = DateTime(2026, 10, 24);
      final s = day.copyWith(
        sleepTargetMin: 9 * 60 + 15,
        dayBoundaries: {
          for (final w in Weekday.values)
            w: const TimeWindow(start: '07:00', end: '23:00'),
        },
      );
      expect(
        windDown(s, date: sat, now: DateTime.utc(2026, 10, 24, 10)),
        DateTime.utc(2026, 10, 24, 20, 45),
      );
    });
  });

  group('the night on the day dot (15 W6)', () {
    final wake = DateTime.utc(2026, 11, 2, 6);
    DayDotGeometry at(int bedHour, {DateTime? now, bool night = true}) =>
        dayDotGeometry(
          wakeUtc: wake,
          windDownUtc: wake.add(Duration(hours: bedHour - 6)),
          nextWakeUtc: wake.add(const Duration(days: 1)),
          nowUtc: now ?? wake.add(const Duration(hours: 4)),
          night: night,
        );

    test('5 h, 8 h and 10 h nights: the day ends where the night starts', () {
      expect(at(25).dayEnd, closeTo(19 / 24, 1e-9)); // 5 h night
      expect(at(22).dayEnd, closeTo(16 / 24, 1e-9)); // 8 h
      expect(at(20).dayEnd, closeTo(14 / 24, 1e-9)); // 10 h
    });

    test('the fill runs inside the day, never into the night', () {
      final g = at(22);
      expect(g.progress, closeTo(4 / 24, 1e-9));
      expect(g.dayShare, closeTo(4 / 16, 1e-9));
      expect(
        at(22, now: wake.add(const Duration(hours: 20))).progress,
        closeTo(16 / 24, 1e-9),
      );
    });

    test('off, or no next Wake Up: the day takes the whole ring', () {
      expect(at(22, night: false).dayEnd, 1);
      expect(
        dayDotGeometry(
          wakeUtc: wake,
          windDownUtc: wake.add(const Duration(hours: 16)),
          nowUtc: wake,
        ).hasNight,
        isFalse,
      );
    });

    test('night length, never negative', () {
      expect(nightMinutes(wake, wake.add(const Duration(hours: 7))), 420);
      expect(nightMinutes(wake, wake.subtract(const Duration(hours: 1))), 0);
    });
  });
}
