import 'package:dottoday/data/daos/profiles_dao.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/owner_meta.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/sync/outbox.dart';
import 'package:drift/drift.dart';

// The account screens' small durable facts (CR-160 A3, B1, G1b, D1), in
// `local_meta` beside the owner keys of `owner_meta.dart`. Keys that end in
// `:<accountId>` go with the account when its copy is removed
// (`finishAccountRemoval` deletes every `%:<id>` key).

/// Set right after a sign-out hid the account (policy §2): the app shows
/// "You're signed out" (A3), never a planner, until someone signs in or
/// picks "Use without an account". Durable, so a restart can't skip it.
const signedOutGateKey = 'signed_out_gate';

/// Set when the person chose "Decide later" on B1: the kept guest settings
/// wait for Settings › Account instead of asking again at every launch.
String guestSettingsLaterKey(String accountId) =>
    'guest_settings_later:$accountId';

/// Whether the signed-out screen (A3) is up.
Future<bool> signedOutGateSet(AppDatabase db) async =>
    await _get(db, signedOutGateKey) != null;

/// A3 from now on (after `OwnerSwitch.signOut`).
Future<void> setSignedOutGate(AppDatabase db) => _put(db, signedOutGateKey);

/// A3 no longer: someone signed in, or the guest plan was chosen.
Future<void> clearSignedOutGate(AppDatabase db) =>
    _forget(db, signedOutGateKey);

/// Whether B1 waits for Settings › Account ("Decide later").
Future<bool> guestSettingsDeferred(AppDatabase db, String accountId) async =>
    await _get(db, guestSettingsLaterKey(accountId)) != null;

/// "Decide later" ([later]) or, from Settings › Account, ask now.
Future<void> deferGuestSettings(
  AppDatabase db,
  String accountId, {
  required bool later,
}) => later
    ? _put(db, guestSettingsLaterKey(accountId))
    : _forget(db, guestSettingsLaterKey(accountId));

/// Whether signing in left guest work that may not move (G1b, once).
Future<bool> guestNoticePending(AppDatabase db, String accountId) async =>
    await _get(db, guestNoticeKey(accountId)) != null;

/// G1b was seen: it never shows again for this sign-in.
Future<void> clearGuestNotice(AppDatabase db, String accountId) =>
    _forget(db, guestNoticeKey(accountId));

/// The tasks of the guest an account's sign-in left on this device (G1b):
/// the oldest profile that is not an account, as [ProfilesDao.findActive]
/// picks it after a sign-out; 0 when there is none.
Future<int> leftGuestTaskCount(AppDatabase db) async {
  final accounts = {
    for (final m in await (db.select(
      db.localMeta,
    )..where((m) => m.key.like('${accountMarkerKey('')}%'))).get())
      m.key.substring(accountMarkerKey('').length),
  };
  final profiles = await (db.select(db.profiles)).get()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  final guest = profiles.where((p) => !accounts.contains(p.id)).firstOrNull;
  return guest == null ? 0 : ownerTaskCount(db, guest.id);
}

/// What deleting [owner] removes from this device (D1 summary): its tasks
/// and its changes that haven't synced.
typedef OwnerSummary = ({int tasks, int pending});

/// [owner]'s [OwnerSummary], read now.
Future<OwnerSummary> ownerSummary(AppDatabase db, String owner) async => (
  tasks: await ownerTaskCount(db, owner),
  pending: await Outbox(db).watchCount(owner).first,
);

/// Whether the profile the app shows is [accountId]'s.
Future<bool> isShownAccount(AppDatabase db, String accountId) async =>
    await activeOwnerId(db) == accountId;

Future<String?> _get(AppDatabase db, String key) async => (await (db.select(
  db.localMeta,
)..where((m) => m.key.equals(key))).getSingleOrNull())?.value;

Future<void> _put(AppDatabase db, String key) => db
    .into(db.localMeta)
    .insertOnConflictUpdate(LocalMetaCompanion.insert(key: key, value: '1'));

Future<void> _forget(AppDatabase db, String key) =>
    (db.delete(db.localMeta)..where((m) => m.key.equals(key))).go();
