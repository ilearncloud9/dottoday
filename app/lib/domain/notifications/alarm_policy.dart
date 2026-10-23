import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/time/wall_clock.dart';
import 'package:timezone/timezone.dart' as tz;

/// Which dot-starts ring alarm-loud (11-standout-roadmap A0, docs/09
/// M6.5.3): the first dot of each local day and every routine-start dot.
/// Everything else is a normal time-sensitive ping. No per-task tiers in
/// v1 (deferred).
///
/// "First dot of the day" is the earliest scheduled task that starts on
/// that day in [location], whatever its state: once it is done or skipped
/// the user is already up, so no later dot that day becomes the alarm
/// (rejected: promoting the next planned dot, which would wake a user who
/// ticked the first one early). Trashed and Inbox rows don't count.
///
/// ```dart
/// loudStartIds(rows, berlin); // {'first-on-mon', 'first-on-tue', …}
/// ```
Set<String> loudStartIds(
  Iterable<Occurrence> occurrences,
  tz.Location location, {
  Set<String> routineStartIds = const {},
}) {
  final firstByDay = <DateTime, Occurrence>{};
  for (final o in occurrences) {
    final start = o.startUtc;
    if (start == null || o.deletedAt != null) continue;
    final wall = utcToWallClock(location, start);
    final day = DateTime(wall.year, wall.month, wall.day);
    final best = firstByDay[day];
    if (best == null || _earlier(o, best)) firstByDay[day] = o;
  }
  return {
    for (final o in firstByDay.values)
      if (o.status == OccurrenceStatus.planned) o.id,
    ...routineStartIds,
  };
}

/// Earlier start wins; a tie goes to the lower id so the choice is stable.
bool _earlier(Occurrence a, Occurrence b) {
  final byStart = a.startUtc!.compareTo(b.startUtc!);
  return byStart != 0 ? byStart < 0 : a.id.compareTo(b.id) < 0;
}
