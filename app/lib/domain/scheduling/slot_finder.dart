import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/day_blocks.dart';
import 'package:dottoday/domain/scheduling/schedule_result.dart';

/// The first free slots of [durationMin] in `[max(fromUtc, dayStartUtc),
/// dayEndUtc)`, one per gap, earliest first, at most [limit] (R-17).
///
/// Slot starts snap up to a multiple of [snapMinutes] counted from
/// [dayStartUtc] (the local day boundary), so suggestions land on the same
/// grid as dragging. Travel buffers count as busy. Energy windows are Phase 2
/// (docs/02) and not considered.
List<Slot> findSlots(
  List<Occurrence> day,
  int durationMin, {
  required DateTime fromUtc,
  required DateTime dayStartUtc,
  required DateTime dayEndUtc,
  int snapMinutes = 5,
  int limit = 3,
}) {
  final need = Duration(minutes: durationMin);
  final slots = <Slot>[];
  var cursor = fromUtc.isAfter(dayStartUtc) ? fromUtc : dayStartUtc;

  void offer(DateTime gapEnd) {
    final start = _snapUp(cursor, dayStartUtc, snapMinutes);
    final end = start.add(need);
    final limitEnd = gapEnd.isBefore(dayEndUtc) ? gapEnd : dayEndUtc;
    if (slots.length < limit && !end.isAfter(limitEnd)) {
      slots.add(Slot(start, end));
    }
  }

  for (final block in scheduledBlocks(day).where(occupiesTime)) {
    final busyStart = footprintStart(block);
    if (busyStart.isAfter(cursor)) offer(busyStart);
    final end = block.endUtc!;
    if (end.isAfter(cursor)) cursor = end;
  }
  offer(dayEndUtc);
  return slots;
}

DateTime _snapUp(DateTime t, DateTime origin, int snapMinutes) {
  final step = snapMinutes * Duration.millisecondsPerMinute;
  final offset = t.difference(origin).inMilliseconds;
  final steps = (offset + step - 1) ~/ step;
  return origin.add(Duration(milliseconds: steps * step));
}
