import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/writes/write_batch.dart';

/// The single write path for user data (docs/04 §4, docs/09 M2.3). Feature
/// notifiers call this, never a repository's write methods.
abstract interface class WriteUseCase {
  /// Validates and persists [batch] in one transaction: rows, `dirty` sync
  /// bookkeeping, `change_log` entries and series materialisation. After the
  /// commit it re-plans notifications and rewrites the widget snapshot;
  /// those never undo a committed write.
  ///
  /// Returns [ValidationFailure] for the first invalid row (nothing is
  /// written) or [StorageFailure] if the database rejects the write.
  Future<Result<void, AppFailure>> apply(WriteBatch batch);
}
