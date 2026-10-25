import 'package:dottoday/domain/calendar/calendar_import_plan.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:timezone/timezone.dart' as tz;

/// The calendar move Today offers Rebalance for (docs/09 M11.1b, 11 C1),
/// or null: an event of [day] the calendar moved later within the same
/// day, not over yet at [nowUtc], that now overlaps another planned task.
/// The earliest such event wins. A move earlier frees time, and
/// Rebalance never moves a task earlier, so it is never offered.
///
/// ```dart
/// final move = moveToRebalance(moves.values, today.blocks, now);
/// ```
CalendarMove? moveToRebalance(
  Iterable<CalendarMove> moves,
  List<Occurrence> day,
  DateTime nowUtc,
) {
  final byId = {for (final o in day) o.id: o};
  final offered = [
    for (final m in moves)
      if (byId[m.occurrenceId] case final o? when _offers(m, o, day, nowUtc)) m,
  ]..sort((a, b) => a.toUtc.compareTo(b.toUtc));
  return offered.firstOrNull;
}

bool _offers(CalendarMove m, Occurrence o, List<Occurrence> day, DateTime now) {
  if (m.deltaMin <= 0 || o.status != OccurrenceStatus.planned) return false;
  final end = o.endUtc;
  if (o.startUtc != m.toUtc || end == null || !now.isBefore(end)) {
    return false;
  }
  final zone = tz.getLocation(o.tzId);
  final was = tz.TZDateTime.from(m.fromUtc, zone);
  final is_ = tz.TZDateTime.from(m.toUtc, zone);
  if (was.day != is_.day || was.month != is_.month || was.year != is_.year) {
    return false;
  }
  return day.any(
    (other) =>
        other.id != o.id &&
        other.status == OccurrenceStatus.planned &&
        other.startUtc != null &&
        other.startUtc!.isBefore(end) &&
        other.endUtc!.isAfter(m.toUtc),
  );
}
