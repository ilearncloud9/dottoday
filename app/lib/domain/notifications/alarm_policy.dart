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
}) => {...firstDotIds(occurrences, location), ...routineStartIds};

/// The first dot of each local day in [location] that is still planned
/// (see [loudStartIds] for why a done or skipped first dot hands nothing
/// on). The Wake Up alarm reads it too (docs/15 W1): a first dot within
/// [wakeUpQuietWindow] of a ringing Wake Up is a normal notification.
Set<String> firstDotIds(
  Iterable<Occurrence> occurrences,
  tz.Location location,
) {
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
  };
}

/// How close to a ringing Wake Up alarm the day's first dot stops ringing
/// loud itself, either side (owner, 2026-10-31): one alarm a morning.
const wakeUpQuietWindow = Duration(minutes: 30);

/// Earlier start wins; a tie goes to the lower id so the choice is stable.
bool _earlier(Occurrence a, Occurrence b) {
  final byStart = a.startUtc!.compareTo(b.startUtc!);
  return byStart != 0 ? byStart < 0 : a.id.compareTo(b.id) < 0;
}
