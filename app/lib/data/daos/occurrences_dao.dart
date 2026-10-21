import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/tables/occurrences.dart';
import 'package:drift/drift.dart';

part 'occurrences_dao.g.dart';

/// Longest block (docs/05 `duration_min <= 1440`): bounds how early a block
/// can start and still overlap a window, keeping range queries on the
/// `(user_id, start_utc)` index.
const maxDurationMs = 1440 * 60 * 1000;

/// Single-table queries over `occurrences`; rows only, no mapping.
@DriftAccessor(tables: [Occurrences])
class OccurrencesDao extends DatabaseAccessor<AppDatabase>
    with _$OccurrencesDaoMixin {
  OccurrencesDao(super.attachedDatabase);

  /// Live rows overlapping `[fromMs, toMs)`.
  Stream<List<OccurrenceRow>> watchRange(String userId, int fromMs, int toMs) {
    final end =
        occurrences.startUtc + occurrences.durationMin * const Constant(60000);
    final query = select(occurrences)
      ..where(
        (o) =>
            o.userId.equals(userId) &
            o.deletedAt.isNull() &
            o.startUtc.isBiggerThanValue(fromMs - maxDurationMs) &
            o.startUtc.isSmallerThanValue(toMs) &
            end.isBiggerThanValue(fromMs),
      )
      ..orderBy([(o) => OrderingTerm(expression: o.startUtc), _byId]);
    return query.watch();
  }

  /// Live rows without a start, in inbox order.
  Stream<List<OccurrenceRow>> watchInbox(String userId) {
    final query = select(occurrences)
      ..where(
        (o) =>
            o.userId.equals(userId) &
            o.startUtc.isNull() &
            o.deletedAt.isNull(),
      )
      ..orderBy([(o) => OrderingTerm(expression: o.sortOrder), _byId]);
    return query.watch();
  }

  Future<OccurrenceRow?> findById(String userId, String id) => (select(
    occurrences,
  )..where((o) => o.userId.equals(userId) & o.id.equals(id))).getSingleOrNull();

  Future<List<OccurrenceRow>> findBySeries(String userId, String seriesId) =>
      (select(occurrences)
            ..where(
              (o) => o.userId.equals(userId) & o.seriesId.equals(seriesId),
            )
            ..orderBy([(o) => OrderingTerm(expression: o.originalStartUtc)]))
          .get();

  Future<void> upsertAll(Iterable<Insertable<OccurrenceRow>> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(occurrences, rows));

  OrderingTerm _byId($OccurrencesTable o) => OrderingTerm(expression: o.id);
}
