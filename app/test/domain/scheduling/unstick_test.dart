import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/scheduling/unstick.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

// Unstick (11 B3, docs/09 M10.7): moves are counted by the move actions
// only; three moves and no steps ask for the very first step; the answer
// becomes step 1 and the count starts over.

void main() {
  final start = DateTime.utc(2026, 10, 21, 9);
  final task = occurrenceFixture().copyWith(startUtc: start);

  test('a move counts when the start changes, never otherwise', () {
    final later = task.copyWith(startUtc: start.add(const Duration(days: 1)));
    expect(countMove(task, later).moveCount, 1);
    expect(countMove(task, task.copyWith(title: 'x')).moveCount, 0);
    expect(
      countMove(task.copyWith(moveCount: maxMoveCount), later).moveCount,
      maxMoveCount,
    );
  });

  test('a batch counts each row against its earlier version', () {
    final other = occurrenceFixture().copyWith(id: 'other', startUtc: start);
    final moved = countMoves(
      [task, other],
      [
        task.copyWith(startUtc: start.add(const Duration(hours: 1))),
        other,
        occurrenceFixture().copyWith(id: 'new', startUtc: start),
      ],
    );
    expect(moved.map((o) => o.moveCount), [1, 0, 0]);
  });

  test(
    'the row: three moves, no steps, still planned — never the first move',
    () {
      expect(showsUnstick(task.copyWith(moveCount: 1), const []), isFalse);
      expect(showsUnstick(task.copyWith(moveCount: 2), const []), isFalse);
      expect(showsUnstick(task.copyWith(moveCount: 3), const []), isTrue);
      expect(
        showsUnstick(task.copyWith(moveCount: 5), [subtaskFixture()]),
        isFalse,
      );
      expect(
        showsUnstick(task.copyWith(moveCount: 5), [
          subtaskFixture().copyWith(deletedAt: t1),
        ]),
        isTrue,
        reason: 'a step in Trash is no step',
      );
      expect(
        showsUnstick(
          task.copyWith(moveCount: 3, status: OccurrenceStatus.done),
          const [],
        ),
        isFalse,
      );
    },
  );

  test('the answer becomes step 1 and the count starts over', () {
    final rows = unstickAnswer(
      task.copyWith(moveCount: 4),
      '  Open the folder ',
      stepId: 's1',
      nowUtc: t1,
    )!;
    expect(
      (rows.step.title, rows.step.sortOrder, rows.step.occurrenceId),
      ('Open the folder', 1.0, task.id),
    );
    expect((rows.task.moveCount, rows.task.updatedAt), (0, t1));
    expect(unstickAnswer(task, '   ', stepId: 's', nowUtc: t1), isNull);
    expect(
      unstickAnswer(
        task,
        'x' * 300,
        stepId: 's',
        nowUtc: t1,
      )!.step.title.length,
      200,
    );
  });
}
