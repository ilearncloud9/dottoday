import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/sync/requeue.dart';
import 'package:dottoday/data/sync/shared_hlc.dart';
import 'package:drift/drift.dart';

const _syncedWith = 'sync_account';

/// Makes this device's profile the signed-in account's (docs/09 M6.2):
/// the server keys every row by the account id, the device by the id it
/// made on first launch. The profile is re-keyed and every row follows
/// (`ON UPDATE CASCADE`); outbox rows of the profile are re-pointed and
/// the pull starts from the beginning for the new account.
///
/// If this device synced with another account before (signed into a new
/// one, or the last one was deleted), that account's server has none of
/// this device's rows: everything is queued again ([requeueAll]) and the
/// server versions seen there are forgotten (M6.5).
///
/// Returns the old id, or null when nothing changed.
Future<String?> adoptAccount(AppDatabase db, String accountId, SharedHlc hlc) =>
    db.transaction(() async {
      final before = await (db.select(
        db.localMeta,
      )..where((m) => m.key.equals(_syncedWith))).getSingleOrNull();
      await db
          .into(db.localMeta)
          .insertOnConflictUpdate(
            LocalMetaCompanion.insert(key: _syncedWith, value: accountId),
          );
      final switched = before != null && before.value != accountId;
      if (switched) await db.delete(db.fieldSeen).go();
      final profile = await db.select(db.profiles).getSingleOrNull();
      if (profile == null || profile.id == accountId) return null;
      final old = profile.id;
      await db.customUpdate(
        'UPDATE profiles SET id = ? WHERE id = ?',
        variables: [Variable<String>(accountId), Variable<String>(old)],
        updates: db.allTables.toSet(),
      );
      await db.customUpdate(
        "UPDATE change_log SET entity_id = ? WHERE entity = 'profiles' "
        'AND entity_id = ?',
        variables: [Variable<String>(accountId), Variable<String>(old)],
        updates: {db.changeLog},
      );
      await db.delete(db.syncCursors).go();
      if (switched) await requeueAll(db, hlc);
      return old;
    });
