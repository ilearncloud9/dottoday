import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/day_capacity.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:dottoday/shared/dot/week_strip.dart';

/// "2 of 7 · 5 h 45 planned" for a day's timed [blocks] (docs/10 §3
/// `DayCard`). Skipped tasks count as neither planned nor to do; free time
/// is what no task occupies between Wake Up and Bedtime (overlaps counted
/// once, tasks outside the waking day ignored — domain `capacityOf`).
DaySummary daySummaryOf(List<Occurrence> blocks, DayShape shape) {
  final active = [
    for (final o in blocks)
      if (o.status != OccurrenceStatus.skipped) o,
  ];
  final planned = active.fold(0, (sum, o) => sum + o.durationMin);
  return DaySummary(
    done: active.where((o) => o.status == OccurrenceStatus.done).length,
    total: active.length,
    plannedMinutes: planned,
    freeMinutes: capacityOf(active, shape).freeMinutes,
  );
}

/// The completion dot of a day (docs/10 §3 `WeekStrip`): the share done
/// once the day has begun, an outline for a day ahead or with nothing
/// planned.
Completion completionOf(List<Occurrence> blocks, {required bool begun}) {
  final s = doneCounts(blocks);
  if (!begun || s.total == 0) return const Completion.none();
  return Completion.of(s.done / s.total);
}

/// Done and total of [blocks], skipped ones left out.
({int done, int total}) doneCounts(List<Occurrence> blocks) {
  var done = 0;
  var total = 0;
  for (final o in blocks) {
    if (o.status == OccurrenceStatus.skipped) continue;
    total++;
    if (o.status == OccurrenceStatus.done) done++;
  }
  return (done: done, total: total);
}
