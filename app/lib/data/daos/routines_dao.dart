import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/tables/routines_table.dart';
import 'package:drift/drift.dart';

part 'routines_dao.g.dart';

/// Single-table queries over `routines`; rows only, no mapping.
@DriftAccessor(tables: [RoutinesTable])
class RoutinesDao extends DatabaseAccessor<AppDatabase>
    with _$RoutinesDaoMixin {
  RoutinesDao(super.attachedDatabase);

  Stream<List<RoutineRow>> watchActive(String userId) =>
      (select(routinesTable)
            ..where((r) => r.userId.equals(userId) & r.deletedAt.isNull())
            ..orderBy([
              (r) => OrderingTerm(expression: r.sortOrder),
              (r) => OrderingTerm(expression: r.id),
            ]))
          .watch();

  Future<RoutineRow?> findById(String userId, String id) => (select(
    routinesTable,
  )..where((r) => r.userId.equals(userId) & r.id.equals(id))).getSingleOrNull();

  Future<void> upsertAll(Iterable<Insertable<RoutineRow>> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(routinesTable, rows));
}
