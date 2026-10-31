import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:timezone/timezone.dart' as tz;

import 'timeline_fakes.dart';

// The weekly review's week (`B-ios-week-review`): Sun 18 – Sat 24 Oct 2026
// in Berlin, 29 of 34 done, Thursday the busiest and Saturday the lightest.
// Done morning tasks really started on plan (B1), so the sentence opens
// "Mornings mostly went to plan." Unfinished: one one-off on Tuesday, one
// one-off and one repeat on Thursday, one one-off and one calendar event
// on Saturday — three move, two stay.

const _colors = ['coral', 'indigo', 'teal', 'violet', 'rose', 'amber', 'sky'];
const _icons = ['run', 'code', 'mail', 'book', 'food', 'list', 'calendar'];

/// (tasks, done, minutes each) per day, Sunday first.
const _shape = [
  (4, 4, 45),
  (6, 6, 50),
  (5, 4, 40),
  (5, 5, 45),
  (7, 5, 65),
  (4, 4, 45),
  (3, 1, 30),
];

/// The repeat Thursday's last task belongs to (`seriesFixture`'s id).
const reviewSeriesId = '01928c3e-0000-7000-8000-0000000000a1';

/// The review week's sunday.
final reviewSunday = DateTime(2026, 10, 18);

/// Sunday 25 Oct 2026, 22:30 in Berlin: past Wind Down, the review's day.
final reviewNow = DateTime.utc(2026, 10, 25, 21, 30);

/// Thirty-four tasks over the review week.
List<Occurrence> weekReviewRows() {
  final berlin = tz.getLocation('Europe/Berlin');
  return [
    for (final (day, (count, done, minutes)) in _shape.indexed)
      for (var i = 0; i < count; i++)
        _task(berlin, day, i, minutes, done: i < done, count: count),
  ];
}

Occurrence _task(
  tz.Location berlin,
  int day,
  int i,
  int minutes, {
  required bool done,
  required int count,
}) {
  final start = tz.TZDateTime(
    berlin,
    2026,
    10,
    18 + day,
    7,
    30,
  ).add(Duration(minutes: i * (minutes + 15))).toUtc();
  // Thursday's last is a repeat, Saturday's last an event: both stay.
  final repeat = day == 4 && i == count - 1;
  final event = day == 6 && i == count - 1;
  return Occurrence(
    id: 'wk-$day-$i',
    userId: testUserId,
    title: 'Task ${day + 1}.${i + 1}',
    colorKey: _colors[(day + i) % _colors.length],
    iconKey: _icons[i % _icons.length],
    startUtc: start,
    tzId: berlin.name,
    durationMin: minutes,
    status: done ? OccurrenceStatus.done : OccurrenceStatus.planned,
    seriesId: repeat ? reviewSeriesId : null,
    originalStartUtc: repeat ? start : null,
    source: event ? OccurrenceSource.calendar : OccurrenceSource.user,
    actualStartUtc: done ? start.add(const Duration(minutes: 5)) : null,
    actualEndUtc: done ? start.add(Duration(minutes: minutes)) : null,
    createdAt: DateTime.utc(2026, 10, 17),
    updatedAt: DateTime.utc(2026, 10, 17),
  );
}
