import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/proposals/carry_proposal.dart';
import 'package:dottoday/domain/review/week_review.dart';
import 'package:dottoday/domain/scheduling/day_review.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/domain/time/wind_down.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The day's Wake Up → Wind Down from its timeline data.
DayShape shapeOf(TimelineData d) => DayShape.on(
  d.day.location,
  d.day.date,
  d.settings.boundaryFor(d.day.weekday),
);

/// [data]'s seven days as the review reads them (11 D1, docs/09 M12.1).
WeekReview weekReviewOf(List<TimelineData> data) => WeekReview.of([
  for (final d in data)
    WeekReviewDay(
      date: d.day.date,
      snapshot: DaySnapshot.ofDay(
        blocks: d.blocks,
        shape: shapeOf(d),
        // The night after it, on the review's dots (docs/15 W6).
        tomorrowWakeUtc: d.settings.showNightArc
            ? nextWakeUtc(d.day.location, d.day.date, d.settings)
            : null,
      ),
    ),
], data.first.day.location);

/// One-off tasks left unfinished on the week's days up to [today]: what
/// "move them to next week?" offers (repeating tasks come round again and
/// calendar events stay with their calendar, as in the Day review).
List<Occurrence> unfinishedOf(List<TimelineData> data, DateTime today) => [
  for (final d in data)
    if (!d.day.date.isAfter(today)) ...reviewOf(d.blocks).movable,
];

/// The seven days after the review week, read (and held while read) so
/// "Place" can find free slots in them.
Future<List<CarryDay>> nextWeekDays(
  ProviderContainer container,
  List<DateTime> week,
) async {
  final last = week.last;
  final days = <CarryDay>[];
  for (var i = 1; i <= DateTime.daysPerWeek; i++) {
    final d = await readTimelineDay(
      container,
      DateTime(last.year, last.month, last.day + i),
    );
    final shape = shapeOf(d);
    days.add(
      CarryDay(blocks: d.blocks, wakeUtc: shape.wakeUtc, bedUtc: shape.bedUtc),
    );
  }
  return days;
}
