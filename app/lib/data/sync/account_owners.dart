import 'dart:convert';

import 'package:dottoday/data/daos/profiles_dao.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/owner_meta.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/data/sync/guest_sessions.dart';
import 'package:dottoday/data/sync/pull_guard.dart';
import 'package:dottoday/data/sync/requeue.dart';
import 'package:dottoday/data/sync/shared_hlc.dart';
import 'package:dottoday/data/writes/entity_writers.dart';
import 'package:dottoday/data/writes/row_writer.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/onboarding/starter_habits.dart';
import 'package:dottoday/domain/sync/stable_ids.dart';
import 'package:drift/drift.dart';
import 'package:timezone/timezone.dart' as tz;

/// What signing in did to this device's owners (CR-160).
enum OwnerChange {
  /// The account was already the one shown.
  unchanged,

  /// The account's rows were already here (it signed in before): shown
  /// again, with whatever it queued while signed out.
  returned,

  /// The account's first time on this device: a profile of its own.
  newAccount,

  /// The guest has tasks that could be brought in and nobody chose yet
  /// (owner, 2026-11-08: never attached to whoever signs in without an
  /// informed choice). Nothing changed; record a [GuestChoice] first.
  guestChoiceNeeded,
}

/// What happens to the guest's eligible tasks when an account signs in.
enum GuestChoice {
  /// The default: they stay on this device, separate.
  keepSeparate,

  /// They move into the account, once. Only after the person confirmed
  /// "I made these tasks myself"; a choice, not proof of ownership.
  bringIn,
}

/// What a sign-in did: the change, how many guest tasks moved in and how
/// many stayed with the guest.
typedef SignInResult = ({OwnerChange change, int broughtIn, int keptSeparate});

/// The guest's tasks: [eligible] may be brought in (first written in the
/// current guest session), [ineligible] may not (CR-160 policy §3).
typedef GuestWork = ({int eligible, int ineligible});

/// Records the person's [choice] for the guest's tasks before [accountId]
/// signs in. Eligibility is checked again when the choice is carried out,
/// so a stale or repeated choice can never move ineligible work.
Future<void> recordGuestChoice(
  AppDatabase db,
  String accountId,
  GuestChoice choice,
) => _put(db, guestChoiceKey(accountId), choice.name);

/// The shown guest's tasks, for G1 / G1b; none when no guest is shown.
Future<GuestWork> guestWork(AppDatabase db) async {
  final guest = await _shownGuest(db);
  if (guest == null) return (eligible: 0, ineligible: 0);
  final all = await ownerTaskCount(db, guest);
  final movable = await _movable(db, guest);
  return (eligible: movable.tasks, ineligible: all - movable.tasks);
}

/// Makes [accountId] the owner the app shows (CR-160, docs/04 §4 "Owners",
/// `docs/cr-160-ownership-policy.md`). Rows never change owner, except the
/// guest's eligible tasks after [GuestChoice.bringIn], and those only into
/// the account signing in. Another account's rows are never moved, queued
/// or shown for this one. [freshProfile] makes the account's first profile
/// on this device (device defaults). Guest settings from the current
/// session go into a brand-new profile and are kept for an explicit choice
/// (B1); an account that already has settings keeps them. One transaction:
/// an interruption leaves everything as it was, and a retry is the same
/// sign-in again.
///
/// ```dart
/// final r = await signInOwner(db, uid, hlc, freshProfile: defaults);
/// ```
Future<SignInResult> signInOwner(
  AppDatabase db,
  String accountId,
  SharedHlc hlc, {
  required Profile Function(String accountId) freshProfile,
}) => db.transaction(() async {
  final active = await activeOwnerId(db);
  if (active == accountId) {
    await _put(db, accountMarkerKey(accountId), '1');
    return (change: OwnerChange.unchanged, broughtIn: 0, keptSeparate: 0);
  }
  final guest = await _shownGuest(db);
  final movable = guest == null ? _Movable.none : await _movable(db, guest);
  final all = guest == null ? 0 : await ownerTaskCount(db, guest);
  final choice = await _guestChoice(db, accountId);
  if (movable.tasks > 0 && choice == null) {
    return (
      change: OwnerChange.guestChoiceNeeded,
      broughtIn: 0,
      keptSeparate: 0,
    );
  }
  final bring = choice == GuestChoice.bringIn && movable.tasks > 0;
  final guestSettings = guest != null && movable.profile && (bring || all == 0)
      ? await _profile(db, guest)
      : null;
  final returned = await _hasProfile(db, accountId);
  if (!returned) {
    await _writeFreshProfile(db, accountId, hlc, freshProfile, guestSettings);
  }
  if (guestSettings != null) {
    await _put(db, guestSettingsKey(accountId), jsonEncode(guestSettings));
  }
  if (bring) await _moveGuestWork(db, guest!, accountId, movable, hlc);
  final kept = all - (bring ? movable.tasks : 0);
  if (kept > 0 && movable.tasks == 0) {
    await _put(db, guestNoticeKey(accountId), 'ineligible');
  }
  await _put(db, accountMarkerKey(accountId), '1');
  await _put(db, activeOwnerKey, accountId);
  // Another owner is shown: a pull begun before is from an ended session.
  await bumpOwnerGeneration(db);
  await _forget(db, guestChoiceKey(accountId));
  await rotateGuestSession(db);
  return (
    change: returned ? OwnerChange.returned : OwnerChange.newAccount,
    broughtIn: bring ? movable.tasks : 0,
    keptSeparate: kept,
  );
});

/// Signing out (criterion 2; owner 2026-11-08): the account stops showing
/// at once; its rows and pending changes stay its own, and go up only when
/// the same account signs in again. Only a guest may show afterwards. The
/// guest session ends: work made before can't be brought into anyone.
Future<void> signOutOwner(AppDatabase db) => db.transaction(() async {
  await _put(db, activeOwnerKey, '');
  await bumpOwnerGeneration(db);
  await rotateGuestSession(db);
});

/// First step after the server confirmed [accountId] was deleted (policy
/// §4): its copy here is hidden and marked removal pending, durably, so an
/// interruption never leaves it shown, synced, adopted or turned into
/// guest data. [finishAccountRemoval] removes it.
Future<void> beginAccountRemoval(AppDatabase db, String accountId) =>
    db.transaction(() async {
      await _put(db, accountMarkerKey(accountId), '1');
      await _put(db, removalPendingKey(accountId), '1');
      if (await activeOwnerId(db) == accountId) await signOutOwner(db);
    });

/// Removes the deleted account [accountId]'s copy from this device: every
/// row, pending change, setting and owner-keyed local value it owns, then
/// its profile; [alsoRemove] first removes what lives outside this
/// database (backups). Idempotent: run again after any interruption until
/// the pending mark is gone. Never touches any other owner.
Future<void> finishAccountRemoval(
  AppDatabase db,
  String accountId, {
  Future<void> Function()? alsoRemove,
}) async {
  if (!await isRemovalPending(db, accountId)) return;
  await alsoRemove?.call();
  await db.transaction(() async {
    await _forgetSeen(db, accountId);
    await (db.delete(
      db.changeLog,
    )..where((c) => c.ownerId.equals(accountId))).go();
    await (db.delete(
      db.syncCursors,
    )..where((c) => c.ownerId.equals(accountId))).go();
    for (final table in _ownedTables) {
      await db.customStatement('DELETE FROM $table WHERE user_id = ?', [
        accountId,
      ]);
    }
    await (db.delete(db.profiles)..where((p) => p.id.equals(accountId))).go();
    // Owner-keyed values (`<kind>:<owner>`), the pending mark last of all.
    await db.customStatement(
      "DELETE FROM local_meta WHERE key LIKE '%:' || ? AND key <> ?",
      [accountId, removalPendingKey(accountId)],
    );
    await _forget(db, removalPendingKey(accountId));
  });
}

/// Accounts whose removal began and hasn't finished.
Future<List<String>> pendingRemovals(AppDatabase db) async {
  final prefix = removalPendingKey('');
  final rows = await (db.select(
    db.localMeta,
  )..where((m) => m.key.like('$prefix%'))).get();
  return [for (final r in rows) r.key.substring(prefix.length)];
}

/// Whether [accountId]'s removal is pending.
Future<bool> isRemovalPending(AppDatabase db, String accountId) async =>
    await _get(db, removalPendingKey(accountId)) != null;

/// The profile the app shows: the one recorded, else (before anything was
/// recorded) the oldest; after a sign-out only a guest.
Future<String?> activeOwnerId(AppDatabase db) async =>
    (await ProfilesDao(db).findActive())?.id;

/// Whether [profileId] is an account (else a guest).
Future<bool> isAccount(AppDatabase db, String profileId) async =>
    await _get(db, accountMarkerKey(profileId)) != null;

/// Tables whose rows carry `user_id`, children before parents.
const _ownedTables = [
  'subtasks',
  'occurrences',
  'series',
  'routines',
  'reveal_hints',
  'conflicts',
  'calendar_series',
  'calendar_links',
  'calendar_accounts',
];

/// The guest's rows that may move: first written in the current session.
/// A task moves with its series, and steps move with their task, so no
/// row ever points at another owner's.
final class _Movable {
  _Movable(
    this.series,
    this.occurrences,
    this.subtasks,
    this.routines, {
    required this.profile,
    required this.oneOffs,
  });

  static final none = _Movable({}, {}, {}, {}, profile: false, oneOffs: 0);

  final Set<String> series;
  final Set<String> occurrences;
  final Set<String> subtasks;
  final Set<String> routines;
  final bool profile;
  final int oneOffs;

  /// What the person sees as "tasks": series, one-off tasks and routines.
  int get tasks => series.length + oneOffs + routines.length;
}

Future<_Movable> _movable(AppDatabase db, String guest) async {
  final series = (await _ids(
    db,
    'series',
    guest,
  )).intersection(await currentSessionIds(db, 'series'));
  final current = await currentSessionIds(db, 'occurrences');
  final occurrences = <String>{};
  var oneOffs = 0;
  final rows =
      await (db.select(db.occurrences)..where(
            (o) => o.userId.equals(guest) & o.source.equals('calendar').not(),
          ))
          .get();
  for (final o in rows) {
    if (!current.contains(o.id)) continue;
    final sid = o.seriesId;
    if (sid != null && !series.contains(sid)) continue;
    occurrences.add(o.id);
    if (sid == null) oneOffs++;
  }
  final subtasks = {
    for (final s in await (db.select(
      db.subtasks,
    )..where((s) => s.userId.equals(guest))).get())
      if (occurrences.contains(s.occurrenceId)) s.id,
  };
  final routines = (await _ids(
    db,
    'routines',
    guest,
  )).intersection(await currentSessionIds(db, 'routines'));
  final profile = (await currentSessionIds(db, 'profiles')).contains(guest);
  return _Movable(
    series,
    occurrences,
    subtasks,
    routines,
    profile: profile,
    oneOffs: oneOffs,
  );
}

/// [owner]'s tasks as the person counts them (see [_Movable.tasks]): G1,
/// G1b and the deletion summary (D1) count the same way.
Future<int> ownerTaskCount(AppDatabase db, String owner) async {
  final n = await db
      .customSelect(
        'SELECT (SELECT COUNT(*) FROM series WHERE user_id = ?1) + '
        '(SELECT COUNT(*) FROM occurrences WHERE user_id = ?1 '
        "AND source <> 'calendar' AND series_id IS NULL) + "
        '(SELECT COUNT(*) FROM routines WHERE user_id = ?1) AS n',
        variables: [Variable<String>(owner)],
      )
      .getSingle();
  return n.read<int>('n');
}

Future<Set<String>> _ids(AppDatabase db, String table, String owner) async => {
  for (final r
      in await db
          .customSelect(
            'SELECT id FROM $table WHERE user_id = ?',
            variables: [Variable<String>(owner)],
          )
          .get())
    r.read<String>('id'),
};

/// Moves [m] from [guest] to [account] and queues exactly those rows for
/// the account; nothing else of either owner changes.
Future<void> _moveGuestWork(
  AppDatabase db,
  String guest,
  String account,
  _Movable m,
  SharedHlc hlc,
) async {
  // Starter ids follow their owner; steps follow at commit.
  await db.customStatement('PRAGMA defer_foreign_keys = ON');
  final moved = <String, Set<String>>{
    'series': m.series,
    'occurrences': m.occurrences,
    'subtasks': m.subtasks,
    'routines': m.routines,
  };
  for (final MapEntry(key: table, value: ids) in moved.entries) {
    await _forgetGuestEntries(db, guest, table, ids);
    await _setOwner(db, table, ids, account);
  }
  final tasks = await _rekeyStarters(db, m.occurrences, guest, account);
  await requeueOwner(db, account, hlc, only: {...moved, 'occurrences': tasks});
}

Future<void> _forgetGuestEntries(
  AppDatabase db,
  String guest,
  String entity,
  Set<String> ids,
) async {
  for (final chunk in _chunks(ids)) {
    await (db.delete(db.changeLog)..where(
          (c) =>
              c.ownerId.equals(guest) &
              c.entity.equals(entity) &
              c.entityId.isIn(chunk),
        ))
        .go();
    await (db.delete(
      db.guestRowSessions,
    )..where((r) => r.entity.equals(entity) & r.entityId.isIn(chunk))).go();
  }
}

Future<void> _setOwner(
  AppDatabase db,
  String table,
  Set<String> ids,
  String owner,
) async {
  for (final chunk in _chunks(ids)) {
    final marks = List.filled(chunk.length, '?').join(', ');
    await db.customStatement(
      'UPDATE $table SET user_id = ? WHERE id IN ($marks)',
      [owner, ...chunk],
    );
  }
}

Iterable<List<String>> _chunks(Set<String> ids) sync* {
  final list = ids.toList();
  for (var i = 0; i < list.length; i += 400) {
    yield list.sublist(i, i + 400 > list.length ? list.length : i + 400);
  }
}

/// Moved starter tasks (ids are [starterTaskId]s of the guest) take the
/// account's ids for the same habit and day, so they merge with the
/// account's own instead of duplicating (criterion 8). Returns the moved
/// task ids as they are now.
Future<Set<String>> _rekeyStarters(
  AppDatabase db,
  Set<String> moved,
  String guest,
  String account,
) async {
  final out = <String>{};
  for (final chunk in _chunks(moved)) {
    final rows = await (db.select(
      db.occurrences,
    )..where((o) => o.id.isIn(chunk))).get();
    for (final o in rows) {
      final start = o.startUtc;
      final id = o.seriesId == null && start != null
          ? _starterRekey(o.id, start, o.tzId, guest, account)
          : null;
      if (id == null || await _exists(db, id)) {
        out.add(o.id);
        continue;
      }
      await db.customStatement('UPDATE occurrences SET id = ? WHERE id = ?', [
        id,
        o.id,
      ]);
      await db.customStatement(
        'UPDATE subtasks SET occurrence_id = ? WHERE occurrence_id = ?',
        [id, o.id],
      );
      out.add(id);
    }
  }
  return out;
}

Future<bool> _exists(AppDatabase db, String occurrenceId) async =>
    await (db.select(
      db.occurrences,
    )..where((o) => o.id.equals(occurrenceId))).getSingleOrNull() !=
    null;

/// [id]'s account id if it is the guest's starter for a day around
/// [startMs] (a starter sits on its day's Wake Up to Wind Down, which can
/// cross midnight); null if it is not a starter.
String? _starterRekey(
  String id,
  int startMs,
  String tzId,
  String guest,
  String account,
) {
  final tz.Location zone;
  try {
    zone = tz.getLocation(tzId);
  } on tz.LocationNotFoundException {
    return null;
  }
  final local = tz.TZDateTime.fromMillisecondsSinceEpoch(zone, startMs);
  for (final shift in const [0, -1, 1]) {
    final day = DateTime(local.year, local.month, local.day + shift);
    for (final habit in StarterHabit.values) {
      if (starterTaskId(guest, habit, day) == id) {
        return starterTaskId(account, habit, day);
      }
    }
  }
  return null;
}

/// The account's first profile here: device defaults, or the current
/// guest's time zone, language and preferences when they come along.
/// Written with its creation clock; an account that already has settings
/// on the server keeps them (the engine drops these at its first sync).
Future<void> _writeFreshProfile(
  AppDatabase db,
  String accountId,
  SharedHlc hlc,
  Profile Function(String) freshProfile,
  Map<String, Object?>? guest,
) async {
  var profile = freshProfile(accountId);
  if (guest != null) {
    final g = Profile.fromJson(guest);
    profile = profile.copyWith(
      tzId: g.tzId,
      locale: g.locale,
      settings: g.settings,
    );
  }
  final clock = await hlc.clock();
  await writeRows(
    db,
    profileWriter(DriftSettingsRepository(db)),
    [profile],
    owner: accountId,
    now: profile.createdAt,
    nextHlc: clock.now,
  );
  await hlc.save();
}

Future<Map<String, Object?>?> _profile(AppDatabase db, String id) async {
  final row = await (db.select(
    db.profiles,
  )..where((p) => p.id.equals(id))).getSingleOrNull();
  return row == null ? null : profileFromRow(row).toJson();
}

/// The shown profile if it is a guest.
Future<String?> _shownGuest(AppDatabase db) async {
  final active = await activeOwnerId(db);
  if (active == null || await isAccount(db, active)) return null;
  return active;
}

Future<GuestChoice?> _guestChoice(AppDatabase db, String accountId) async =>
    GuestChoice.values.asNameMap()[await _get(db, guestChoiceKey(accountId))];

/// Forgets the server versions seen for [owner]'s rows.
Future<void> _forgetSeen(AppDatabase db, String owner) async {
  const tables = {
    'series': 'series',
    'occurrences': 'occurrences',
    'subtasks': 'subtasks',
    'routines': 'routines',
    'reveal_hints': 'reveal_hints',
  };
  for (final MapEntry(key: entity, value: table) in tables.entries) {
    await db.customStatement(
      'DELETE FROM field_seen WHERE entity = ? AND entity_id IN '
      '(SELECT id FROM $table WHERE user_id = ?)',
      [entity, owner],
    );
  }
  await db.customStatement(
    "DELETE FROM field_seen WHERE entity = 'profiles' AND entity_id = ?",
    [owner],
  );
}

Future<bool> _hasProfile(AppDatabase db, String id) async =>
    await (db.select(
      db.profiles,
    )..where((p) => p.id.equals(id))).getSingleOrNull() !=
    null;

Future<String?> _get(AppDatabase db, String key) async => (await (db.select(
  db.localMeta,
)..where((m) => m.key.equals(key))).getSingleOrNull())?.value;

Future<void> _put(AppDatabase db, String key, String value) => db
    .into(db.localMeta)
    .insertOnConflictUpdate(LocalMetaCompanion.insert(key: key, value: value));

Future<void> _forget(AppDatabase db, String key) =>
    (db.delete(db.localMeta)..where((m) => m.key.equals(key))).go();
