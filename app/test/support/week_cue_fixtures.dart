import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';

import 'timeline_fakes.dart';

// Week board cue fixtures (docs/09 M10.6, M10.7 follow-up), on the demo
// week at Wed 21 Oct 2026, 09:22 in Berlin.

/// The demo week's "now".
final weekCueNow = DateTime.utc(2026, 10, 21, 7, 22);

/// A planned task `cue-[day]` on [day] Oct 2026 at 9:00 Berlin for
/// [minutes], moved [moves] times.
Occurrence weekCueTask(
  int day,
  String title, {
  int moves = 0,
  int minutes = 150,
}) {
  final base = demoWeekRows().firstWhere(
    (o) => o.startUtc!.day == day && o.status == OccurrenceStatus.planned,
  );
  return base.copyWith(
    id: 'cue-$day',
    title: title,
    startUtc: DateTime.utc(2026, 10, day, 7),
    durationMin: minutes,
    moveCount: moves,
  );
}

/// One step not started on `cue-21`, so Smallest step asks at 9:22.
List<Subtask> weekCueSteps() => [
  Subtask(
    id: 'step-1',
    userId: testUserId,
    occurrenceId: 'cue-21',
    title: 'Gather documents',
    durationMin: 10,
    createdAt: weekCueNow,
    updatedAt: weekCueNow,
  ),
];
