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
