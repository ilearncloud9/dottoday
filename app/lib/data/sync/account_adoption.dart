import 'package:dottoday/data/db/app_database.dart';
import 'package:drift/drift.dart';

/// Makes this device's profile the signed-in account's (docs/09 M6.2):
/// the server keys every row by the account id, the device by the id it
/// made on first launch. The profile is re-keyed and every row follows
/// (`ON UPDATE CASCADE`); outbox rows of the profile are re-pointed and
/// the pull starts from the beginning for the new account.
///
/// Returns the old id, or null when nothing changed.
Future<String?> adoptAccount(AppDatabase db, String accountId) =>
    db.transaction(() async {
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
      return old;
    });
