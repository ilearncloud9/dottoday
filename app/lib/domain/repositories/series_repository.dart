import 'package:dottoday/domain/entities/series.dart';

/// Read/write access to recurring series (docs/05 `series`), owner-scoped.
/// Writes are for the write path only (M2.3).
abstract interface class SeriesRepository {
  /// Series that are neither deleted nor archived, ordered by id.
  Stream<List<Series>> watchActive(String userId);

  /// The series [id] owned by [userId] (deleted included), or null.
  Future<Series?> findById(String userId, String id);

  /// Active series whose materialisation stops before [horizonUtc] (or was
  /// never run), for the daily re-materialise (M5.2).
  Future<List<Series>> findNeedingMaterialisation(
    String userId,
    DateTime horizonUtc,
  );

  /// Inserts or replaces each series by id.
  Future<void> upsertAll(Iterable<Series> series);
}
