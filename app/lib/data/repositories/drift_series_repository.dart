import 'package:dottoday/data/daos/series_dao.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/repositories/series_repository.dart';

/// [SeriesRepository] over the local Drift database.
final class DriftSeriesRepository implements SeriesRepository {
  DriftSeriesRepository(AppDatabase db) : _dao = SeriesDao(db);

  final SeriesDao _dao;

  @override
  Stream<List<Series>> watchActive(String userId) =>
      _dao.watchActive(userId).map((rows) => rows.map(seriesFromRow).toList());

  @override
  Future<Series?> findById(String userId, String id) async {
    final row = await _dao.findById(userId, id);
    return row == null ? null : seriesFromRow(row);
  }

  @override
  Future<List<Series>> findNeedingMaterialisation(
    String userId,
    DateTime horizonUtc,
  ) async => (await _dao.findMaterialisedBefore(
    userId,
    horizonUtc.millisecondsSinceEpoch,
  )).map(seriesFromRow).toList();

  @override
  Future<void> upsertAll(Iterable<Series> series) => _dao.upsertAll(
    series.map((s) => seriesCodec.encode<SeriesRow>(s.toJson())),
  );
}
