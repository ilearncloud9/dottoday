import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:timezone/timezone.dart' as tz;

import 'timeline_fakes.dart';

/// [count] finished high-energy "Write report" runs, one a day back from
/// 20 Oct 2026, each really started at [hour]:15 Berlin (docs/09 M11.5).
List<Occurrence> energyHistory({int count = 20, int hour = 9}) {
  final berlin = tz.getLocation('Europe/Berlin');
  final base = demoDayRows(DateTime(2026, 10, 21)).first;
  return [
    for (var i = 0; i < count; i++)
      () {
        final day = DateTime(2026, 10, 20 - i);
        final start = tz.TZDateTime(
          berlin,
          day.year,
          day.month,
          day.day,
          hour,
          15,
        ).toUtc();
        return base.copyWith(
          id: '01928c3e-0000-7000-8000-0000000ee${i.toString().padLeft(3, '0')}',
          title: 'Write report',
          seriesId: null,
          energy: Energy.high,
          status: OccurrenceStatus.done,
          startUtc: start,
          durationMin: 60,
          actualStartUtc: start,
          actualEndUtc: start.add(const Duration(minutes: 60)),
        );
      }(),
  ];
}
