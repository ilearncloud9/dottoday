import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/validation/entity_validators.dart';
import 'package:dottoday/domain/validation/routine_validator.dart';
import 'package:dottoday/domain/writes/write_batch.dart';

/// Validates every row of [batch] (06 §7), returning the batch with
/// normalised rows (e.g. trimmed titles) or the first failure.
Result<WriteBatch, ValidationFailure> validateBatch(WriteBatch batch) {
  try {
    return Ok(
      WriteBatch(
        userId: batch.userId,
        profile: batch.profile == null
            ? null
            : _unwrap(validateProfile(batch.profile!)),
        series: [for (final s in batch.series) _unwrap(validateSeries(s))],
        occurrences: [
          for (final o in batch.occurrences) _unwrap(validateOccurrence(o)),
        ],
        subtasks: [for (final s in batch.subtasks) _unwrap(validateSubtask(s))],
        routines: [for (final r in batch.routines) _unwrap(validateRoutine(r))],
        // Hint records carry no user text; the schema CHECKs bound them.
        revealHints: batch.revealHints,
      ),
    );
  } on _Invalid catch (e) {
    return Err(e.failure);
  }
}

T _unwrap<T>(Result<T, ValidationFailure> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final failure) => throw _Invalid(failure),
};

/// Short-circuits the collection literals above on the first failure.
final class _Invalid implements Exception {
  const _Invalid(this.failure);

  final ValidationFailure failure;
}
