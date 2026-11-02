import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/reveal/hint_scheduler.dart';

// The triggers of docs/14 §5, each a pure read of rows the app already
// has; nothing new is stored to decide them.

/// A task on [today] moved [unstickMoves] times and still without steps
/// ([stepCounts]: occurrence id → number of steps).
String? movedTaskOf(List<Occurrence> today, Map<String, int> stepCounts) =>
    today
        .where(
          (o) =>
              o.status == OccurrenceStatus.planned &&
              o.moveCount >= unstickMoves &&
              (stepCounts[o.id] ?? 0) == 0,
        )
        .firstOrNull
        ?.id;

/// A task on [today] over [longTaskMinutes] with no steps, not yet done.
String? longTaskOf(List<Occurrence> today, Map<String, int> stepCounts) => today
    .where(
      (o) =>
          o.status == OccurrenceStatus.planned &&
          o.durationMin > longTaskMinutes &&
          (stepCounts[o.id] ?? 0) == 0,
    )
    .firstOrNull
    ?.id;

/// Whether each of [mornings] (one list of timed tasks per day, newest
/// last) began with the same three titles. Fewer than [routineMornings]
/// days, or a day with fewer than three tasks, is no.
bool sameMornings(List<List<Occurrence>> mornings) {
  if (mornings.length < routineMornings) return false;
  final firsts = [
    for (final day in mornings.sublist(mornings.length - routineMornings))
      _firstThree(day),
  ];
  if (firsts.any((f) => f == null)) return false;
  return firsts.every((f) => _same(f!, firsts.first!));
}

/// How many of [week]'s tasks really ended more than [overrunMinutes]
/// after their planned end (B1 timestamps; nothing is inferred).
int overrunsOf(Iterable<Occurrence> week) => week.where((o) {
  final end = o.endUtc;
  final actual = o.actualEndUtc;
  return end != null &&
      actual != null &&
      actual.difference(end).inMinutes > overrunMinutes;
}).length;

List<String>? _firstThree(List<Occurrence> day) {
  final timed = [
    for (final o in day)
      if (o.startUtc != null && o.source == OccurrenceSource.user) o,
  ]..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));
  if (timed.length < 3) return null;
  return [for (final o in timed.take(3)) o.title.trim().toLowerCase()];
}

bool _same(List<String> a, List<String> b) =>
    a.length == b.length &&
    [for (var i = 0; i < a.length; i++) a[i] == b[i]].every((x) => x);

/// Whether the newest [lateMorningsForHint] of [offsetsMin] (minutes from
/// Wake Up to "I'm up", newest first) are each at least
/// [lateMorningMinutes] (docs/15 §11 mission offer).
bool lateMorningsOf(Iterable<int> offsetsMin) {
  final last = offsetsMin.take(lateMorningsForHint).toList();
  return last.length == lateMorningsForHint &&
      last.every((m) => m >= lateMorningMinutes);
}
