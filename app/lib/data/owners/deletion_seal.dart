/// The account-deletion seal and each owner's write revision (CR-160
/// policy §4, reminder-action race): what lets D1 tell "changed since the
/// review" from "unchanged", and refuse saves while the deletion runs.
///
/// Both live in `local_meta` under `<kind>:<ownerId>` (so account removal
/// deletes them with the rest) and are read and written only inside SQLite
/// transactions. That is the whole race argument: every save that counts
/// runs [checkNotSealed] and [bumpWriteRevision] in its own transaction, and
/// [sealForDeletion] writes the seal and reads the revision in one
/// transaction. SQLite runs transactions serializably, across connections
/// too (the background refresh isolate opens its own), so a save is either
/// ordered before the seal — its revision is what the seal reads, and D1
/// stops — or after it, and refused before anything commits. A save that
/// rolls back takes its revision bump with it.
library;

import 'package:dottoday/data/db/app_database.dart';
import 'package:drift/drift.dart';

const _sealKind = 'deletion_seal';
const _revisionKind = 'write_revision';

String _sealKey(String owner) => '$_sealKind:$owner';
String _revisionKey(String owner) => '$_revisionKind:$owner';

/// A save for an owner whose deletion is running: refused, nothing written.
final class OwnerSealedException implements Exception {
  const OwnerSealedException();
}

/// Inside the caller's transaction: throws [OwnerSealedException] while
/// [owner]'s deletion is sealed.
Future<void> checkNotSealed(AppDatabase db, String owner) async {
  if (await _get(db, _sealKey(owner)) != null) {
    throw const OwnerSealedException();
  }
}

/// Inside the caller's transaction: [owner]'s data changed. Call it only
/// when rows were actually written, so a save that changed nothing never
/// invalidates a review.
Future<void> bumpWriteRevision(AppDatabase db, String owner) async {
  final next = await writeRevision(db, owner) + 1;
  await _put(db, _revisionKey(owner), '$next');
}

/// [owner]'s write revision now (0 before any counted save).
Future<int> writeRevision(AppDatabase db, String owner) async =>
    int.tryParse(await _get(db, _revisionKey(owner)) ?? '') ?? 0;

/// Seals [owner] for deletion and returns its write revision, both in one
/// transaction (see the library doc). From here, saves for [owner] are
/// refused until [unsealDeletion].
Future<int> sealForDeletion(AppDatabase db, String owner) =>
    db.transaction(() async {
      // The write first: the transaction holds the write lock before it
      // reads, so no save can commit between the read and the seal.
      await _put(db, _sealKey(owner), '1');
      return writeRevision(db, owner);
    });

/// Ends [sealForDeletion]: saves for [owner] go through again. A no-op
/// once account removal deleted the seal with the rest.
Future<void> unsealDeletion(AppDatabase db, String owner) =>
    (db.delete(db.localMeta)..where((m) => m.key.equals(_sealKey(owner)))).go();

/// At the app's launch: a seal left by a deletion that a crash or a kill
/// interrupted. Only the app runs deletions, so at its start none is
/// running; never called from the background refresh.
Future<void> clearDeletionSeals(AppDatabase db) =>
    (db.delete(db.localMeta)..where((m) => m.key.like('$_sealKind:%'))).go();

Future<String?> _get(AppDatabase db, String key) async => (await (db.select(
  db.localMeta,
)..where((m) => m.key.equals(key))).getSingleOrNull())?.value;

Future<void> _put(AppDatabase db, String key, String value) => db
    .into(db.localMeta)
    .insertOnConflictUpdate(LocalMetaCompanion.insert(key: key, value: value));
