/// Writing a backup as parts (CR-160 Stage B4,
/// docs/cr-160-multipart-export.md §4, §8), for an account whose backup
/// would be over the import limit. The account is read twice in one read
/// transaction (one consistent cut): the first pass plans where parts end
/// from each row's size, the second writes them, one part in memory at a
/// time. The backup row, its parts and its manifest are inserted in one
/// transaction of the backups file, so a half-written backup is never
/// visible; then it is read back and checked whole, or removed.
///
/// Rows are those `readUserData` gives a backup: every row the owner has,
/// Trash included, ordered by id; imported calendar events and their steps
/// left out.
library;

import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/multipart_backup_store.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_part.dart';
import 'package:dottoday/domain/export/multipart_planner.dart';
import 'package:drift/drift.dart';

/// Target size of a stored backup's parts: 5 MB, not the 10 MB of an
/// exported file. Peak memory grows with part size (a part is held as rows,
/// a sorted copy, its text and its bytes): 10 MB parts measured 120–131 MB
/// above idle for a 59 MB account, over §7's 100 MB; 5 MB measured 56–69
/// MB. Owner decision, 2026-11-11.
const backupPartTargetBytes = 5 * 1024 * 1024;

/// A stored multipart backup: its id and total bytes of its parts.
typedef StoredParts = ({int id, int bytes});

const _page = 500;

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
    final profileRow = await (db.select(
      db.profiles,
    )..where((p) => p.id.equals(owner))).getSingleOrNull();
    if (profileRow == null) return null;
    final profile = profileFromRow(profileRow).toJson();
    final planner = PartPlanner(
      exportId: exportId,
      profile: profile,
      targetBytes: targetBytes,
    );
    final totals = {for (final t in partTables) t: 0};
    var fits = true;
    // Drift resolves a query's transaction from the innermost zone, so
    // reads made while the backups file's transaction is open run back in
    // this one's zone (else they would wait on it: a deadlock).
    final reads = Zone.current;
    await _eachRow(db, reads, owner, (table, row) async {
      totals[table] = totals[table]! + 1;
      fits = fits && planner.add(table, row);
    });
    if (!fits) return null;
    final plan = planner.finish();
    return backups.transaction(() async {
      final id = await _store(db, reads, backups, owner, plan, profile, (
        exportId: exportId,
        reason: reason,
        nowUtc: nowUtc,
        schemaVersion: schemaVersion,
        totals: totals,
      ));
      return (id: id, totals: totals);
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
  TableCounts totals,
});

/// Inside both transactions: the backup row, every part, then the
/// manifest in place of the row's placeholder.
Future<int> _store(
  AppDatabase db,
  Zone reads,
  BackupDatabase backups,
  String owner,
  List<int> plan,
  Map<String, Object?> profile,
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
  final entries = <PartEntry>[];
  var part = <String, List<Map<String, Object?>>>{
    for (final t in partTables) t: [],
  };
  var inPart = 0;
  Future<void> flush() async {
    final index = entries.length + 1;
    final text = canonicalJson(
      ExportPart(
        exportId: meta.exportId,
        index: index,
        total: plan.length,
        profile: index == 1 ? profile : null,
        rows: part,
      ).toJson(),
    );
    // The rows are text now: let them go before the part is stored, and
    // encode it once for both its size and its hash (peak memory, §7).
    final counts = {for (final t in partTables) t: part[t]!.length};
    part = {for (final t in partTables) t: []};
    inPart = 0;
    final encoded = utf8.encode(text);
    final bytes = encoded.length;
    final hash = sha256.convert(encoded).toString();
    await backups
        .into(backups.backupParts)
        .insert(
          BackupPartsCompanion.insert(
            backupId: id,
            partIndex: index,
            sha256: hash,
            bytes: bytes,
            json: text,
          ),
        );
    entries.add(
      PartEntry(
        index: index,
        name: 'dottoday-backup-$id-part-$index-of-${plan.length}.json',
        bytes: bytes,
        sha256: hash,
        counts: counts,
      ),
    );
  }

  // Part 1 may hold the profile alone (the planner said so).
  while (entries.length < plan.length && plan[entries.length] == 0) {
    await flush();
  }
  await _eachRow(db, reads, owner, (table, row) async {
    part[table]!.add(row);
    inPart++;
    if (inPart == plan[entries.length]) {
      await flush();
      while (entries.length < plan.length && plan[entries.length] == 0) {
        await flush();
      }
    }
  });
  final manifest = ExportManifest(
    exportId: meta.exportId,
    exportedAtMs: meta.nowUtc.millisecondsSinceEpoch,
    appVersion: '',
    schemaVersion: meta.schemaVersion,
    purpose: ExportPurpose.backup,
    totals: meta.totals,
    parts: entries,
  );
  await (backups.update(backups.backups)..where((b) => b.id.equals(id))).write(
    BackupsCompanion(json: Value(canonicalJson(manifest.toJson()))),
  );
  return id;
}

/// Runs [visit] on every row a backup of [owner] holds, in written order
/// (part tables, then id), a page at a time, each page read in [reads].
Future<void> _eachRow(
  AppDatabase db,
  Zone reads,
  String owner,
  Future<void> Function(String table, Map<String, Object?> row) visit,
) async {
  final calendarEvents = db.selectOnly(db.occurrences)
    ..addColumns([db.occurrences.id])
    ..where(db.occurrences.source.equals('calendar'));
  for (final table in partTables) {
    var after = '';
    while (true) {
      final List<(String, Map<String, Object?>)> page = switch (table) {
        'series' => [
          for (final r in await reads.run(
            (db.select(db.seriesTable)
                  ..where(
                    (t) =>
                        t.userId.equals(owner) & t.id.isBiggerThanValue(after),
                  )
                  ..orderBy([(t) => OrderingTerm(expression: t.id)])
                  ..limit(_page))
                .get,
          ))
            (r.id, seriesFromRow(r).toJson()),
        ],
        'occurrences' => [
          for (final r in await reads.run(
            (db.select(db.occurrences)
                  ..where(
                    (t) =>
                        t.userId.equals(owner) &
                        t.id.isBiggerThanValue(after) &
                        t.source.equals('calendar').not(),
                  )
                  ..orderBy([(t) => OrderingTerm(expression: t.id)])
                  ..limit(_page))
                .get,
          ))
            (r.id, occurrenceFromRow(r).toJson()),
        ],
        'subtasks' => [
          for (final r in await reads.run(
            (db.select(db.subtasks)
                  ..where(
                    (t) =>
                        t.userId.equals(owner) &
                        t.id.isBiggerThanValue(after) &
                        t.occurrenceId.isNotInQuery(calendarEvents),
                  )
                  ..orderBy([(t) => OrderingTerm(expression: t.id)])
                  ..limit(_page))
                .get,
          ))
            (r.id, subtaskFromRow(r).toJson()),
        ],
        'routines' => [
          for (final r in await reads.run(
            (db.select(db.routinesTable)
                  ..where(
                    (t) =>
                        t.userId.equals(owner) & t.id.isBiggerThanValue(after),
                  )
                  ..orderBy([(t) => OrderingTerm(expression: t.id)])
                  ..limit(_page))
                .get,
          ))
            (r.id, routineFromRow(r).toJson()),
        ],
        // Backups never carry calendar templates (only D1's export does).
        _ => const [],
      };
      if (page.isEmpty) break;
      for (final (_, row) in page) {
        await visit(table, row);
      }
      after = page.last.$1;
    }
  }
}
