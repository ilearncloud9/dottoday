import 'package:dottoday/data/daos/routines_dao.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/repositories/routine_repository.dart';

/// [RoutineRepository] over the local Drift database.
final class DriftRoutineRepository implements RoutineRepository {
  DriftRoutineRepository(AppDatabase db) : _dao = RoutinesDao(db);

  final RoutinesDao _dao;

  @override
  Stream<List<Routine>> watchActive(String userId) =>
      _dao.watchActive(userId).map((rows) => rows.map(routineFromRow).toList());

  @override
  Future<Routine?> findById(String userId, String id) async {
    final row = await _dao.findById(userId, id);
    return row == null ? null : routineFromRow(row);
  }

  @override
  Future<void> upsertAll(Iterable<Routine> routines) => _dao.upsertAll(
    routines.map((r) => routineCodec.encode<RoutineRow>(r.toJson())),
  );
}
