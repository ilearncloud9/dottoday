import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/day_blocks.dart';
import 'package:dottoday/domain/validation/field_rules.dart';

/// How a proposed time sits among a day's tasks (`ThreadPicker`'s caption:
/// "Free until 19:30 · no overlap" or an overlap warning, docs/10 §6 "the
/// ThreadPicker never lets the user pick a time blind").
final class SlotFit {
  const SlotFit({
    required this.overlaps,
    required this.freeUntilUtc,
    this.next,
  });

  /// Tasks the proposed time collides with (travel buffers included), in
  /// timeline order.
  final List<Occurrence> overlaps;

  /// When the next task (or Bedtime) begins after the proposed start; the
  /// room the slot has.
  final DateTime freeUntilUtc;

  /// The task that ends the room at [freeUntilUtc]; null when Bedtime
  /// (or nothing) does.
  final Occurrence? next;

  bool get isFree => overlaps.isEmpty;
}

/// Checks `[startUtc, startUtc + durationMin)` against [day]'s timed tasks.
///
/// Skipped and all-day items don't occupy time; [ignoreId] leaves out the
/// task being moved. [freeUntilUtc] is the first busy start after
/// [startUtc], else [dayEndUtc] (Bedtime) — or [startUtc]'s own end when it
/// is already past Bedtime.
///
/// ```dart
/// fitAt(day, fivePm, 60, dayEndUtc: bedtime).isFree; // true
/// ```
SlotFit fitAt(
  Iterable<Occurrence> day,
  DateTime startUtc,
  int durationMin, {
  required DateTime dayEndUtc,
  String? ignoreId,
}) {
  final end = startUtc.add(Duration(minutes: durationMin));
  final busy = scheduledBlocks(day).where(
    (o) =>
        o.id != ignoreId && occupiesTime(o) && o.durationMin < maxDurationMin,
  );
  final overlaps = <Occurrence>[];
  Occurrence? nextTask;
  DateTime? next;
  for (final o in busy) {
    final from = footprintStart(o);
    final to = o.endUtc!;
    if (from.isBefore(end) && to.isAfter(startUtc)) overlaps.add(o);
    if (!from.isBefore(startUtc) && (next == null || from.isBefore(next))) {
      next = from;
      nextTask = o;
    }
  }
  final bedtime = dayEndUtc.isAfter(startUtc) ? dayEndUtc : null;
  final bounds = [?next, ?bedtime];
  final until = bounds.isEmpty
      ? end
      : bounds.reduce((a, b) => a.isBefore(b) ? a : b);
  return SlotFit(
    overlaps: overlaps,
    freeUntilUtc: until,
    next: next != null && until == next ? nextTask : null,
  );
}
