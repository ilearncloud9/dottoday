import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/scheduling/start_nudge.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

// The one "still not started" trigger (11 B2, A0; docs/09 M10.6).

void main() {
  final start = DateTime.utc(2026, 10, 21, 9);
  final task = occurrenceFixture().copyWith(startUtc: start, durationMin: 60);

  test('planned start + 10 min, only while nobody started it', () {
    expect(noStartAt(task), start.add(const Duration(minutes: 10)));
    expect(
      noStartAt(task, afterMin: 20),
      start.add(const Duration(minutes: 20)),
    );
    expect(noStartAt(task.copyWith(actualStartUtc: start)), isNull);
    expect(noStartAt(task.copyWith(status: OccurrenceStatus.done)), isNull);
    expect(noStartAt(task.copyWith(status: OccurrenceStatus.skipped)), isNull);
    expect(noStartAt(task.copyWith(startUtc: null)), isNull, reason: 'Inbox');
    expect(noStartAt(task.copyWith(deletedAt: t1)), isNull);
    expect(
      noStartAt(task.copyWith(durationMin: 10)),
      isNull,
      reason: 'over before anyone would be asked',
    );
  });

  test('the step offered: first live open one, in order', () {
    final steps = [
      subtaskFixture().copyWith(id: 'c', sortOrder: 3),
      subtaskFixture().copyWith(id: 'a', sortOrder: 1, done: true),
      subtaskFixture().copyWith(id: 'x', sortOrder: 0, deletedAt: t1),
      subtaskFixture().copyWith(id: 'b', sortOrder: 2),
    ];
    expect(smallestStep(steps)!.id, 'b');
    expect(smallestStep([steps[1]]), isNull);
  });

  test('the row asks from the trigger until the planned end', () {
    final steps = [subtaskFixture()];
    expect(
      smallestStepAt(task, steps, start.add(const Duration(minutes: 9))),
      isNull,
    );
    expect(
      smallestStepAt(task, steps, start.add(const Duration(minutes: 10))),
      isNotNull,
    );
    expect(
      smallestStepAt(task, steps, start.add(const Duration(minutes: 60))),
      isNull,
    );
    expect(
      smallestStepAt(task, const [], start.add(const Duration(minutes: 30))),
      isNull,
    );
  });
}
