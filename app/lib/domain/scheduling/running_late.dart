import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';

// "Running late" (docs/09 M3f.5, R-04): besides pushing the rest of the
// day (`DaySchedulerService.runningLate`), skip or shorten the task at
// hand. Pure; the caller writes the result through the undoable path.

/// The shortest a shortened task may become.
const minShortenedMinutes = 5;

/// How long after a task's end an unticked one counts as "running late".
const lateGrace = Duration(minutes: 5);

/// How long a missed task keeps the nudge up: older ones no longer mean
/// the user is behind right now.
const lateWindow = Duration(hours: 1);

bool _timed(Occurrence o) =>
    o.status == OccurrenceStatus.planned &&
    o.startUtc != null &&
    o.source == OccurrenceSource.user;

/// The task "Running late" acts on: the one running at [nowUtc], else the
/// next planned one; null when nothing is left today.
///
/// ```dart
/// lateTarget(day, now)?.title; // 'Lunch with Sam'
/// ```
Occurrence? lateTarget(List<Occurrence> day, DateTime nowUtc) {
  Occurrence? next;
  for (final o in day.where(_timed)) {
    final start = o.startUtc!;
    if (!start.isAfter(nowUtc) && o.endUtc!.isAfter(nowUtc)) return o;
    if (start.isAfter(nowUtc) &&
        (next == null || start.isBefore(next.startUtc!))) {
      next = o;
    }
  }
  return next;
}

/// [o] starting [minutes] later and ending as planned, so nothing after it
/// moves; null when less than [minShortenedMinutes] would be left.
///
/// ```dart
/// shortenStart(lunch, 15)!.durationMin; // 45, was 60
/// ```
Occurrence? shortenStart(Occurrence o, int minutes) {
  final start = o.startUtc;
  if (start == null || o.durationMin - minutes < minShortenedMinutes) {
    return null;
  }
  return o.copyWith(
    startUtc: start.add(Duration(minutes: minutes)),
    durationMin: o.durationMin - minutes,
  );
}

/// The task that suggests the user is behind (the running-late nudge,
/// `Settings.runningLateNudge`): the latest one that ended between
/// [lateWindow] and [lateGrace] ago without a tick, while something is
/// still planned later today. Null when on track.
Occurrence? missedTask(List<Occurrence> day, DateTime nowUtc) {
  final timed = day.where(_timed).toList();
  if (!timed.any((o) => o.startUtc!.isAfter(nowUtc))) return null;
  Occurrence? missed;
  for (final o in timed) {
    final end = o.endUtc!;
    final ago = nowUtc.difference(end);
    if (ago < lateGrace || ago > lateWindow) continue;
    if (missed == null || end.isAfter(missed.endUtc!)) missed = o;
  }
  return missed;
}
