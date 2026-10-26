import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/suggestions/suggestion_service.dart';

/// One real run of a step (docs/13 §5): when it was ticked and how long it
/// took since the step before it was ticked, or since the task really
/// started.
typedef StepRun = ({DateTime tickedAt, int minutes});

/// The key a step learns under: its task's and its own normalised titles,
/// so "Dishes" in "Clean the kitchen" is not "Dishes" in "Party".
String stepKey(String taskTitle, String stepTitle) =>
    '${normaliseTitle(taskTitle)}\u0000${normaliseTitle(stepTitle)}';

/// Every real step run in [history] with [steps] (any order), by
/// [stepKey], newest first.
///
/// A run needs a real start (B1, never inferred): the task's
/// `actualStartUtc` or an earlier step's tick (`tickedAt`, ADR-0012), and
/// a span of 1–1440 min. Steps ticked before 0008 have no time and say
/// nothing; neither do tasks that never really started.
///
/// ```dart
/// stepRunsByKey(history, steps)[stepKey('Clean', 'Dishes')]!.first.minutes;
/// ```
Map<String, List<StepRun>> stepRunsByKey(
  Iterable<Occurrence> history,
  Iterable<Subtask> steps,
) {
  final byTask = <String, List<Subtask>>{};
  for (final s in steps) {
    if (s.deletedAt == null) (byTask[s.occurrenceId] ??= []).add(s);
  }
  final out = <String, List<StepRun>>{};
  for (final task in history) {
    final start = task.actualStartUtc;
    final mine = byTask[task.id];
    if (task.deletedAt != null || start == null || mine == null) continue;
    for (final (key, run) in _runsOf(task.title, start, mine)) {
      (out[key] ??= []).add(run);
    }
  }
  for (final runs in out.values) {
    runs.sort((a, b) => b.tickedAt.compareTo(a.tickedAt));
  }
  return out;
}

/// [steps] of a task that really started at [start], in order: each tick
/// against the latest tick before it (as Focus times them), else [start].
Iterable<(String, StepRun)> _runsOf(
  String taskTitle,
  DateTime start,
  List<Subtask> steps,
) sync* {
  final ordered = [...steps]
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  var from = start;
  for (final s in ordered) {
    final at = tickedAt(s);
    if (at == null) continue;
    final minutes = at.difference(from).inMinutes;
    if (minutes >= 1 && minutes <= 1440) {
      yield (stepKey(taskTitle, s.title), (tickedAt: at, minutes: minutes));
    }
    if (at.isAfter(from)) from = at;
  }
}
