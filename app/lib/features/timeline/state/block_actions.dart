import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/day_scheduler_service.dart';
import 'package:dottoday/domain/scheduling/schedule_result.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Marks [o] done, or planned again if it is done, through the undoable
/// write path (docs/02 F1 "check a block done", R-11 undo). Completion is
/// on this occurrence only, never its series (R-09).
Future<Result<UndoToken, AppFailure>> toggleDone(WidgetRef ref, Occurrence o) {
  final done = o.status == OccurrenceStatus.done;
  final changed = o.copyWith(
    status: done ? OccurrenceStatus.planned : OccurrenceStatus.done,
    completedAtUtc: done ? null : ref.read(clockProvider).nowUtc(),
  );
  return ref
      .read(undoServiceProvider)
      .applyUndoable(WriteBatch(userId: o.userId, occurrences: [changed]));
}

/// Gives the live task [o] [minutes] more (LiveRow "+15 min", R-04).
/// Later tasks stay put; if they now overlap, "Shift the rest" offers to
/// move them.
Future<Result<UndoToken, AppFailure>> extendTask(
  WidgetRef ref,
  Occurrence o, {
  int minutes = 15,
}) => ref
    .read(undoServiceProvider)
    .applyUndoable(
      WriteBatch(
        userId: o.userId,
        occurrences: [o.copyWith(durationMin: o.durationMin + minutes)],
      ),
    );

/// Moves every task after [live] by its [overrunMinutes] so nothing
/// overlaps it any more (LiveRow "Shift the rest", R-04). Stops at the
/// first pinned task, which the report names (R-17).
Future<Result<(UndoToken, ShiftReport), AppFailure>> shiftRest(
  WidgetRef ref, {
  required List<Occurrence> day,
  required Occurrence live,
  required int overrunMinutes,
}) async {
  final result = const DaySchedulerService().runningLate(
    day,
    live.endUtc!.subtract(Duration(minutes: overrunMinutes)),
    overrunMinutes,
  );
  final changed = [for (final id in result.report.movedIds) result.byId(id)];
  final applied = await ref
      .read(undoServiceProvider)
      .applyUndoable(WriteBatch(userId: live.userId, occurrences: changed));
  return switch (applied) {
    Ok(:final value) => Ok((value, result.report)),
    Err(:final failure) => Err(failure),
  };
}
