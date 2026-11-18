import 'package:dottoday/shared/dot/thread.dart';
import 'package:timezone/timezone.dart' as tz;

/// [entries] on the hour scale (E-FullA-v2 web Day, M19.2 part 2): each
/// task and free gap stands for its time, up to where the next one starts
/// (an overlapping task's row ends where the next row begins, so the rows
/// stay in time order), and carries the whole local hours of [zone]
/// inside it, labelled by [label]. Caps, now and knots carry no time.
///
/// ```dart
/// dayHours(entries, zone: berlin, pxPerMinute: 70 / 60,
///     label: (h) => '$h:00').spans[1]; // (minutes: 45, marks: [(at: 1/3, …)])
/// ```
ThreadHours dayHours(
  List<ThreadEntry> entries, {
  required tz.Location zone,
  required double pxPerMinute,
  required String Function(DateTime local) label,
}) {
  final times = [for (final e in entries) _time(e)];
  final spans = <ThreadHourSpan?>[];
  for (final (i, t) in times.indexed) {
    if (t == null) {
      spans.add(null);
      continue;
    }
    var end = t.end;
    for (final next in times.skip(i + 1)) {
      if (next == null) continue;
      if (next.start.isBefore(end)) end = next.start;
      break;
    }
    if (!end.isAfter(t.start)) end = t.start;
    spans.add(_span(t.start, end, zone, label));
  }
  return ThreadHours(spans: spans, pxPerMinute: pxPerMinute);
}

typedef _Time = ({DateTime start, DateTime end});

_Time? _time(ThreadEntry e) => switch (e) {
  ThreadTaskEntry(task: ThreadTask(startUtc: final at?, :final minutes)) => (
    start: at,
    end: at.add(Duration(minutes: minutes)),
  ),
  ThreadGap(startUtc: final at?, :final minutes) => (
    start: at,
    end: at.add(Duration(minutes: minutes)),
  ),
  _ => null,
};

ThreadHourSpan _span(
  DateTime start,
  DateTime end,
  tz.Location zone,
  String Function(DateTime local) label,
) {
  final minutes = end.difference(start).inMinutes;
  final local = tz.TZDateTime.from(start, zone);
  var hour = tz.TZDateTime(
    zone,
    local.year,
    local.month,
    local.day,
    local.hour,
  );
  if (hour.isBefore(local)) hour = hour.add(const Duration(hours: 1));
  final marks = <ThreadHourMark>[];
  final length = end.difference(start).inSeconds;
  while (length > 0 && hour.isBefore(end)) {
    marks.add((
      at: hour.difference(start).inSeconds / length,
      label: label(hour),
    ));
    hour = hour.add(const Duration(hours: 1));
  }
  return (minutes: minutes, marks: marks);
}
