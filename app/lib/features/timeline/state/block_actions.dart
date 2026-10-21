import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
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
