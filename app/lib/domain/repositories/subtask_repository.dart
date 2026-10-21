import 'package:dottoday/domain/entities/subtask.dart';

/// Read/write access to per-occurrence subtasks (docs/05 `subtasks`, R-09),
/// owner-scoped. Writes are for the write path only (M2.3).
abstract interface class SubtaskRepository {
  /// Live subtasks of [occurrenceIds], ordered by occurrence, `sortOrder`,
  /// then id. One query for a whole day's progress rings.
  Stream<List<Subtask>> watchForOccurrences(
    String userId,
    Set<String> occurrenceIds,
  );

  /// The subtask [id] owned by [userId] (deleted included), or null.
  Future<Subtask?> findById(String userId, String id);

  /// Inserts or replaces each subtask by id.
  Future<void> upsertAll(Iterable<Subtask> subtasks);
}
