import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:timezone/timezone.dart' as tz;

/// The earliest Wake Up or task start and the latest Wind Down or task
/// end of the week, in whole local hours, so every day fits one shared
/// axis (a 6:45 run or a late train stays on the board).
(int, int) gridAxisHours(
  List<DayShape> shapes,
  List<TimelineData> data,
  tz.Location zone,
) {
  var first = 24;
  var last = 0;
  void cover(DateTime startUtc, DateTime endUtc) {
    final start = ClockTime.ofUtc(zone, startUtc);
    final end = ClockTime.ofUtc(zone, endUtc);
    final sameDay =
        endUtc.difference(startUtc) < const Duration(days: 1) &&
        (end.hour > start.hour ||
            (end.hour == start.hour && end.minute >= start.minute));
    if (start.hour < first) first = start.hour;
    final through = !sameDay ? 24 : (end.minute > 0 ? end.hour + 1 : end.hour);
    if (through > last) last = through;
  }

  for (final s in shapes) {
    cover(s.wakeUtc, s.bedUtc);
  }
  for (final d in data) {
    for (final o in d.blocks) {
      if (o.startUtc case final at?) cover(at, o.endUtc!);
    }
  }
  return (first, last <= first ? first + 1 : last);
}
