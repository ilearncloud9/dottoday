import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';

/// What the actual timestamps say about a task (11 C3, B1).
enum RealityKind {
  /// No actual start (or none to show): drawn where it was planned.
  asPlanned,

  /// Started and not finished: drawn from its actual start to now.
  underWay,

  /// Started and finished: drawn where it really ran.
  finished,

  /// Still to start: the next one, or one whose planned start has passed.
  notStartedYet,
}

/// One task of the Reality thread: [shown] carries the times it really
/// ran (planned ones when there are none), [planned] the plan.
final class Reality {
  const Reality({
    required this.shown,
    required this.planned,
    required this.kind,
  });

  final Occurrence shown;
  final Occurrence planned;
  final RealityKind kind;

  /// Whole minutes it really took ([RealityKind.finished]) or has run so
  /// far ([RealityKind.underWay]); null otherwise.
  int? tookMinutes(DateTime nowUtc) => switch (kind) {
    RealityKind.finished => shown.durationMin,
    RealityKind.underWay => nowUtc.difference(shown.startUtc!).inMinutes,
    RealityKind.asPlanned || RealityKind.notStartedYet => null,
  };

  /// Minutes between the actual and the planned start: positive when it
  /// started after the plan. 0 without an actual start.
  int get startShiftMinutes =>
      shown.startUtc!.difference(planned.startUtc!).inMinutes;
}

/// The day as it really went at [nowUtc] (11 C3, docs/09 M11.2), one
/// [Reality] per scheduled task of [blocks], in their order. Times are
/// never inferred (11 §0 B1): a task without an actual start stays where
/// it was planned, and so does one ticked done without one.
///
/// ```dart
/// realityOf(day, now).map((r) => r.shown); // the actual thread
/// ```
List<Reality> realityOf(List<Occurrence> blocks, DateTime nowUtc) {
  final scheduled = [
    for (final o in blocks)
      if (o.startUtc != null) o,
  ];
  final next = _nextToStart(scheduled, nowUtc);
  return [for (final o in scheduled) _reality(o, nowUtc, o.id == next)];
}

Reality _reality(Occurrence o, DateTime now, bool next) {
  final start = o.actualStartUtc;
  final end = o.actualEndUtc;
  if (start != null && end != null && end.isAfter(start)) {
    return Reality(
      shown: _ran(o, start, end),
      planned: o,
      kind: RealityKind.finished,
    );
  }
  if (start != null && o.status == OccurrenceStatus.planned) {
    // Under way: from its start to now, at least as long as planned so it
    // reads as live until it is ticked.
    final planEnd = start.add(Duration(minutes: o.durationMin));
    final soon = now.add(const Duration(minutes: 1));
    return Reality(
      shown: _ran(o, start, planEnd.isAfter(soon) ? planEnd : soon),
      planned: o,
      kind: RealityKind.underWay,
    );
  }
  final waiting =
      start == null &&
      o.status == OccurrenceStatus.planned &&
      (next || !o.startUtc!.isAfter(now));
  return Reality(
    shown: o,
    planned: o,
    kind: waiting ? RealityKind.notStartedYet : RealityKind.asPlanned,
  );
}

/// [o] moved to the span it really ran, at least a minute long.
Occurrence _ran(Occurrence o, DateTime start, DateTime end) {
  final minutes = end.difference(start).inMinutes;
  return o.copyWith(startUtc: start, durationMin: minutes < 1 ? 1 : minutes);
}

/// The first planned task after [now] with no actual start.
String? _nextToStart(List<Occurrence> scheduled, DateTime now) {
  final waiting = [
    for (final o in scheduled)
      if (o.status == OccurrenceStatus.planned &&
          o.actualStartUtc == null &&
          o.startUtc!.isAfter(now))
        o,
  ]..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));
  return waiting.firstOrNull?.id;
}
