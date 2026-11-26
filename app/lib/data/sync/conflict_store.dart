import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/sync/sync_status.dart';

/// Reads the open conflicts and acts on them (the database side).
abstract interface class ConflictStore {
  Stream<List<SyncConflict>> watch(String userId);

  /// "Keep mine", "Keep theirs" or "Keep both" ([combined], notes only):
  /// writes the kept value as a new local edit where it isn't in use yet,
  /// closes the conflict, and says how to take it back (ED-194, ED-195).
  Future<Result<ConflictUndo, AppFailure>> resolve(
    String userId,
    String id,
    ConflictChoice choice, {
    String? combined,
  });

  /// Takes back a resolve: [undo]'s value as a new edit while the field
  /// still holds what was kept, else a new conflict (ED-194).
  Future<Result<void, AppFailure>> undo(String userId, ConflictUndo undo);
}
