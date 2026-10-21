import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/tables/occurrences.dart';
import 'package:drift/drift.dart';

part 'subtasks_dao.g.dart';

/// Single-table queries over `subtasks`; rows only, no mapping.
@DriftAccessor(tables: [Subtasks])
class SubtasksDao extends DatabaseAccessor<AppDatabase>
    with _$SubtasksDaoMixin {
  SubtasksDao(super.attachedDatabase);

  Stream<List<SubtaskRow>> watchForOccurrences(
    String userId,
    Set<String> occurrenceIds,
  ) =>
      (select(subtasks)
            ..where(
              (s) =>
                  s.userId.equals(userId) &
                  s.occurrenceId.isIn(occurrenceIds) &
                  s.deletedAt.isNull(),
            )
            ..orderBy([
              (s) => OrderingTerm(expression: s.occurrenceId),
              (s) => OrderingTerm(expression: s.sortOrder),
              (s) => OrderingTerm(expression: s.id),
            ]))
          .watch();

  Future<SubtaskRow?> findById(String userId, String id) => (select(
    subtasks,
  )..where((s) => s.userId.equals(userId) & s.id.equals(id))).getSingleOrNull();

  Future<void> upsertAll(Iterable<Insertable<SubtaskRow>> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(subtasks, rows));
}
