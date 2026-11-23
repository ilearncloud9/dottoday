import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';

/// A schedule (ED-084): the weekdays that share one Wake Up and Wind Down.
/// Schedules aren't stored; they are the stored per-weekday windows,
/// grouped.
typedef DaySchedule = ({List<Weekday> days, TimeWindow window});

/// How a schedule is named on its card.
enum ScheduleKind { everyDay, weekdays, weekend, days }

/// [s]'s schedules in week order from [firstDay] (ISO 1–7): one per
/// distinct window, each with its days in week order.
///
/// ```dart
/// schedulesOf(const Settings()); // [(days: Mon–Sun, window: 07:00–22:00)]
/// ```
List<DaySchedule> schedulesOf(Settings s, {int firstDay = 1}) {
  final order = [
    for (var i = 0; i < 7; i++) Weekday.values[(firstDay - 1 + i) % 7],
  ];
  final byWindow = <TimeWindow, List<Weekday>>{};
  for (final d in order) {
    byWindow.putIfAbsent(s.boundaryFor(d), () => []).add(d);
  }
  return [
    for (final MapEntry(key: window, value: days) in byWindow.entries)
      (days: days, window: window),
  ];
}

/// Every day, Monday to Friday, Saturday and Sunday, or other days.
ScheduleKind scheduleKind(List<Weekday> days) {
  final set = days.toSet();
  if (set.length == 7) return ScheduleKind.everyDay;
  const weekdays = {
    Weekday.mon,
    Weekday.tue,
    Weekday.wed,
    Weekday.thu,
    Weekday.fri,
  };
  if (set.length == 5 && set.containsAll(weekdays)) {
    return ScheduleKind.weekdays;
  }
  if (set.length == 2 && set.containsAll({Weekday.sat, Weekday.sun})) {
    return ScheduleKind.weekend;
  }
  return ScheduleKind.days;
}

/// Minutes of the night after [day]: from its Wind Down to the next
/// morning's Wake Up (ED-084: Friday's night ends at Saturday's Wake Up).
///
/// ```dart
/// nightAfter(const Settings(), Weekday.mon); // 540: 22:00 → 07:00
/// ```
int nightAfter(Settings s, Weekday day) {
  final windDown = windowMinutes(s.boundaryFor(day).end);
  final next = Weekday.values[(day.index + 1) % 7];
  final wake = windowMinutes(s.boundaryFor(next).start);
  return wake + Duration.minutesPerDay - windDown;
}
