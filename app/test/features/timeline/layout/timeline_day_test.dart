import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/features/timeline/layout/timeline_day.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../domain/fixtures.dart';

void main() {
  late tz.Location berlin;
  setUpAll(() {
    tz_data.initializeTimeZones();
    berlin = tz.getLocation('Europe/Berlin');
  });

  test('a normal day is 24 h from local midnight', () {
    final d = TimelineDay.of(DateTime(2026, 10, 21), berlin);
    expect(d.startUtc, DateTime.utc(2026, 10, 20, 22));
    expect(d.endUtc, DateTime.utc(2026, 10, 21, 22));
    expect(d.minutes, 1440);
    expect(d.weekday, Weekday.wed);
    expect(d.hourMarks, hasLength(24));
  });

  test('spring-forward day is 23 h and skips the 02:00 label', () {
    final d = TimelineDay.of(DateTime(2026, 3, 29), berlin);
    expect(d.minutes, 1380);
    final labels = d.hourMarks.map((h) => h.label.hour).toList();
    expect(labels.take(4), [0, 1, 3, 4]);
    expect(labels, hasLength(23));
  });

  test('fall-back day is 25 h and repeats the 02:00 label', () {
    final d = TimelineDay.of(DateTime(2026, 10, 25), berlin);
    expect(d.minutes, 1500);
    final labels = d.hourMarks.map((h) => h.label.hour).toList();
    expect(labels.take(5), [0, 1, 2, 2, 3]);
  });

  test('core minutes come from the day boundary; wrapping means whole day', () {
    final d = TimelineDay.of(DateTime(2026, 10, 21), berlin);
    expect(d.coreMinutes(const TimeWindow(start: '07:00', end: '22:00')), (
      420,
      1320,
    ));
    expect(d.coreMinutes(const TimeWindow(start: '22:00', end: '06:00')), (
      0,
      1440,
    ));
    expect(d.coreMinutes(const TimeWindow(start: 'x', end: '06:00')), (
      0,
      1440,
    ));
  });

  test('core minutes are elapsed minutes on a DST day', () {
    final d = TimelineDay.of(DateTime(2026, 10, 25), berlin);
    final (from, _) = d.coreMinutes(
      const TimeWindow(start: '07:00', end: '22:00'),
    );
    expect(from, 480); // 07:00 is 8 elapsed hours after midnight
  });

  test('all-day = starts at local midnight and lasts 24 h', () {
    final d = TimelineDay.of(DateTime(2026, 10, 21), berlin);
    final o = occurrenceFixture().copyWith(startUtc: d.startUtc);
    expect(d.isAllDay(o.copyWith(durationMin: 1440)), isTrue);
    expect(d.isAllDay(o.copyWith(durationMin: 600)), isFalse);
    final later = o.copyWith(
      startUtc: const ClockTime(1, 0).onDate(berlin, d.date),
      durationMin: 1440,
    );
    expect(d.isAllDay(later), isFalse);
  });
}
