import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/onboarding/starter_habits.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:timezone/timezone.dart' as tz;

import 'fake_ids.dart';
import 'timeline_fakes.dart';

/// Morning run, Lunch and Read on Thu 22 Oct 2026 in Berlin (07:00–22:00),
/// as O3 would plant them.
List<Occurrence> firstThreadRows() {
  final berlin = tz.getLocation('Europe/Berlin');
  return starterTasks(
    picked: const [
      StarterHabit.morningRun,
      StarterHabit.lunch,
      StarterHabit.read,
    ],
    titleOf: (h) => switch (h) {
      StarterHabit.morningRun => 'Morning run',
      StarterHabit.lunch => 'Lunch',
      _ => 'Read',
    },
    shape: DayShape(
      wakeUtc: tz.TZDateTime(berlin, 2026, 10, 22, 7).toUtc(),
      bedUtc: tz.TZDateTime(berlin, 2026, 10, 22, 22).toUtc(),
    ),
    zone: berlin,
    userId: testUserId,
    nowUtc: DateTime.utc(2026, 10, 21, 9),
    ids: FakeIds('first'),
  );
}
