import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/timeline/layout/drag_math.dart';
import 'package:dottoday/features/timeline/layout/timeline_day.dart';
import 'package:dottoday/features/timeline/state/timeline_interaction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Outcome of a drop: the written block, whether it had to settle after a
/// pinned block, and the undo token.
typedef DropOutcome = ({
  Result<UndoToken, AppFailure> result,
  Occurrence moved,
  bool settled,
});

/// The block [s] would become on [day], with a move settled past pinned
/// blocks among [others] (docs/03 §3.2; resizes may overlap, like any
/// overlap the user chooses).
(Occurrence, bool) droppedBlock(
  DragSession s,
  TimelineDay day,
  Iterable<Occurrence> others,
) {
  var slot = s.proposed;
  var settled = false;
  if (s.mode == DragMode.move) {
    final pinned = [
      for (final o in others)
        if (o.pinned && o.id != s.block.id && o.startUtc != null)
          (start: day.minuteOf(o.startUtc!).round(), duration: o.durationMin),
    ];
    (slot, settled) = settleAfterPinned(slot, pinned);
  }
  final moved = s.block.copyWith(
    startUtc: day.startUtc.add(Duration(minutes: slot.start)),
    durationMin: slot.duration,
  );
  return (moved, settled);
}

/// Writes the drop through the undoable write path (R-11).
Future<DropOutcome> dropBlock(
  WidgetRef ref,
  DragSession s,
  TimelineDay day,
  Iterable<Occurrence> others,
) async {
  final (moved, settled) = droppedBlock(s, day, others);
  final result = await ref
      .read(undoServiceProvider)
      .applyUndoable(WriteBatch(userId: moved.userId, occurrences: [moved]));
  return (result: result, moved: moved, settled: settled);
}
