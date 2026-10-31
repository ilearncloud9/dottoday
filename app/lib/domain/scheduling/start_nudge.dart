import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/scheduling/start_escalation.dart';

/// The step Smallest step offers: the first live step not done, in order.
Subtask? smallestStep(Iterable<Subtask> steps) {
  final open = [
    for (final s in steps)
      if (s.deletedAt == null && !s.done) s,
  ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return open.firstOrNull;
}

/// Whether Smallest step still has something to ask about [steps]: one to
/// do and none ticked yet — a ticked step means the task is under way,
/// whatever `actualStart` says (11 B2 is about starting, never nagging).
bool stepsNotStarted(Iterable<Subtask> steps) {
  final live = [
    for (final s in steps)
      if (s.deletedAt == null) s,
  ];
  return live.any((s) => !s.done) && !live.any((s) => s.done);
}

/// The step [o]'s row offers at [nowUtc] ("Just `step` · 2 min?"): past
/// the trigger, before its planned end; null otherwise.
Subtask? smallestStepAt(
  Occurrence o,
  Iterable<Subtask> steps,
  DateTime nowUtc,
) {
  final at = escalationAt(DotStart(o));
  if (at == null || nowUtc.isBefore(at) || !nowUtc.isBefore(o.endUtc!)) {
    return null;
  }
  return stepsNotStarted(steps) ? smallestStep(steps) : null;
}
