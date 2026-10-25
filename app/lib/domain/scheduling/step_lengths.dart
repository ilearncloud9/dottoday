import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/validation/field_rules.dart';

/// Step lengths (11 §0 B2, docs/09 M10.3): a task's length may follow the
/// sum of its steps (`durationFromSteps`), and a typed length overrides it.

/// Sum of the live steps that have a length; null when none has one.
///
/// ```dart
/// stepsTotal([gather(10), login(15), untimed]); // 25
/// ```
int? stepsTotal(Iterable<Subtask> steps) {
  final lengths = [
    for (final s in steps)
      if (s.deletedAt == null) ?s.durationMin,
  ];
  return lengths.isEmpty ? null : lengths.fold<int>(0, (a, b) => a + b);
}

/// [o] with its length following [steps] while `durationFromSteps` is on
/// and a step has a length, clamped to the task range (5 min – 24 h); else
/// [o] unchanged.
Occurrence followSteps(Occurrence o, Iterable<Subtask> steps) {
  if (!o.durationFromSteps) return o;
  final total = stepsTotal(steps);
  if (total == null) return o;
  final length = total.clamp(minDurationMin, maxDurationMin);
  return length == o.durationMin ? o : o.copyWith(durationMin: length);
}

/// The "Length = sum of steps" switch: on follows [steps] at once; off
/// keeps the length it has.
Occurrence setFollowSteps(Occurrence o, Iterable<Subtask> steps, bool on) =>
    followSteps(o.copyWith(durationFromSteps: on), steps);

/// A length the user picked: it wins and turns following off.
Occurrence overrideLength(Occurrence o, int minutes) =>
    o.copyWith(durationMin: minutes, durationFromSteps: false);
