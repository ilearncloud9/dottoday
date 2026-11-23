import 'package:dottoday/shared/learning/learned_line.dart';
import 'package:flutter/foundation.dart';

/// Where the plan put a task's dot, seen from where it really started.
enum GhostShift {
  /// Started as planned, or no actual start: no ghost dot.
  none,

  /// The plan was earlier: the ghost dot sits above.
  earlier,

  /// The plan was later: the ghost dot sits below.
  later,
}

/// A task as the Reality thread shows it (11 C3, `B-ios-reality-thread`):
/// display strings only, formatted by the feature.
@immutable
final class ThreadReality {
  const ThreadReality({
    this.range,
    this.meta,
    this.note,
    this.ghost = GhostShift.none,
    this.underWay = false,
    this.usual,
    this.usualWhy,
  });

  /// "usually 2 h 20" at the end of the live row's time line (M11.3
  /// learning, E-R2-23 §4).
  final String? usual;

  /// How [usual] was worked out, on tap (docs/13 §6).
  final LearnedExplanation? usualWhy;

  /// "7:42 – 8:16" or "9:10 – now"; null keeps the planned range.
  final String? range;

  /// After the range: "planned 7:30", "planned 9:00 – 11:00", "not
  /// started yet".
  final String? meta;

  /// Joined onto the time line: "took 34 min"; on the live row "1 h 14
  /// in" (E-R2-23 §4).
  final String? note;
  final GhostShift ghost;

  /// Really started and not finished: the only rows drawn live.
  final bool underWay;
}
