import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/day_scheduler_service.dart';
import 'package:dottoday/domain/scheduling/schedule_result.dart';
import 'package:dottoday/domain/scheduling/task_progress.dart' as progress;
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Marks [o] done, or planned again if it is done, through the undoable
/// write path (docs/02 F1 "check a block done", R-11 undo). Completion is
/// on this occurrence only, never its series (R-09).
Future<Result<UndoToken, AppFailure>> toggleDone(WidgetRef ref, Occurrence o) {
  final changed = progress.toggleDone(o, ref.read(clockProvider).nowUtc());
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
  return _applyShift(ref.read(undoServiceProvider), live.userId, result);
}

/// Pushes what is left of [day] from [nowUtc] [minutes] later ("Running
/// late +5/+15/+30", docs/02 F1, R-04), up to the first pinned task. Null
/// when nothing is left to move. Takes a container: the Running late
/// sheet has closed by the time this runs.
Future<Result<(UndoToken, ShiftReport), AppFailure>>? runLate(
  ProviderContainer container, {
  required List<Occurrence> day,
  required DateTime nowUtc,
  required int minutes,
  bool includeCalendar = false,
  Set<String> readOnlyIds = const {},
}) {
  final result = const DaySchedulerService().runningLate(
    day,
    nowUtc,
    minutes,
    includeCalendar: includeCalendar,
    readOnlyIds: readOnlyIds,
  );
  if (result.report.movedIds.isEmpty) return null;
  return _applyShift(
    container.read(undoServiceProvider),
    day.first.userId,
    result,
  );
}

/// Writes [result]'s moved tasks as one undoable batch.
Future<Result<(UndoToken, ShiftReport), AppFailure>> _applyShift(
  UndoService undo,
  String userId,
  ScheduleResult result,
) async {
  final changed = [for (final id in result.report.movedIds) result.byId(id)];
  final applied = await undo.applyUndoable(
    WriteBatch(userId: userId, occurrences: changed),
  );
  return switch (applied) {
    Ok(:final value) => Ok((value, result.report)),
    Err(:final failure) => Err(failure),
  };
}

/// How far [live] runs into the next planned task (see `ThreadTask`).
int overrunOf(Occurrence live, List<Occurrence> blocks) {
  final next = blocks
      .where(
        (o) =>
            o.status == OccurrenceStatus.planned &&
            o.startUtc != null &&
            o.startUtc!.isAfter(live.startUtc!),
      )
      .fold<Occurrence?>(
        null,
        (a, o) => a == null || o.startUtc!.isBefore(a.startUtc!) ? o : a,
      );
  if (next == null) return 0;
  return live.endUtc!.difference(next.startUtc!).inMinutes;
}

/// Gives [o] [minutes] of travel time before it (docs/09 M7.5, R-17),
/// through the undoable write path; 0 removes it. The block itself stays
/// put: the buffer takes the time before its start.
Future<Result<UndoToken, AppFailure>> setTravelTime(
  WidgetRef ref,
  Occurrence o,
  int minutes,
) => ref
    .read(undoServiceProvider)
    .applyUndoable(
      WriteBatch(
        userId: o.userId,
        occurrences: [o.copyWith(travelBufferMin: minutes)],
      ),
    );
