import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/tables/reveal_hints_table.dart';
import 'package:drift/drift.dart';

part 'reveal_hints_dao.g.dart';

/// Single-table queries over `reveal_hints`; rows only, no mapping.
@DriftAccessor(tables: [RevealHintsTable])
class RevealHintsDao extends DatabaseAccessor<AppDatabase>
    with _$RevealHintsDaoMixin {
  RevealHintsDao(super.attachedDatabase);

  Stream<List<RevealHintRow>> watchAll(String userId) =>
      (select(revealHintsTable)..where((h) => h.userId.equals(userId))).watch();

  Future<RevealHintRow?> findById(String userId, String id) => (select(
    revealHintsTable,
  )..where((h) => h.userId.equals(userId) & h.id.equals(id))).getSingleOrNull();

  Future<void> upsertAll(Iterable<Insertable<RevealHintRow>> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(revealHintsTable, rows));
}
