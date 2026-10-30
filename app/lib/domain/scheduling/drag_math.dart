import 'package:dottoday/domain/time/clock_time.dart';
import 'package:timezone/timezone.dart' as tz;

/// Where a task of [durationMin] lands when let go [fraction] (0–1) down a
/// row that stands for [gapMinutes] from [gapStartUtc] (R-05 drag): a free
/// gap, or with [fit] off another task's row (ADR-0015).
///
/// The start snaps to a multiple of [snapMinutes] on the wall clock in
/// [zone] (so 09:15, not "5 past the previous task + 10"). In a gap it is
/// clamped so the task fits inside when it can; a task longer than the gap
/// starts at the gap's opening and overlaps what follows, which "Shift the
/// rest" then offers to fix. On a task's row ([fit] false) it lands where
/// it was let go and overlaps that task.
///
/// ```dart
/// dropStart(zone: berlin, gapStartUtc: t0905, gapMinutes: 60,
///     fraction: 0.5, durationMin: 30, snapMinutes: 15); // 09:30 local
/// ```
DateTime dropStart({
  required tz.Location zone,
  required DateTime gapStartUtc,
  required int gapMinutes,
  required double fraction,
  required int durationMin,
  required int snapMinutes,
  bool fit = true,
}) {
  final raw = gapStartUtc.add(
    Duration(minutes: (gapMinutes * fraction.clamp(0, 1)).round()),
  );
  final local = tz.TZDateTime.from(raw, zone);
  final ofDay = local.hour * 60 + local.minute;
  final snap = (ofDay / snapMinutes).round() * snapMinutes - ofDay;
  final start = raw.add(Duration(minutes: snap));
  if (!fit) return start;
  final latest = gapStartUtc.add(Duration(minutes: gapMinutes - durationMin));
  if (start.isAfter(latest)) {
    return latest.isBefore(gapStartUtc) ? gapStartUtc : latest;
  }
  return start.isBefore(gapStartUtc) ? gapStartUtc : start;
}

/// [startUtc] moved onto [date]'s calendar day in [zone] at the same wall
/// time (dropping a task on a week-strip day, PRD F8).
DateTime sameTimeOn(tz.Location zone, DateTime startUtc, DateTime date) =>
    ClockTime.ofUtc(zone, startUtc).onDate(zone, date);
