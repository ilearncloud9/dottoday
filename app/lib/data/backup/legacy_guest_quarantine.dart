/// Guest backups that existed before this protection first ran (CR-160 I1,
/// legacy guest-backup privacy). A move of guest work into an account made
/// by an earlier build recorded nothing, so no device can prove which of
/// its guest backups hold another account's work, nor that no account ever
/// signed in. They are therefore quarantined, all of them (fail closed):
/// hidden from listing and restoring, never shown again automatically,
/// never deleted here.
///
/// The boundary is the last backup id issued when the first fenced backup
/// operation of this build runs (`prepareFencedBackupWork`), recorded once
/// and never moved. Every backup this build makes is made under the fence
/// after that, so it is above the boundary: a crash before recording leaves
/// no boundary, and the first fenced operation records it before anything
/// else; while it is missing every guest backup is hidden. If the backups
/// file is ever recreated its ids start again under the boundary, so new
/// guest backups are hidden too (fail closed, never the reverse).
///
/// The evidence scrub only narrows what a quarantined backup holds: rows
/// whose ids an account on this device holds now, and guest starter tasks
/// whose re-keyed id an account holds, are positively that account's work
/// and are taken out. Nothing about a row's absence is evidence of
/// anything, so the scrub never makes a backup visible.
library;

import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/guest_backup_cutoff.dart';
import 'package:dottoday/data/backup/guest_backup_scrub.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/owner_meta.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:drift/drift.dart';

const _lastScrubKey = 'legacy_guest_scrub_at';

/// How often maintenance runs the evidence scrub at most.
const legacyScrubInterval = Duration(hours: 24);

/// Records the legacy boundary if this device has none yet. Under
/// `guestBackupFence`, before any other backup work.
Future<void> recordLegacyGuestBoundary(
  AppDatabase db,
  BackupDatabase backups,
) async {
  final held = await (db.select(
    db.localMeta,
  )..where((m) => m.key.equals(legacyGuestBoundaryKey))).getSingleOrNull();
  if (held != null) return;
  await db
      .into(db.localMeta)
      .insert(
        LocalMetaCompanion.insert(
          key: legacyGuestBoundaryKey,
          value: '${await lastBackupIdIssued(backups)}',
        ),
        mode: InsertMode.insertOrIgnore,
      );
}

/// What one evidence scrub did.
typedef LegacyScrub = ({int scrubbed, int unreadable});

/// Takes out of every quarantined guest backup the rows positively shown
/// to be an account's: ids [accounts] (every account on this device when
/// null) hold now, and starters re-keyed into them. Under the fence.
Future<LegacyScrub> scrubLegacyByEvidence(
  AppDatabase db,
  BackupDatabase backups, {
  Set<String>? accounts,
}) async {
  final owners = accounts ?? await _accounts(db);
  var scrubbed = 0;
  var unreadable = 0;
  if (owners.isEmpty) return (scrubbed: 0, unreadable: 0);
  final rows = await backups.select(backups.backups).get();
  for (final row in rows) {
    final guest = row.owner;
    if (guest == null) continue;
    final visibility = await guestBackupVisibility(db, guest);
    if (!visibility.quarantines(row.id)) continue;
    final bundle = _decoded(row.json);
    if (bundle == null) {
      unreadable++;
      continue;
    }
    final evidence = await _evidence(db, bundle, guest, owners);
    if (evidence.values.every((ids) => ids.isEmpty)) continue;
    final clean = scrubbedBackupJson(row.json, guest, evidence);
    if (clean == null) {
      unreadable++;
      continue;
    }
    await (backups.update(backups.backups)
          ..where((b) => b.id.equals(row.id) & b.owner.equals(guest)))
        .write(BackupsCompanion(json: Value(clean)));
    scrubbed++;
  }
  return (scrubbed: scrubbed, unreadable: unreadable);
}

/// Maintenance's evidence scrub: at most every [legacyScrubInterval] (and
/// again whenever the clock went back). Null when not due.
Future<LegacyScrub?> scrubLegacyIfDue(
  AppDatabase db,
  BackupDatabase backups, {
  required DateTime nowUtc,
}) async {
  final now = nowUtc.millisecondsSinceEpoch;
  final last = int.tryParse(
    (await (db.select(
              db.localMeta,
            )..where((m) => m.key.equals(_lastScrubKey))).getSingleOrNull())
            ?.value ??
        '',
  );
  if (last != null &&
      last <= now &&
      now - last < legacyScrubInterval.inMilliseconds) {
    return null;
  }
  final result = await scrubLegacyByEvidence(db, backups);
  await db
      .into(db.localMeta)
      .insertOnConflictUpdate(
        LocalMetaCompanion.insert(key: _lastScrubKey, value: '$now'),
      );
  return result;
}

ExportBundle? _decoded(String json) => switch (decodeExportJson(json)) {
  Ok(:final value) => value,
  Err() => null,
};

Future<Set<String>> _accounts(AppDatabase db) async {
  final prefix = accountMarkerKey('');
  return {
    for (final m in await (db.select(
      db.localMeta,
    )..where((m) => m.key.like('$prefix%'))).get())
      m.key.substring(prefix.length),
  };
}

/// Per table, the ids of [bundle] an account in [accounts] positively holds.
Future<Map<String, Set<String>>> _evidence(
  AppDatabase db,
  ExportBundle bundle,
  String guest,
  Set<String> accounts,
) async {
  final byTable = <String, Iterable<String>>{
    'series': bundle.series.map((s) => s.id),
    'occurrences': bundle.occurrences.map((o) => o.id),
    'subtasks': bundle.subtasks.map((s) => s.id),
    'routines': bundle.routines.map((r) => r.id),
  };
  final out = {
    for (final MapEntry(key: t, value: ids) in byTable.entries)
      t: await _heldByAccounts(db, t, ids.toList(), accounts),
  };
  for (final o in bundle.occurrences) {
    final start = o.startUtc;
    if (o.seriesId != null || start == null) continue;
    for (final account in accounts) {
      final rekeyed = starterRekeyFor(
        o.id,
        start.millisecondsSinceEpoch,
        o.tzId,
        guest,
        account,
      );
      if (rekeyed == null) continue;
      final held = await _heldByAccounts(
        db,
        'occurrences',
        [rekeyed],
        {account},
      );
      if (held.isNotEmpty) out['occurrences']!.add(o.id);
    }
  }
  return out;
}

Future<Set<String>> _heldByAccounts(
  AppDatabase db,
  String table,
  List<String> ids,
  Set<String> accounts,
) async {
  final out = <String>{};
  final owners = accounts.toList();
  for (var i = 0; i < ids.length; i += 400) {
    final chunk = ids.sublist(i, (i + 400).clamp(0, ids.length));
    final rows = await db
        .customSelect(
          'SELECT id FROM $table WHERE id IN '
          '(${List.filled(chunk.length, '?').join(', ')}) AND user_id IN '
          '(${List.filled(owners.length, '?').join(', ')})',
          variables: [
            for (final id in chunk) Variable<String>(id),
            for (final a in owners) Variable<String>(a),
          ],
        )
        .get();
    out.addAll(rows.map((r) => r.read<String>('id')));
  }
  return out;
}
