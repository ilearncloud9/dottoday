import 'dart:math' as math;

import 'package:dottoday/domain/validation/field_rules.dart';

/// What a gesture changes on a block.
enum DragMode { move, resizeStart, resizeEnd }

/// A proposed block position in elapsed minutes from the day start.
typedef Slot = ({int start, int duration});

/// [minute] rounded to the nearest multiple of [snap] (settings
/// `snapMinutes`, default 5, R-16). The grid starts at local midnight.
int snapMinute(double minute, int snap) => (minute / snap).round() * snap;

/// Where a block lands while dragged: the pointer minus where it was
/// grabbed, snapped, kept inside the day. It may still run past midnight
/// (blocks crossing midnight are allowed).
Slot moveSlot({
  required double pointerMin,
  required double grabOffsetMin,
  required int duration,
  required int snap,
  required double dayMinutes,
}) {
  final latest = (dayMinutes - minDurationMin).floor();
  final start = snapMinute(pointerMin - grabOffsetMin, snap).clamp(0, latest);
  return (start: start, duration: duration);
}

/// Dragging the top edge: the end stays put, the start follows the pointer
/// within 5 min – 24 h of the end and not before the day start.
Slot resizeStartSlot({
  required double pointerMin,
  required Slot original,
  required int snap,
}) {
  final end = original.start + original.duration;
  final earliest = math.max(0, end - maxDurationMin);
  final start = snapMinute(
    pointerMin,
    snap,
  ).clamp(earliest, end - minDurationMin);
  return (start: start, duration: end - start);
}

/// Dragging the bottom edge: the start stays put, the end follows the
/// pointer within 5 min – 24 h of the start.
Slot resizeEndSlot({
  required double pointerMin,
  required Slot original,
  required int snap,
}) {
  final end = snapMinute(
    pointerMin,
    snap,
  ).clamp(original.start + minDurationMin, original.start + maxDurationMin);
  return (start: original.start, duration: end - original.start);
}

/// Moves [slot] past every pinned interval it overlaps, in order, so a drop
/// never lands on a pinned block (docs/03 §3.2, R-17). Returns the settled
/// slot and whether it had to move.
(Slot, bool) settleAfterPinned(Slot slot, Iterable<Slot> pinned) {
  final sorted = pinned.toList()..sort((a, b) => a.start - b.start);
  var start = slot.start;
  var moved = false;
  for (final p in sorted) {
    final pEnd = p.start + p.duration;
    if (start < pEnd && start + slot.duration > p.start) {
      start = pEnd;
      moved = true;
    }
  }
  return ((start: start, duration: slot.duration), moved);
}

/// Auto-scroll speed in px per frame for a pointer [distance] px inside an
/// edge zone of [zone] px: 0 at the zone's inner edge, [max] at the edge.
double autoScrollSpeed(double distance, {double zone = 64, double max = 18}) {
  if (distance >= zone) return 0;
  final depth = 1 - math.max(0, distance) / zone;
  return max * depth * depth;
}
