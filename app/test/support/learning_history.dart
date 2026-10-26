import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';

import '../features/task_editor/add_harness.dart';

/// "Write report" planned 9:00 for 60 min on 13–16 Oct, really started
/// 15 min after and took 80: four runs, so learning speaks ("usually
/// 1 h 20", "usually starts ~15 min after plan"; docs/13 §2).
List<Occurrence> writeReportHistory() => [
  for (var d = 13; d <= 16; d++)
    demoTimed().first.copyWith(
      id: '01928c3e-0000-7000-8000-0000000d00$d',
      title: 'Write report',
      seriesId: null,
      startUtc: DateTime.utc(2026, 10, d, 7),
      durationMin: 60,
      actualStartUtc: DateTime.utc(2026, 10, d, 7, 15),
      actualEndUtc: DateTime.utc(2026, 10, d, 8, 35),
      status: OccurrenceStatus.done,
    ),
];
