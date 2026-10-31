import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/day_blocks.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/domain/validation/field_rules.dart';

/// How full a waking day is (docs/10 §6 "Wake Up / Wind Down drive … free-time
/// maths, capacity rings, the week's Free · unplanned").
final class DayCapacity {
  const DayCapacity({required this.awakeMinutes, required this.busyMinutes});

  /// Wake Up → Wind Down.
  final int awakeMinutes;

  /// Minutes of the waking day some task occupies, overlaps counted once.
  final int busyMinutes;

  /// The rest of the waking day ("Free · unplanned").
  int get freeMinutes => awakeMinutes - busyMinutes;

  /// 0–1: the capacity ring's sweep.
  double get share => awakeMinutes <= 0 ? 0 : busyMinutes / awakeMinutes;
}

/// [blocks]' footprint inside [shape]'s waking day: the union of the time
/// each occupying task (travel buffer included, skipped and all-day ones
/// left out) spends between Wake Up and Wind Down.
///
/// ```dart
/// capacityOf([nineToEleven, tenToTwelve], shape).busyMinutes; // 180
/// ```
DayCapacity capacityOf(Iterable<Occurrence> blocks, DayShape shape) {
  final wake = shape.wakeUtc;
  final bed = shape.bedUtc;
  var busy = 0;
  DateTime? cursor;
  final busyBlocks = [
    for (final o in scheduledBlocks(blocks))
      if (occupiesTime(o) && o.durationMin < maxDurationMin) o,
  ]..sort((a, b) => footprintStart(a).compareTo(footprintStart(b)));
  for (final o in busyBlocks) {
    var from = footprintStart(o);
    var to = o.endUtc!;
    if (from.isBefore(wake)) from = wake;
    if (to.isAfter(bed)) to = bed;
    if (cursor != null && from.isBefore(cursor)) from = cursor;
    if (!to.isAfter(from)) continue;
    busy += to.difference(from).inMinutes;
    cursor = to;
  }
  return DayCapacity(awakeMinutes: shape.awakeMinutes, busyMinutes: busy);
}
