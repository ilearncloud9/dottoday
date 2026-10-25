import 'package:dottoday/domain/entities/routine.dart';

/// Read/write access to routines (docs/05 `routines`, 11 C2), owner-scoped.
/// Writes are for the write path only (M2.3).
abstract interface class RoutineRepository {
  /// Live routines in their order (sort order, then id).
  Stream<List<Routine>> watchActive(String userId);

  /// The routine [id] owned by [userId] (deleted included), or null.
  Future<Routine?> findById(String userId, String id);

  /// Inserts or replaces each routine by id.
  Future<void> upsertAll(Iterable<Routine> routines);
}
