/// Device-only values that belong to one owner (CR-160 I4): recent
/// searches, brain dumps, the thinking log. Kept in `local_meta` under
/// `<kind>:<ownerId>`, the form account removal deletes
/// (`finishAccountRemoval`), so the next owner never reads them.
library;

import 'package:dottoday/data/daos/profiles_dao.dart';
import 'package:dottoday/data/db/app_database.dart';

/// The `local_meta` key of [ownerId]'s [kind].
///
/// ```dart
/// ownedKey('recent_searches', 'p1'); // 'recent_searches:p1'
/// ```
String ownedKey(String kind, String ownerId) => '$kind:$ownerId';

/// The profile the app shows now (null before one exists), as
/// `localProfileProvider` resolves it.
Future<String?> shownOwnerId(AppDatabase db) async =>
    (await ProfilesDao(db).findActive())?.id;

/// Set once a bare [kind] value was found that nobody can be shown.
String unattributedKey(String kind) => 'owned_meta_unattributed:$kind';

/// [ownerId]'s [kind], adopting the value an earlier version kept under the
/// bare [kind] key when that is provably theirs.
///
/// Before CR-160 these values were global. The device's only profile wrote
/// them when the device has exactly one profile and it is [ownerId]: then
/// the value moves to [ownerId], once, so nobody loses a draft. With more
/// than one profile nobody can tell whose text it is: showing it to the
/// wrong owner is the leak I4 closes, and deleting it could destroy a
/// person's work (a brain-dump draft). So it stays where it is, untouched
/// and shown to nobody, and is marked unattributed so a later moment with
/// one profile left (another removed) never hands it to someone who may
/// not have written it.
Future<String?> readOwned(AppDatabase db, String kind, String ownerId) async {
  final own = await _get(db, ownedKey(kind, ownerId));
  if (own != null) return own;
  return db.transaction(() async {
    final legacy = await _get(db, kind);
    if (legacy == null) return null;
    if (await _get(db, unattributedKey(kind)) != null) return null;
    final profiles = await db.select(db.profiles).get();
    if (profiles.length != 1 || profiles.single.id != ownerId) {
      await _put(db, unattributedKey(kind), '1');
      return null;
    }
    await writeOwned(db, kind, ownerId, legacy);
    await _forget(db, kind);
    return legacy;
  });
}

/// Stores [value] as [ownerId]'s [kind].
Future<void> writeOwned(
  AppDatabase db,
  String kind,
  String ownerId,
  String value,
) => db
    .into(db.localMeta)
    .insertOnConflictUpdate(
      LocalMetaCompanion.insert(key: ownedKey(kind, ownerId), value: value),
    );

/// Forgets [ownerId]'s [kinds]; every other owner's stay.
Future<void> forgetOwned(AppDatabase db, List<String> kinds, String ownerId) =>
    (db.delete(db.localMeta)..where(
          (m) => m.key.isIn([for (final k in kinds) ownedKey(k, ownerId)]),
        ))
        .go();

Future<String?> _get(AppDatabase db, String key) async => (await (db.select(
  db.localMeta,
)..where((m) => m.key.equals(key))).getSingleOrNull())?.value;

Future<void> _put(AppDatabase db, String key, String value) => db
    .into(db.localMeta)
    .insertOnConflictUpdate(LocalMetaCompanion.insert(key: key, value: value));

Future<void> _forget(AppDatabase db, String key) =>
    (db.delete(db.localMeta)..where((m) => m.key.equals(key))).go();
