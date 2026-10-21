import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/tables/profiles.dart';
import 'package:drift/drift.dart';

part 'profiles_dao.g.dart';

/// Single-table queries over `profiles`; rows only, no mapping.
@DriftAccessor(tables: [Profiles])
class ProfilesDao extends DatabaseAccessor<AppDatabase>
    with _$ProfilesDaoMixin {
  ProfilesDao(super.attachedDatabase);

  Stream<ProfileRow?> watchById(String id) =>
      (select(profiles)..where((p) => p.id.equals(id))).watchSingleOrNull();

  /// The oldest profile row: the local owner (one per device database).
  Future<ProfileRow?> findFirst() =>
      (select(profiles)
            ..orderBy([(p) => OrderingTerm(expression: p.createdAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<void> upsert(Insertable<ProfileRow> row) =>
      into(profiles).insertOnConflictUpdate(row);
}
