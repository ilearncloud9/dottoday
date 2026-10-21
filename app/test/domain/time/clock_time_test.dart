import 'package:dottoday/domain/time/clock_time.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  group('parse', () {
    const cases = <String, ClockTime?>{
      '9': ClockTime(9, 0),
      '09': ClockTime(9, 0),
      '930': ClockTime(9, 30),
      '0930': ClockTime(9, 30),
      '1745': ClockTime(17, 45),
      '0': ClockTime(0, 0),
      '9:30': ClockTime(9, 30),
      '9.30': ClockTime(9, 30),
      '9h30': ClockTime(9, 30),
      '15h': ClockTime(15, 0),
      '9 30': ClockTime(9, 30),
      '23:59': ClockTime(23, 59),
      ' 7:05 ': ClockTime(7, 5),
      '12am': ClockTime(0, 0),
      '12:00 AM': ClockTime(0, 0),
      '12:30 a.m.': ClockTime(0, 30),
      '12pm': ClockTime(12, 0),
      '12:00 PM': ClockTime(12, 0),
      '7pm': ClockTime(19, 0),
      '7 p': ClockTime(19, 0),
      '1130pm': ClockTime(23, 30),
      '11:59 p.m.': ClockTime(23, 59),
      '24:00': null,
      '9:60': null,
      '9:3': null,
      '13pm': null,
      '0am': null,
      '12345': null,
      '': null,
      'noon': null,
      '9:30:15': null,
      '-1': null,
    };
    for (final MapEntry(key: input, value: want) in cases.entries) {
      test('"$input" → $want', () => expect(ClockTime.parse(input), want));
    }
  });

  test('fromMinutes wraps into one day', () {
    expect(ClockTime.fromMinutes(90), const ClockTime(1, 30));
    expect(ClockTime.fromMinutes(1440 + 5), const ClockTime(0, 5));
    expect(ClockTime.fromMinutes(-10), const ClockTime(23, 50));
  });

  test('ordering and toString', () {
    expect(const ClockTime(9, 5).compareTo(const ClockTime(10, 0)), isNegative);
    expect(const ClockTime(9, 5).toString(), '09:05');
    expect(const ClockTime(9, 5).hashCode, 545);
  });

  group('onDate never changes the calendar day (R-20)', () {
    late tz.Location berlin;
    setUp(() => berlin = tz.getLocation('Europe/Berlin'));

    test('late evening stays on the same local day', () {
      final utc = const ClockTime(23, 30).onDate(berlin, DateTime(2026, 7, 1));
      final local = tz.TZDateTime.from(utc, berlin);
      expect((local.year, local.month, local.day), (2026, 7, 1));
      expect((local.hour, local.minute), (23, 30));
    });

    test('just after midnight stays on the given day', () {
      final utc = const ClockTime(0, 15).onDate(berlin, DateTime(2026, 7, 1));
      final local = tz.TZDateTime.from(utc, berlin);
      expect(local.day, 1);
    });

    test('DST gap resolves forward on the same day', () {
      final utc = const ClockTime(2, 30).onDate(berlin, DateTime(2026, 3, 29));
      final local = tz.TZDateTime.from(utc, berlin);
      expect((local.day, local.hour, local.minute), (29, 3, 30));
    });

    test('ofUtc round-trips', () {
      final utc = const ClockTime(8, 45).onDate(berlin, DateTime(2026, 1, 5));
      expect(ClockTime.ofUtc(berlin, utc), const ClockTime(8, 45));
    });
  });
}
