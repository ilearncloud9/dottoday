import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/day_capacity.dart';
import 'package:dottoday/domain/time/day_shape.dart';

/// One day of the Week board (`A-mac-week-alt3-board`): what is planned
/// and how much of the waking day is still free.
final class DayLoad {
  const DayLoad({
    required this.date,
    required this.plannedMinutes,
    required this.freeMinutes,
    required this.awakeMinutes,
    required this.done,
    required this.total,
  });

  /// [blocks] of [date] inside [shape]: timed, non-skipped tasks count;
  /// free time counts overlaps once (domain `capacityOf`).
  factory DayLoad.of(DateTime date, List<Occurrence> blocks, DayShape shape) {
    final active = [
      for (final o in blocks)
        if (o.startUtc != null && o.status != OccurrenceStatus.skipped) o,
    ];
    final capacity = capacityOf(active, shape);
    return DayLoad(
      date: date,
      plannedMinutes: active.fold(0, (sum, o) => sum + o.durationMin),
      freeMinutes: capacity.freeMinutes,
      awakeMinutes: capacity.awakeMinutes,
      done: active.where((o) => o.status == OccurrenceStatus.done).length,
      total: active.length,
    );
  }

  /// Local date (y/m/d).
  final DateTime date;
  final int plannedMinutes;
  final int freeMinutes;
  final int awakeMinutes;
  final int done;
  final int total;

  /// Planned share of the waking day, 0–1 (`CapacityRing`).
  double get share =>
      awakeMinutes == 0 ? 0 : (plannedMinutes / awakeMinutes).clamp(0, 1);
}

/// The Week board's header numbers and `WeekSummaryStrip` chips: "13 of
/// 29 done · 36 h 15 planned", Busiest · Thu · 7 h 30, Lightest · Sat ·
/// 2 h 30, Free · 68 h 45 unplanned.
final class WeekSummary {
  const WeekSummary({
    required this.days,
    required this.busiest,
    required this.lightest,
    required this.plannedMinutes,
    required this.freeMinutes,
    required this.done,
    required this.total,
  });

  /// Busiest is the day with the most planned time, lightest the least;
  /// ties go to the earlier day. Both are null for an empty week (nothing
  /// to compare).
  factory WeekSummary.of(List<DayLoad> days) {
    final planned = days.where((d) => d.plannedMinutes > 0);
    DayLoad? pick(bool Function(DayLoad a, DayLoad b) better) =>
        planned.fold<DayLoad?>(
          null,
          (best, d) => best == null || better(d, best) ? d : best,
        );
    final busiest = pick((a, b) => a.plannedMinutes > b.plannedMinutes);
    final lightest = pick((a, b) => a.plannedMinutes < b.plannedMinutes);
    int sum(int Function(DayLoad d) f) => days.fold(0, (s, d) => s + f(d));
    return WeekSummary(
      days: days,
      busiest: busiest,
      lightest: identical(busiest, lightest) ? null : lightest,
      plannedMinutes: sum((d) => d.plannedMinutes),
      freeMinutes: sum((d) => d.freeMinutes),
      done: sum((d) => d.done),
      total: sum((d) => d.total),
    );
  }

  final List<DayLoad> days;
  final DayLoad? busiest;

  /// Null when only one day has anything planned.
  final DayLoad? lightest;
  final int plannedMinutes;
  final int freeMinutes;
  final int done;
  final int total;
}
