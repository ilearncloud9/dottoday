/// Writing a backup as parts (CR-160 Stage B4,
/// docs/cr-160-multipart-export.md §4, §8). The account is read in one
/// read transaction through the part stream (part_stream.dart, shared with
/// the multipart export): a planning pass, then the parts one at a time.
/// The backup row, its parts and its manifest are inserted in one
/// transaction of the backups file, so a half-written backup is never
/// visible; then it is read back and checked whole, or removed.
///
/// Rows are those `readUserData` gives a backup ([RowScope.standard]).
library;

import 'dart:async';

import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/multipart_backup_store.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/export/part_stream.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:drift/drift.dart';

/// Target size of a stored backup's parts: 5 MB, not the 10 MB of an
/// exported file. Peak memory grows with part size (a part is held as rows,
/// a sorted copy, its text and its bytes): 10 MB parts measured 120–131 MB
/// above idle for a 59 MB account, over §7's 100 MB; 5 MB measured 56–69
/// MB. Owner decision, 2026-11-11.
const backupPartTargetBytes = 5 * 1024 * 1024;

/// A stored multipart backup: its id and total bytes of its parts.
typedef StoredParts = ({int id, int bytes});

/// Writes [owner]'s backup as parts of at most [targetBytes]. Null when
/// nothing was kept: no profile, a row too large for any part, or the
/// written backup didn't read back whole (then it was removed).
Future<StoredParts?> writeMultipartBackup(
  AppDatabase db,
  BackupDatabase backups,
  String owner, {
  required String reason,
  required DateTime nowUtc,
  required String exportId,
  required int schemaVersion,
  int targetBytes = backupPartTargetBytes,
}) async {
  final written = await db.transaction(() async {
    // Drift resolves a query's transaction from the innermost zone, so
    // reads made while the backups file's transaction is open run back in
    // this one's zone (else they would wait on it: a deadlock).
    final reads = Zone.current;
    final planned = await planParts(
      db,
      reads,
      owner,
      RowScope.standard,
      exportId: exportId,
      targetBytes: targetBytes,
    );
    if (planned is! PartPlan) return null;
    return backups.transaction(() async {
      final id = await _store(db, reads, backups, owner, planned, (
        exportId: exportId,
        reason: reason,
        nowUtc: nowUtc,
        schemaVersion: schemaVersion,
      ));
      return (id: id, totals: planned.totals);
    });
  });
  if (written == null) return null;
  if (!await verifyStoredMultipart(
    backups,
    written.id,
    owner,
    totals: written.totals,
  )) {
    await (backups.delete(
      backups.backups,
    )..where((b) => b.id.equals(written.id))).go();
    return null;
  }
  final bytes = await backups
      .customSelect(
        'SELECT COALESCE(SUM(bytes), 0) AS n FROM backup_parts '
        'WHERE backup_id = ?',
        variables: [Variable.withInt(written.id)],
        readsFrom: {backups.backupParts},
      )
      .getSingle();
  return (id: written.id, bytes: bytes.read<int>('n'));
}

typedef _Meta = ({
  String exportId,
  String reason,
  DateTime nowUtc,
  int schemaVersion,
});

/// Inside both transactions: the backup row, every part, then the
/// manifest in place of the row's placeholder.
Future<int> _store(
  AppDatabase db,
  Zone reads,
  BackupDatabase backups,
  String owner,
  PartPlan plan,
  _Meta meta,
) async {
  final id = await backups
      .into(backups.backups)
      .insert(
        BackupsCompanion.insert(
          createdAt: meta.nowUtc.millisecondsSinceEpoch,
          reason: meta.reason,
          appSchemaVersion: meta.schemaVersion,
          json: '{}',
          owner: Value(owner),
        ),
      );
  final entries = await writeParts(
    db,
    reads,
    owner,
    RowScope.standard,
    plan,
    exportId: meta.exportId,
    name: (index, total) => 'dottoday-backup-$id-part-$index-of-$total.json',
    sink: (index, text, bytes, hash) => backups
        .into(backups.backupParts)
        .insert(
          BackupPartsCompanion.insert(
            backupId: id,
            partIndex: index,
            sha256: hash,
            bytes: bytes.length,
            json: text,
          ),
        ),
  );
  final manifest = ExportManifest(
    exportId: meta.exportId,
    exportedAtMs: meta.nowUtc.millisecondsSinceEpoch,
    appVersion: '',
    schemaVersion: meta.schemaVersion,
    purpose: ExportPurpose.backup,
    totals: plan.totals,
    parts: entries,
  );
  await (backups.update(backups.backups)..where((b) => b.id.equals(id))).write(
    BackupsCompanion(json: Value(canonicalJson(manifest.toJson()))),
  );
  return id;
}
