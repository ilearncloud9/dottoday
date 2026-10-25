import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/thinking/model_output.dart';

/// Unstick (11 B3, docs/09 M10.7): a task with no steps that has been
/// moved this many times asks for its very first step — never on the first
/// move.
const unstickAfterMoves = 3;

/// The server's ceiling for `move_count` (0006).
const maxMoveCount = 1000;

/// [moved] as the move actions write it: one more move when its start
/// differs from [before]'s. Drag, Running late and Rebalance call this;
/// an edit in the editor never does.
///
/// ```dart
/// countMove(task, task.copyWith(startUtc: later)).moveCount; // +1
/// ```
Occurrence countMove(Occurrence before, Occurrence moved) {
  if (before.startUtc == moved.startUtc) return moved;
  final count = (before.moveCount + 1).clamp(0, maxMoveCount);
  return moved.copyWith(moveCount: count);
}

/// [moved] rows with their moves counted against [before] (by id); a row
/// with no earlier version is returned as it is.
List<Occurrence> countMoves(
  Iterable<Occurrence> before,
  Iterable<Occurrence> moved,
) {
  final byId = {for (final o in before) o.id: o};
  return [
    for (final o in moved)
      if (byId[o.id] case final b?) countMove(b, o) else o,
  ];
}

/// Whether [o] shows the Unstick row: planned, moved [unstickAfterMoves]
/// times or more, and no step yet among [steps].
bool showsUnstick(Occurrence o, Iterable<Subtask> steps) =>
    o.deletedAt == null &&
    o.status == OccurrenceStatus.planned &&
    o.moveCount >= unstickAfterMoves &&
    !steps.any((s) => s.deletedAt == null);

/// The rows the Unstick answer writes, in one batch: [answer] as step 1
/// of [o] and its move count back to 0. Null for a blank answer.
({Subtask step, Occurrence task})? unstickAnswer(
  Occurrence o,
  String answer, {
  required String stepId,
  required DateTime nowUtc,
}) {
  final clean = answer.trim();
  if (clean.isEmpty) return null;
  final title = clean.length <= ModelOutput.maxTitle
      ? clean
      : clean.substring(0, ModelOutput.maxTitle);
  return (
    step: Subtask(
      id: stepId,
      userId: o.userId,
      occurrenceId: o.id,
      title: title,
      sortOrder: 1,
      createdAt: nowUtc,
      updatedAt: nowUtc,
    ),
    task: o.copyWith(moveCount: 0, updatedAt: nowUtc),
  );
}
