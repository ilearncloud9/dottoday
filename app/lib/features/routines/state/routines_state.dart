import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Saves [routine] (new or edited) as one undoable write, stamped now.
Future<Result<UndoToken, AppFailure>> saveRoutine(
  ProviderContainer ref,
  Routine routine,
) => ref
    .read(undoServiceProvider)
    .applyUndoable(
      WriteBatch(
        userId: routine.userId,
        routines: [
          routine.copyWith(updatedAt: ref.read(clockProvider).nowUtc()),
        ],
      ),
    );

/// Deletes [routine] (soft, with Undo); dropped tasks are not touched.
Future<Result<UndoToken, AppFailure>> deleteRoutine(
  ProviderContainer ref,
  Routine routine,
) {
  final now = ref.read(clockProvider).nowUtc();
  return ref
      .read(undoServiceProvider)
      .applyUndoable(
        WriteBatch(
          userId: routine.userId,
          routines: [routine.copyWith(deletedAt: now, updatedAt: now)],
        ),
      );
}

/// A blank routine for "New routine": one empty step from Wake Up.
Routine blankRoutine({
  required String userId,
  required DateTime nowUtc,
  IdGenerator ids = const UuidV7Generator(),
}) => Routine(
  id: ids.newId(),
  userId: userId,
  title: '',
  items: [
    RoutineItem(id: ids.newId(), title: '', offsetMin: 0, durationMin: 15),
  ],
  createdAt: nowUtc,
  updatedAt: nowUtc,
);
