import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:dottoday/shared/dot/thread_picker_pieces.dart';
import 'package:timezone/timezone.dart' as tz;

/// [blocks] as `ThreadPicker` neighbours on [date] in [location]: minutes
/// from that day's local midnight. All-day and skipped items, and
/// [exceptId] (the task being placed), are left out — they take no time
/// on the thread.
List<PickerBlock> pickerBlocks(
  Iterable<Occurrence> blocks,
  tz.Location location,
  DateTime date, {
  String? exceptId,
}) {
  final midnight = const ClockTime(0, 0).onDate(location, date);
  int minuteOf(DateTime utc) => utc.difference(midnight).inMinutes;
  return [
    for (final o in blocks)
      if (o.startUtc != null &&
          o.id != exceptId &&
          o.durationMin < maxDurationMin &&
          o.status != OccurrenceStatus.skipped)
        PickerBlock(
          id: o.id,
          title: o.title,
          color: TaskColor.fromKey(o.colorKey),
          icon: TaskIcon.fromKey(o.iconKey),
          startMinute: minuteOf(o.startUtc!),
          endMinute: minuteOf(o.endUtc!),
        ),
  ];
}
