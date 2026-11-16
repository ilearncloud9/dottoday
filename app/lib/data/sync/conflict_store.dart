import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/sync/sync_status.dart';

/// Reads the open conflicts and acts on them (the database side).
abstract interface class ConflictStore {
  Stream<List<SyncConflict>> watch(String userId);

  /// "Keep mine": writes the device's value again, as a new local edit.
  Future<Result<void, AppFailure>> keepMine(String userId, String id);

  /// "Keep theirs": the server value already applies; closes the conflict.
  Future<void> close(String id);
}
