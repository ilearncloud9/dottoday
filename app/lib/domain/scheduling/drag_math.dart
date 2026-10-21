import 'package:dottoday/domain/time/clock_time.dart';
import 'package:timezone/timezone.dart' as tz;

/// Where a task of [durationMin] lands when let go [fraction] (0–1) down a
/// free gap of [gapMinutes] opening at [gapStartUtc] (R-05 drag).
///
/// The start snaps to a multiple of [snapMinutes] on the wall clock in
/// [zone] (so 09:15, not "5 past the previous task + 10") and is clamped
/// so the task fits inside the gap when it can; a task longer than the gap
/// starts at the gap's opening and overlaps what follows, which "Shift the
/// rest" then offers to fix.
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
}) {
  final raw = gapStartUtc.add(
    Duration(minutes: (gapMinutes * fraction.clamp(0, 1)).round()),
  );
  final local = tz.TZDateTime.from(raw, zone);
  final ofDay = local.hour * 60 + local.minute;
  final snap = (ofDay / snapMinutes).round() * snapMinutes - ofDay;
  final start = raw.add(Duration(minutes: snap));
  final latest = gapStartUtc.add(Duration(minutes: gapMinutes - durationMin));
  if (start.isAfter(latest)) {
    return latest.isBefore(gapStartUtc) ? gapStartUtc : latest;
  }
  return start.isBefore(gapStartUtc) ? gapStartUtc : start;
}

/// The new length after a resize grip moved [steps] snap steps; never
/// shorter than one step (R-05).
///
/// ```dart
/// resizedDuration(45, steps: -2, snapMinutes: 15); // 15
/// ```
int resizedDuration(
  int durationMin, {
  required int steps,
  required int snapMinutes,
}) {
  final next = durationMin + steps * snapMinutes;
  return next < snapMinutes ? snapMinutes : next;
}

/// [startUtc] moved onto [date]'s calendar day in [zone] at the same wall
/// time (dropping a task on a week-strip day, PRD F8).
DateTime sameTimeOn(tz.Location zone, DateTime startUtc, DateTime date) =>
    ClockTime.ofUtc(zone, startUtc).onDate(zone, date);
