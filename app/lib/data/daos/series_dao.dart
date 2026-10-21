import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/tables/series_table.dart';
import 'package:drift/drift.dart';

part 'series_dao.g.dart';

/// Single-table queries over `series`; rows only, no mapping.
@DriftAccessor(tables: [SeriesTable])
class SeriesDao extends DatabaseAccessor<AppDatabase> with _$SeriesDaoMixin {
  SeriesDao(super.attachedDatabase);

  Expression<bool> _active($SeriesTableTable s, String userId) =>
      s.userId.equals(userId) & s.deletedAt.isNull() & s.archivedAt.isNull();

  Stream<List<SeriesRow>> watchActive(String userId) =>
      (select(seriesTable)
            ..where((s) => _active(s, userId))
            ..orderBy([(s) => OrderingTerm(expression: s.id)]))
          .watch();

  Future<SeriesRow?> findById(String userId, String id) => (select(
    seriesTable,
  )..where((s) => s.userId.equals(userId) & s.id.equals(id))).getSingleOrNull();

  Future<List<SeriesRow>> findMaterialisedBefore(
    String userId,
    int horizonMs,
  ) =>
      (select(seriesTable)
            ..where(
              (s) =>
                  _active(s, userId) &
                  (s.materialisedThroughUtc.isNull() |
                      s.materialisedThroughUtc.isSmallerThanValue(horizonMs)),
            )
            ..orderBy([(s) => OrderingTerm(expression: s.id)]))
          .get();

  Future<void> upsertAll(Iterable<Insertable<SeriesRow>> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(seriesTable, rows));
}
