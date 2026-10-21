import 'package:dottoday/data/daos/series_dao.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/row_codec.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/repositories/series_repository.dart';

const _codec = RowCodec(jsonColumns: {'alerts', 'subtask_template'});

Series _toEntity(SeriesRow row) => Series.fromJson(_codec.decode(row));

/// [SeriesRepository] over the local Drift database.
final class DriftSeriesRepository implements SeriesRepository {
  DriftSeriesRepository(AppDatabase db) : _dao = SeriesDao(db);

  final SeriesDao _dao;

  @override
  Stream<List<Series>> watchActive(String userId) =>
      _dao.watchActive(userId).map((rows) => rows.map(_toEntity).toList());

  @override
  Future<Series?> findById(String userId, String id) async {
    final row = await _dao.findById(userId, id);
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<List<Series>> findNeedingMaterialisation(
    String userId,
    DateTime horizonUtc,
  ) async => (await _dao.findMaterialisedBefore(
    userId,
    horizonUtc.millisecondsSinceEpoch,
  )).map(_toEntity).toList();

  @override
  Future<void> upsertAll(Iterable<Series> series) =>
      _dao.upsertAll(series.map((s) => _codec.encode<SeriesRow>(s.toJson())));
}
