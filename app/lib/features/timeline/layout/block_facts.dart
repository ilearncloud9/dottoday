import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';

/// Everything a block shows besides title and time (docs/03 §3.1 "Block
/// anatomy"): its state and badges. Pure, so the label and the drawing
/// agree and both are unit-testable.
final class BlockFacts {
  const BlockFacts({
    required this.done,
    required this.overdue,
    required this.pinned,
    required this.recurring,
    required this.calendar,
    required this.alertCount,
    this.subtasksDone = 0,
    this.subtasksTotal = 0,
    this.startsBefore = false,
    this.endsAfter = false,
  });

  /// Facts of [o] at [nowUtc]. [seriesAlerts] are inherited when the
  /// occurrence has no override (`alerts` null, docs/05).
  ///
  /// Overdue = planned and already ended: shown quietly, never nagged
  /// (docs/02 F1).
  factory BlockFacts.of(
    Occurrence o, {
    required DateTime? nowUtc,
    List<Alert>? seriesAlerts,
    ({int done, int total})? subtasks,
    bool startsBefore = false,
    bool endsAfter = false,
  }) {
    final done = o.status == OccurrenceStatus.done;
    final end = o.endUtc;
    return BlockFacts(
      done: done,
      overdue:
          !done &&
          o.status == OccurrenceStatus.planned &&
          end != null &&
          nowUtc != null &&
          !end.isAfter(nowUtc),
      pinned: o.pinned,
      recurring: o.seriesId != null,
      calendar: o.source == OccurrenceSource.calendar,
      alertCount: (o.alerts ?? seriesAlerts ?? const []).length,
      subtasksDone: subtasks?.done ?? 0,
      subtasksTotal: subtasks?.total ?? 0,
      startsBefore: startsBefore,
      endsAfter: endsAfter,
    );
  }

  final bool done;
  final bool overdue;
  final bool pinned;
  final bool recurring;
  final bool calendar;
  final int alertCount;
  final int subtasksDone;
  final int subtasksTotal;
  final bool startsBefore;
  final bool endsAfter;

  bool get hasSubtasks => subtasksTotal > 0;

  @override
  bool operator ==(Object other) =>
      other is BlockFacts &&
      other.done == done &&
      other.overdue == overdue &&
      other.pinned == pinned &&
      other.recurring == recurring &&
      other.calendar == calendar &&
      other.alertCount == alertCount &&
      other.subtasksDone == subtasksDone &&
      other.subtasksTotal == subtasksTotal &&
      other.startsBefore == startsBefore &&
      other.endsAfter == endsAfter;

  @override
  int get hashCode => Object.hash(
    done,
    overdue,
    pinned,
    recurring,
    calendar,
    alertCount,
    subtasksDone,
    subtasksTotal,
    startsBefore,
    endsAfter,
  );
}
