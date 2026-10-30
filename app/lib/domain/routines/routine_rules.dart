import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/domain/validation/routine_validator.dart';
import 'package:timezone/timezone.dart' as tz;

/// A routine saved from [picked] tasks of a day (11 C2 "Save as
/// routine"): their order, lengths and gaps from the first start. It
/// starts at Wake Up when the first task does, ends at Bedtime when the
/// last one does, else keeps the first task's local time.
///
/// ```dart
/// routineFromSelection(picked, shape: shape, zone: berlin, …).anchor;
/// ```
Routine routineFromSelection(
  List<Occurrence> picked, {
  required DayShape shape,
  required tz.Location zone,
  required String id,
  required String userId,
  required String title,
  required DateTime nowUtc,
  required String Function() newId,
}) {
  final timed = [
    for (final o in picked)
      if (o.startUtc != null) o,
  ]..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));
  final first = timed.first.startUtc!;
  final items = [
    for (final o in timed.take(maxRoutineItems))
      RoutineItem(
        id: newId(),
        title: o.title,
        colorKey: o.colorKey,
        iconKey: o.iconKey,
        offsetMin: o.startUtc!.difference(first).inMinutes,
        durationMin: o.durationMin,
        soundId: o.soundId,
      ),
  ];
  final lastEnd = timed
      .map((o) => o.endUtc!)
      .reduce((a, b) => a.isAfter(b) ? a : b);
  final anchor = first == shape.wakeUtc
      ? RoutineAnchor.wake
      : lastEnd == shape.bedUtc
      ? RoutineAnchor.bed
      : RoutineAnchor.time;
  return Routine(
    id: id,
    userId: userId,
    title: title,
    anchor: anchor,
    anchorMinute: anchor == RoutineAnchor.time
        ? ClockTime.ofUtc(zone, first).minutesOfDay
        : null,
    items: items,
    createdAt: nowUtc,
    updatedAt: nowUtc,
  );
}

/// Where [routine]'s first step starts on [date] in [zone], given that
/// day's [shape] (Wake Up / Bedtime).
DateTime routineStartUtc(
  Routine routine, {
  required DayShape shape,
  required tz.Location zone,
  required DateTime date,
}) => switch (routine.anchor) {
  RoutineAnchor.wake => shape.wakeUtc,
  RoutineAnchor.bed => shape.bedUtc.subtract(
    Duration(minutes: routine.spanMinutes),
  ),
  RoutineAnchor.time => ClockTime.fromMinutes(
    routine.anchorMinute ?? 0,
  ).onDate(zone, date),
};

/// One planned task per step of [routine] from [startUtc], in [tzId]
/// (11 C2 "Drop"): what the drop proposes. The first step carries
/// [Occurrence.routineStart], so its start rings like an alarm (A0).
List<Occurrence> routineTasks(
  Routine routine, {
  required DateTime startUtc,
  required String tzId,
  required DateTime nowUtc,
  required String Function() newId,
}) {
  final items = [...routine.items]
    ..sort((a, b) => a.offsetMin.compareTo(b.offsetMin));
  return [
    for (final (i, item) in items.indexed)
      Occurrence(
        id: newId(),
        userId: routine.userId,
        title: item.title,
        colorKey: item.colorKey,
        iconKey: item.iconKey,
        startUtc: startUtc.add(Duration(minutes: item.offsetMin)),
        tzId: tzId,
        durationMin: item.durationMin,
        soundId: item.soundId,
        routineStart: i == 0,
        createdAt: nowUtc,
        updatedAt: nowUtc,
      ),
  ];
}
