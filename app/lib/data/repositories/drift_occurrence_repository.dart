import 'package:dottoday/data/daos/occurrences_dao.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/row_codec.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/repositories/occurrence_repository.dart';

const _codec = RowCodec(jsonColumns: {'alerts'});

Occurrence _toEntity(OccurrenceRow row) =>
    Occurrence.fromJson(_codec.decode(row));

/// [OccurrenceRepository] over the local Drift database.
final class DriftOccurrenceRepository implements OccurrenceRepository {
  DriftOccurrenceRepository(AppDatabase db) : _dao = OccurrencesDao(db);

  final OccurrencesDao _dao;

  @override
  Stream<List<Occurrence>> watchRange(
    String userId,
    DateTime fromUtc,
    DateTime toUtc,
  ) => _dao
      .watchRange(
        userId,
        fromUtc.millisecondsSinceEpoch,
        toUtc.millisecondsSinceEpoch,
      )
      .map((rows) => rows.map(_toEntity).toList());

  @override
  Stream<List<Occurrence>> watchInbox(String userId) =>
      _dao.watchInbox(userId).map((rows) => rows.map(_toEntity).toList());

  @override
  Future<Occurrence?> findById(String userId, String id) async {
    final row = await _dao.findById(userId, id);
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<List<Occurrence>> findBySeries(String userId, String seriesId) async =>
      (await _dao.findBySeries(userId, seriesId)).map(_toEntity).toList();

  @override
  Future<void> upsertAll(Iterable<Occurrence> occurrences) => _dao.upsertAll(
    occurrences.map((o) => _codec.encode<OccurrenceRow>(o.toJson())),
  );
}
