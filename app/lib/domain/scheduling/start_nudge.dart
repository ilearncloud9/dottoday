import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';

/// Minutes after a planned start with no real start before Smallest step
/// asks (11 B2: "planned start + N minutes (default 10)").
const startNudgeAfterMin = 10;

/// The one "still not started" trigger (11 B2, A0; docs/09 M10.6): when
/// [o] has gone [afterMin] past its planned start with no `actualStart`
/// (B1, never inferred), or null when it can't — Inbox, done or skipped,
/// already started, deleted. Smallest step uses it now; the deferred
/// escalation (A0) will reuse it rather than build its own.
///
/// ```dart
/// noStartAt(deepWork); // 9:10 for a 9:00 dot nobody started
/// ```
DateTime? noStartAt(Occurrence o, {int afterMin = startNudgeAfterMin}) {
  final start = o.startUtc;
  if (start == null ||
      o.deletedAt != null ||
      o.actualStartUtc != null ||
      o.status != OccurrenceStatus.planned) {
    return null;
  }
  final at = start.add(Duration(minutes: afterMin));
  // A dot shorter than the wait is over before anyone would be asked.
  return at.isBefore(o.endUtc!) ? at : null;
}

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
  final at = noStartAt(o);
  if (at == null || nowUtc.isBefore(at) || !nowUtc.isBefore(o.endUtc!)) {
    return null;
  }
  return stepsNotStarted(steps) ? smallestStep(steps) : null;
}
