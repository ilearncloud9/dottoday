import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';

// Done / not done / started on one occurrence (R-09), and the actual
// timestamps that go with them (11-standout-roadmap B1). Every writer of
// completion goes through these so the actuals never drift apart from the
// status. Actuals are set by explicit actions only — never inferred from
// the clock or the plan.

/// [o] marked done at [nowUtc]: `completedAtUtc` and `actualEndUtc` both
/// record the tap. `actualStartUtc` stays as it was (null if the user never
/// pressed Start), so Reality shows "took …" only when it is known.
Occurrence markDone(Occurrence o, DateTime nowUtc) => o.copyWith(
  status: OccurrenceStatus.done,
  completedAtUtc: nowUtc,
  actualEndUtc: nowUtc,
);

/// [o] planned again: the end goes, a real start is kept (the user did
/// begin it).
Occurrence markNotDone(Occurrence o) => o.copyWith(
  status: OccurrenceStatus.planned,
  completedAtUtc: null,
  actualEndUtc: null,
);

/// Done ⇄ planned, as the Done circle, ⌘D and the task sheet toggle it.
Occurrence toggleDone(Occurrence o, DateTime nowUtc) =>
    o.status == OccurrenceStatus.done ? markNotDone(o) : markDone(o, nowUtc);

/// [o] started at [nowUtc] (Focus, the live dot, Start). Only the first
/// start counts; a done or skipped task is left alone.
///
/// ```dart
/// markStarted(o, t1).actualStartUtc; // t1
/// markStarted(markStarted(o, t1), t2).actualStartUtc; // still t1
/// ```
Occurrence markStarted(Occurrence o, DateTime nowUtc) =>
    o.status != OccurrenceStatus.planned || o.actualStartUtc != null
    ? o
    : o.copyWith(actualStartUtc: nowUtc);

/// A fresh copy's progress (duplicate day, duplicate selection): planned,
/// nothing started or finished.
Occurrence withoutProgress(Occurrence o) => o.copyWith(
  status: OccurrenceStatus.planned,
  completedAtUtc: null,
  actualStartUtc: null,
  actualEndUtc: null,
);
