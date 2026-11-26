import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/onboarding/habit_days.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// "Make it a habit" (M20.11 part 6, ED-491).

Occurrence _day(int d, {bool done = true}) => Occurrence(
  id: 'o$d',
  userId: 'u',
  title: 'Gym',
  startUtc: DateTime.utc(2026, 10, d, 16),
  tzId: 'Europe/Berlin',
  durationMin: 60,
  status: done ? OccurrenceStatus.done : OccurrenceStatus.planned,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

void main() {
  tz_data.initializeTimeZones();
  final berlin = tz.getLocation('Europe/Berlin');

  test('three done: the weekdays they fell on', () {
    // Mon 12, Wed 14, Fri 16 October 2026.
    expect(
      habitDays([_day(12), _day(14), _day(16), _day(13, done: false)], berlin),
      {Weekday.mon, Weekday.wed, Weekday.fri},
    );
  });

  test('fewer than three done: nothing yet', () {
    expect(
      habitDays([_day(12), _day(14), _day(15, done: false)], berlin),
      isNull,
    );
  });

  test('done every day of the week: nothing to narrow', () {
    expect(habitDays([for (var d = 12; d <= 18; d++) _day(d)], berlin), isNull);
  });
}
