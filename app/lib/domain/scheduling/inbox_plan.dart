import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/schedule_result.dart';
import 'package:dottoday/domain/scheduling/slot_finder.dart';

/// The rest of a day, for fitting inbox items into it (docs/02 F3).
final class DayRoom {
  const DayRoom({
    required this.blocks,
    required this.fromUtc,
    required this.startUtc,
    required this.endUtc,
    this.snapMinutes = 5,
  });

  /// The day's timed tasks.
  final List<Occurrence> blocks;

  /// Nothing earlier is offered (now, on today).
  final DateTime fromUtc;

  /// Wake Up and Wind Down.
  final DateTime startUtc;
  final DateTime endUtc;
  final int snapMinutes;

  /// This room with [o] booked too (auto-plan places one after another).
  DayRoom withBlock(Occurrence o) => DayRoom(
    blocks: [...blocks, o],
    fromUtc: fromUtc,
    startUtc: startUtc,
    endUtc: endUtc,
    snapMinutes: snapMinutes,
  );

  /// The first free slots for [minutes], earliest first.
  List<Slot> slotsFor(int minutes, {int limit = 1}) => findSlots(
    blocks,
    minutes,
    fromUtc: fromUtc,
    dayStartUtc: startUtc,
    dayEndUtc: endUtc,
    snapMinutes: snapMinutes,
    limit: limit,
  );
}

/// Inbox items still to do (not done or skipped).
Iterable<Occurrence> openItems(Iterable<Occurrence> items) =>
    items.where((o) => o.status == OccurrenceStatus.planned);

/// "5 unscheduled · 5 h 15 of work": open items and their total minutes.
({int count, int minutes}) inboxWork(Iterable<Occurrence> items) {
  final open = openItems(items).toList();
  return (
    count: open.length,
    minutes: open.fold(0, (sum, o) => sum + o.durationMin),
  );
}

/// The open item that can start soonest in [room], with its slot
/// (`NextFreeSlot`, "Next free slot today: 11:30 – 12:30 · fits Go for a
/// run"); ties go to the item listed first. Null when nothing fits.
({Occurrence item, Slot slot})? nextFreeSlot(
  Iterable<Occurrence> items,
  DayRoom room,
) {
  ({Occurrence item, Slot slot})? best;
  for (final o in openItems(items)) {
    final slot = room.slotsFor(o.durationMin).firstOrNull;
    if (slot == null) continue;
    if (best == null || slot.startUtc.isBefore(best.slot.startUtc)) {
      best = (item: o, slot: slot);
    }
  }
  return best;
}
