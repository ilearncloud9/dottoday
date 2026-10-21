import 'package:dottoday/domain/entities/occurrence.dart';

/// What a scheduling operation did, for the UI's partial-shift toast and
/// undo (R-04, R-17).
final class ShiftReport {
  const ShiftReport({
    this.movedIds = const [],
    this.blockedById,
    this.skippedIds = const [],
  });

  /// Blocks whose start changed, in timeline order.
  final List<String> movedIds;

  /// The pinned block that stopped the shift; non-null means [partial].
  final String? blockedById;

  /// Blocks left in place but passed over (calendar events, done blocks).
  final List<String> skippedIds;

  /// Whether a pinned block stopped the shift before the end of the day.
  bool get partial => blockedById != null;
}

/// A day after a scheduling operation, plus its [report].
///
/// [day] holds every input block (changed ones replaced), sorted by start.
final class ScheduleResult {
  const ScheduleResult(this.day, this.report);

  final List<Occurrence> day;
  final ShiftReport report;

  /// The block with [id] in [day].
  Occurrence byId(String id) => day.firstWhere((o) => o.id == id);
}

/// How [insert] treats blocks already at the new block's time (docs/04 §5).
enum InsertPolicy {
  /// Keep the requested time and let blocks overlap.
  overlap,

  /// Keep the requested time and push later blocks down, gaps preserved.
  bump,

  /// Move the new block to the first free gap at or after its time.
  fitNextGap,
}

/// A free interval of the day long enough for a requested duration.
final class Slot {
  const Slot(this.startUtc, this.endUtc);

  final DateTime startUtc;
  final DateTime endUtc;

  @override
  bool operator ==(Object other) =>
      other is Slot && other.startUtc == startUtc && other.endUtc == endUtc;

  @override
  int get hashCode => Object.hash(startUtc, endUtc);

  @override
  String toString() => 'Slot($startUtc–$endUtc)';
}
