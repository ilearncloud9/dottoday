import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';

/// What Focus shows at one moment (11 A3, `B-ios-focus`, docs/09 M10.5):
/// the task's ring and minutes left, and the current step with its own
/// timer. Pure; the screen recomputes it every second.
final class FocusState {
  const FocusState({
    required this.progress,
    required this.minutesLeft,
    required this.steps,
    this.stepIndex,
    this.stepStartUtc,
    this.stepLeft,
    this.stepProgress,
  });

  /// Share of the planned time gone, 0–1 (the ring).
  final double progress;

  /// Whole minutes to the planned end, never below 0.
  final int minutesLeft;

  /// Live steps in order.
  final List<Subtask> steps;

  /// The first step not done; null without steps or when all are done.
  final int? stepIndex;

  /// When the current step began: the last tick, else the start.
  final DateTime? stepStartUtc;

  /// Time left on the current step; null when it has no length. Never
  /// negative: a step that runs over shows 0:00, never "late" (11 §D).
  final Duration? stepLeft;

  /// Share of the current step's length gone, 0–1.
  final double? stepProgress;

  Subtask? get step => stepIndex == null ? null : steps[stepIndex!];
}

/// [task] in Focus at [nowUtc] with its [subtasks] (any order, deleted
/// ones ignored).
///
/// The current step begins when the step before it was ticked (its last
/// update) — even if Focus was opened later — or, for the first, when the
/// task really started (B1 `actualStart`) or was planned to.
///
/// ```dart
/// focusAt(deepWork, steps, now).stepLeft; // 0:14:20
/// ```
FocusState focusAt(Occurrence task, List<Subtask> subtasks, DateTime nowUtc) {
  final start = task.startUtc ?? task.actualStartUtc ?? nowUtc;
  final length = Duration(minutes: task.durationMin);
  final gone = nowUtc.difference(start);
  final progress = length.inSeconds == 0
      ? 1.0
      : (gone.inSeconds / length.inSeconds).clamp(0.0, 1.0);
  final left = start.add(length).difference(nowUtc);
  final minutesLeft = left.isNegative ? 0 : (left.inSeconds / 60).ceil();
  final steps = [
    for (final s in subtasks)
      if (s.deletedAt == null) s,
  ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  final index = steps.indexWhere((s) => !s.done);
  if (index < 0) {
    return FocusState(
      progress: progress,
      minutesLeft: minutesLeft,
      steps: steps,
    );
  }
  // The first step runs from the real start; a later one from the tick
  // that finished the step before it.
  var stepStart = task.actualStartUtc ?? start;
  final ticks = [
    for (final s in steps.take(index))
      if (s.done) s.updatedAt,
  ]..sort();
  if (ticks.isNotEmpty) stepStart = ticks.last;
  if (stepStart.isAfter(nowUtc)) stepStart = nowUtc;
  final stepLength = steps[index].durationMin;
  Duration? stepLeft;
  double? stepProgress;
  if (stepLength != null) {
    final total = Duration(minutes: stepLength);
    final spent = nowUtc.difference(stepStart);
    final rest = total - spent;
    stepLeft = rest.isNegative ? Duration.zero : rest;
    stepProgress = (spent.inSeconds / total.inSeconds).clamp(0.0, 1.0);
  }
  return FocusState(
    progress: progress,
    minutesLeft: minutesLeft,
    steps: steps,
    stepIndex: index,
    stepStartUtc: stepStart,
    stepLeft: stepLeft,
    stepProgress: stepProgress,
  );
}

/// A step timer as Focus shows it: "14:20", "1:05:00" past an hour.
///
/// ```dart
/// countdown(const Duration(minutes: 14, seconds: 20)); // 14:20
/// ```
String countdown(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = d.inSeconds % 60;
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${d.inMinutes}:${two(s)}';
}
