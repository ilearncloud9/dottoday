import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/owner_meta.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Guest sessions (CR-160, owner 2026-11-08): only guest work first written
/// in the current uninterrupted guest session may be brought into an
/// account. A session is a random id, never a time, so clock changes,
/// restarts, offline use and retries can't make old work eligible.

/// The current guest session if [owner] is a guest (no account marker),
/// created on first use; null for an account.
Future<String?> guestSessionFor(AppDatabase db, String owner) async {
  final marker = await (db.select(
    db.localMeta,
  )..where((m) => m.key.equals(accountMarkerKey(owner)))).getSingleOrNull();
  if (marker != null) return null;
  return currentGuestSession(db);
}

/// The current guest session id, created if there is none yet.
Future<String> currentGuestSession(AppDatabase db) async {
  final row = await (db.select(
    db.localMeta,
  )..where((m) => m.key.equals(guestSessionKey))).getSingleOrNull();
  if (row != null) return row.value;
  final id = const Uuid().v4();
  await db
      .into(db.localMeta)
      .insert(
        LocalMetaCompanion.insert(key: guestSessionKey, value: id),
        mode: InsertMode.insertOrIgnore,
      );
  return (await (db.select(
    db.localMeta,
  )..where((m) => m.key.equals(guestSessionKey))).getSingle()).value;
}

/// Ends the current guest session: called at every change of owner. Work
/// written before stays where it is and can no longer be brought in.
Future<void> rotateGuestSession(AppDatabase db) => db
    .into(db.localMeta)
    .insertOnConflictUpdate(
      LocalMetaCompanion.insert(key: guestSessionKey, value: const Uuid().v4()),
    );

/// Ids of [entity] rows first written in the current guest session.
Future<Set<String>> currentSessionIds(AppDatabase db, String entity) async {
  final session = await currentGuestSession(db);
  final rows = await (db.select(
    db.guestRowSessions,
  )..where((r) => r.entity.equals(entity) & r.session.equals(session))).get();
  return {for (final r in rows) r.entityId};
}
