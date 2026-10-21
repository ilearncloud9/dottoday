import 'package:dottoday/domain/entities/occurrence.dart';

/// Read/write access to occurrences (docs/05). Every call is scoped to one
/// owner so a deep-linked id can never resolve another user's row (06 §9).
///
/// Writes are raw persistence: call them only from the write path (M2.3),
/// which wraps them in one transaction with `change_log` and side effects.
abstract interface class OccurrenceRepository {
  /// Live (not deleted) blocks overlapping `[fromUtc, toUtc)`, ordered by
  /// start then id. Overlap, not containment, so a block crossing midnight
  /// shows on both days. Use for day, week and month views.
  ///
  /// ```dart
  /// repo.watchRange(userId, dayStartUtc, nextDayStartUtc)
  /// ```
  Stream<List<Occurrence>> watchRange(
    String userId,
    DateTime fromUtc,
    DateTime toUtc,
  );

  /// Live inbox items (no start), ordered by `sortOrder` then id.
  Stream<List<Occurrence>> watchInbox(String userId);

  /// The row with [id] owned by [userId], including deleted ones (Trash),
  /// or null.
  Future<Occurrence?> findById(String userId, String id);

  /// Every row of [seriesId] (including edited, skipped and deleted ones),
  /// which the `Materialiser` treats as exceptions (M1.3).
  Future<List<Occurrence>> findBySeries(String userId, String seriesId);

  /// Inserts or replaces each occurrence by id.
  Future<void> upsertAll(Iterable<Occurrence> occurrences);
}
