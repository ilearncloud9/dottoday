import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:timezone/timezone.dart' as tz;

import 'timeline_fakes.dart';

// The Reality thread on the demo day (docs/09 M11.2, `B-ios-reality-
// thread`), Berlin, Wed 21 Oct 2026 at 09:22: Morning run (planned 6:45)
// really ran 6:57–7:31; Coffee was ticked with no actuals; Deep work
// (planned 9:00–11:00) started at 9:10; Design review is next.

/// [demoDayRows] for [date] with the actual timestamps above.
List<Occurrence> realityDayRows([DateTime? date]) {
  final day = date ?? DateTime(2026, 10, 21);
  final berlin = tz.getLocation('Europe/Berlin');
  DateTime at(int h, int m) =>
      tz.TZDateTime(berlin, day.year, day.month, day.day, h, m).toUtc();
  return [
    for (final o in demoDayRows(day))
      switch (o.title) {
        'Morning run' => o.copyWith(
          actualStartUtc: at(6, 57),
          actualEndUtc: at(7, 31),
          status: OccurrenceStatus.done,
        ),
        'Deep work: roadmap' => o.copyWith(actualStartUtc: at(9, 10)),
        _ => o,
      },
  ];
}

/// Four earlier runs of Deep work (13–16 Oct), 140 min each against a
/// 120-min plan: learning says "usually 2 h 20" (M11.3).
List<Occurrence> deepWorkHistory() {
  final deep = demoDayRows(
    DateTime(2026, 10, 21),
  ).firstWhere((o) => o.title == 'Deep work: roadmap');
  return [
    for (var d = 13; d <= 16; d++)
      deep.copyWith(
        id: '01928c3e-0000-7000-8000-0000000e00$d',
        startUtc: DateTime.utc(2026, 10, d, 7),
        actualStartUtc: DateTime.utc(2026, 10, d, 7),
        actualEndUtc: DateTime.utc(2026, 10, d, 9, 20),
        status: OccurrenceStatus.done,
      ),
  ];
}
