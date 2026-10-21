import 'package:dottoday/domain/entities/enums.dart';
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
  });

  test('DST days are 23 and 25 h long', () {
    expect(TimelineDay.of(DateTime(2026, 3, 29), berlin).minutes, 1380);
    expect(TimelineDay.of(DateTime(2026, 10, 25), berlin).minutes, 1500);
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
