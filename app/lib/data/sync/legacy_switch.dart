/// Data a build before CR-160 attributed to the wrong account (CR-160
/// blocker 8, `docs/cr-160-verification.md`).
///
/// Before schema 18, signing into account B on a device that had synced
/// account A re-keyed A's rows to B there, and schema 18 gives every
/// pending change the device's one profile. A's rows that reached the
/// server are safe (`sync_push` refuses them, "not accessible"); A's
/// unsynced work would be uploaded into B. Nothing on the device records
/// who signed in when, but one trace does: `field_seen` lists every row
/// the device pulled from a server. A pulled row the account's own server
/// doesn't hold proves the switch; then that row, and every change still
/// pending at the upgrade that the account doesn't hold either, is held:
/// moved to a hidden owner that is never shown, synced, or a guest. Kept,
/// never deleted; nothing is relabelled as the account's own.
library;

import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/legacy_outbox.dart';
import 'package:dottoday/data/db/owner_meta.dart';
import 'package:dottoday/data/sync/sync_gateway.dart';
import 'package:drift/drift.dart';

/// Marks a profile as the hidden owner of held rows.
String heldOwnerKey(String profileId) => 'owner_held:$profileId';

/// Owned tables a switch could have re-keyed (profiles are their own).
const _tables = [
  'series',
  'occurrences',
  'subtasks',
  'routines',
  'reveal_hints',
];

/// Before [owner]'s first push after that upgrade (its rows pulled): holds
/// what proves to be another account's. Read-only on the server; throws
/// [SyncGatewayException] like any round, so nothing is pushed before it
/// has answered.
Future<void> checkLegacySwitch(
  AppDatabase db,
  SyncGateway gateway,
  String owner,
) async {
  if (await _get(db, legacyCheckDueKey) == null) return;
  final until = int.tryParse(await _get(db, legacyOutboxUntilKey) ?? '') ?? 0;
  final held = <String, Set<String>>{};
  var proven = false;
  for (final table in _tables) {
    final seen = await _ids(
      db,
      'SELECT r.id FROM $table r WHERE r.user_id = ? AND EXISTS '
      '(SELECT 1 FROM field_seen f WHERE f.entity = ? AND f.entity_id = r.id)',
      [owner, table],
    );
    final pending = await _ids(
      db,
      'SELECT DISTINCT entity_id FROM change_log '
      'WHERE owner_id = ? AND entity = ? AND seq <= ?',
      [owner, table, until],
    );
    final asked = {...seen, ...pending}.toList();
    final mine = asked.isEmpty
        ? <String>{}
        : await gateway.ownIds(table, asked);
    if (seen.difference(mine).isNotEmpty) proven = true;
    held[table] = {...seen, ...pending}.difference(mine);
  }
  if (proven) await holdRows(db, owner, held);
  await _forget(db, legacyCheckDueKey);
}

/// Moves [rows] (ids per table) and their pending changes from [owner] to
/// the hidden owner, with the steps of any held task. One transaction.
Future<void> holdRows(
  AppDatabase db,
  String owner,
  Map<String, Set<String>> rows,
) => db.transaction(() async {
  final tasks = rows['occurrences'] ?? const <String>{};
  final steps = tasks.isEmpty
      ? const <String>{}
      : await _ids(
          db,
          'SELECT id FROM subtasks WHERE user_id = ? AND occurrence_id IN '
          '(${_marks(tasks.length)})',
          [owner, ...tasks],
        );
  final all = {
    ...rows,
    'subtasks': {...?rows['subtasks'], ...steps},
  };
  if (all.values.every((ids) => ids.isEmpty)) return;
  final hidden = await _heldOwner(db, owner);
  for (final MapEntry(key: table, value: ids) in all.entries) {
    final list = ids.toList();
    for (var i = 0; i < list.length; i += 400) {
      final chunk = list.sublist(i, (i + 400).clamp(0, list.length));
      final marks = _marks(chunk.length);
      await db.customUpdate(
        'UPDATE $table SET user_id = ? WHERE user_id = ? AND id IN ($marks)',
        variables: _vars([hidden, owner, ...chunk]),
      );
      await db.customUpdate(
        'UPDATE change_log SET owner_id = ? WHERE owner_id = ? '
        'AND entity = ? AND entity_id IN ($marks)',
        variables: _vars([hidden, owner, table, ...chunk]),
      );
    }
  }
});

/// Live tasks held on this device, as they change (the Account page's
/// notice).
Stream<int> watchHeldTaskCount(AppDatabase db) => db
    .customSelect(
      'SELECT count(*) AS n FROM occurrences WHERE deleted_at IS NULL '
      "AND user_id IN (SELECT substr(key, ${heldOwnerKey('').length + 1}) "
      "FROM local_meta WHERE key LIKE '${heldOwnerKey('')}%')",
      readsFrom: {db.occurrences, db.localMeta},
    )
    .watchSingle()
    .map((r) => r.read<int>('n'));

/// The hidden owner, made on first use: a copy of [owner]'s profile under
/// a new id, marked an account (so never a guest) and held. No one signs
/// in as it, so it is never shown or synced.
Future<String> _heldOwner(AppDatabase db, String owner) async {
  final existing = await (db.select(
    db.localMeta,
  )..where((m) => m.key.like('${heldOwnerKey('')}%'))).getSingleOrNull();
  if (existing != null) return existing.key.substring(heldOwnerKey('').length);
  final id = const UuidV7Generator().newId();
  final profile = await (db.select(
    db.profiles,
  )..where((p) => p.id.equals(owner))).getSingle();
  await db.into(db.profiles).insert(profile.copyWith(id: id));
  await _put(db, accountMarkerKey(id), '1');
  await _put(db, heldOwnerKey(id), owner);
  return id;
}

Future<Set<String>> _ids(AppDatabase db, String sql, List<Object> args) async =>
    {
      for (final r in await db.customSelect(sql, variables: _vars(args)).get())
        r.data.values.first! as String,
    };

List<Variable<Object>> _vars(List<Object> args) => [
  for (final a in args) a is int ? Variable<int>(a) : Variable<String>('$a'),
];

String _marks(int n) => List.filled(n, '?').join(', ');

Future<String?> _get(AppDatabase db, String key) async => (await (db.select(
  db.localMeta,
)..where((m) => m.key.equals(key))).getSingleOrNull())?.value;

Future<void> _put(AppDatabase db, String key, String value) => db
    .into(db.localMeta)
    .insertOnConflictUpdate(LocalMetaCompanion.insert(key: key, value: value));

Future<void> _forget(AppDatabase db, String key) =>
    (db.delete(db.localMeta)..where((m) => m.key.equals(key))).go();
