import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/owner_meta.dart';
import 'package:dottoday/data/db/tables/profiles.dart';
import 'package:dottoday/data/db/tables/sync_tables.dart';
import 'package:drift/drift.dart';

part 'profiles_dao.g.dart';

/// Single-table queries over `profiles`; rows only, no mapping.
@DriftAccessor(tables: [Profiles, LocalMeta])
class ProfilesDao extends DatabaseAccessor<AppDatabase>
    with _$ProfilesDaoMixin {
  ProfilesDao(super.attachedDatabase);

  Stream<ProfileRow?> watchById(String id) =>
      (select(profiles)..where((p) => p.id.equals(id))).watchSingleOrNull();

  /// The profile the app shows (CR-160): the active owner recorded in
  /// `local_meta`. Before anything was recorded (a first launch) the oldest
  /// profile. After a sign-out (recorded as empty) only a guest, the oldest
  /// profile that is not an account, else none: an account's rows are never
  /// shown to whoever uses the device next.
  Future<ProfileRow?> findActive() async {
    final active = await (select(
      localMeta,
    )..where((m) => m.key.equals(activeOwnerKey))).getSingleOrNull();
    if (active != null && active.value.isNotEmpty) {
      final row = await (select(
        profiles,
      )..where((p) => p.id.equals(active.value))).getSingleOrNull();
      if (row != null) return row;
    }
    final all = await (select(
      profiles,
    )..orderBy([(p) => OrderingTerm(expression: p.createdAt)])).get();
    if (active == null) return all.firstOrNull;
    final accounts = {
      for (final m in await (select(
        localMeta,
      )..where((m) => m.key.like('${accountMarkerKey('')}%'))).get())
        m.key.substring(accountMarkerKey('').length),
    };
    return all.where((p) => !accounts.contains(p.id)).firstOrNull;
  }

  Future<void> upsert(Insertable<ProfileRow> row) =>
      into(profiles).insertOnConflictUpdate(row);
}
