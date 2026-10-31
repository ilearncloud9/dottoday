import 'package:dottoday/domain/time/wall_clock.dart';
import 'package:timezone/timezone.dart' as tz;

/// The next local midnight after [nowUtc] in [location], as UTC; on a day
/// whose midnight falls in a DST gap, the first instant after it.
///
/// ```dart
/// nextMidnightUtc(berlin, DateTime.utc(2026, 10, 21, 20)); // 10-21 22:00Z
/// ```
DateTime nextMidnightUtc(tz.Location location, DateTime nowUtc) {
  final wall = utcToWallClock(location, nowUtc);
  return wallClockToUtc(
    location,
    DateTime.utc(wall.year, wall.month, wall.day + 1),
  );
}

/// When the app's housekeeping (docs/09 M5.2) is next due while it stays
/// open: the day turning over in [location] (repeats roll on, reminders
/// and widgets move to the new day), or the daily backup at
/// [backupDueUtc], whichever comes first. A backup already overdue (its
/// last run failed) waits for midnight or the next start or resume, so a
/// failing backup can't spin (docs/04 §4 "Triggers").
///
/// ```dart
/// housekeepingDueUtc(
///   location: berlin,
///   nowUtc: DateTime.utc(2026, 10, 21, 9),
///   backupDueUtc: DateTime.utc(2026, 10, 21, 15),
/// ); // 15:00Z: the backup comes before Berlin's midnight
/// ```
DateTime housekeepingDueUtc({
  required tz.Location location,
  required DateTime nowUtc,
  required DateTime backupDueUtc,
}) {
  final midnight = nextMidnightUtc(location, nowUtc);
  if (!backupDueUtc.isAfter(nowUtc)) return midnight;
  return backupDueUtc.isBefore(midnight) ? backupDueUtc : midnight;
}
