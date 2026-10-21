import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/undo/undo_service.dart';

/// Soft delete with a 30-day restore window (docs/05 `trash`, R-11).
abstract interface class TrashService {
  /// How long deleted rows stay restorable.
  static const retention = Duration(days: 30);

  /// Occurrences deleted within [retention], most recently deleted first.
  Stream<List<Occurrence>> watchTrash(String userId);

  /// Moves occurrences (and their live subtasks) to Trash, undoable for
  /// [UndoService.window].
  Future<Result<UndoToken, AppFailure>> trashOccurrences(
    String userId,
    Set<String> ids,
  );

  /// Brings occurrences back from Trash with the subtasks trashed with
  /// them. Ids not in Trash are ignored.
  Future<Result<void, AppFailure>> restoreOccurrences(
    String userId,
    Set<String> ids,
  );

  /// Hard-deletes rows deleted more than [retention] ago that the server
  /// already has. Returns how many rows were removed.
  Future<Result<int, AppFailure>> purgeExpired(String userId);
}
