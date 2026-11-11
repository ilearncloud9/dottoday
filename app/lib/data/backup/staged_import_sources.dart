/// The three sources of the staged import (CR-160 Stage B3,
/// docs/cr-160-multipart-export.md §5, §8): each is staged a part at a
/// time, so at most one decoded part is held. Staging checks shape only;
/// rows are validated afterwards over the whole set (staged_import_checks).
library;

import 'dart:convert';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/multipart_backup_store.dart';
import 'package:dottoday/data/backup/staged_import_store.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_part.dart';
import 'package:drift/drift.dart';

/// A source refused the import; nothing live changed.
final class SourceRefused implements Exception {
  const SourceRefused(this.failure);
  final AppFailure failure;
}

const badImportFile = SourceRefused(
  ValidationFailure(ValidationField.importFile, ValidationRule.invalidFormat),
);
const _tooLarge = SourceRefused(
  ValidationFailure(ValidationField.importFile, ValidationRule.tooLarge),
);

/// Tables a v1 file must have, and those it may leave out.
const _required = ['series', 'occurrences', 'subtasks'];
const _optional = ['routines', 'calendarSeries'];

/// Stages a JSON v1 [text] (≤ 25 MB, decoded once, as today's import
/// does) as part 1.
Future<void> stageLegacyText(
  AppDatabase db,
  StagedImport import,
  String text,
) async {
  if (exceedsImportLimit(text)) throw _tooLarge;
  final Object? json;
  try {
    json = jsonDecode(text);
  } on FormatException {
    throw badImportFile;
  }
  if (json is! Map<String, Object?>) throw badImportFile;
  if (json['version'] != ExportBundle.version) throw badImportFile;
  if (json['exportedAt'] is! int) throw badImportFile;
  final profile = json['profile'];
  if (profile is! Map<String, Object?>) throw badImportFile;
  await stagePart(
    db,
    import,
    partIndex: 1,
    profile: profile,
    rows: {
      for (final t in [..._required, ..._optional])
        if (json.containsKey(t) || _required.contains(t)) t: _rowsOf(json[t]),
    },
  );
}

List<Map<String, Object?>> _rowsOf(Object? list) {
  if (list is! List<Object?>) throw badImportFile;
  if (list.any((r) => r is! Map<String, Object?>)) throw badImportFile;
  return list.cast<Map<String, Object?>>();
}

/// Stages a multipart set: [manifestText], then each of [parts] read and
/// checked one at a time. Returns the manifest's totals, which the global
/// checks hold the staged rows to.
Future<TableCounts> stageMultipart(
  AppDatabase db,
  StagedImport import,
  String manifestText,
  List<Future<String> Function()> parts,
) async {
  final manifest = ExportManifest.decode(manifestText);
  if (manifest == null) throw badImportFile;
  final set = PartSet(manifest);
  for (final read in parts) {
    switch (set.add(await read())) {
      case PartRefused(problem: PartProblem.tooLarge):
        throw _tooLarge;
      case PartRefused():
        throw badImportFile;
      case PartAccepted(duplicate: true):
        continue;
      case PartAccepted(:final part):
        await stagePart(
          db,
          import,
          partIndex: part.index,
          profile: part.profile,
          rows: part.rows,
        );
    }
  }
  if (!set.complete) throw badImportFile;
  return manifest.totals;
}

/// Stages stored backup [backupId] of the import's owner, read in place
/// inside the encrypted backups file with SQLite's JSON functions, a page
/// of rows at a time: the stored text is never decoded whole in Dart, so a
/// backup over 25 MB can be read too (§8). The caller holds
/// `guestBackupFence` and has checked the backup may be shown.
///
/// A multipart backup (Stage B4) is staged a part at a time from
/// `backup_parts`, each part checked against its manifest; its totals come
/// back for the global checks.
Future<TableCounts?> stageStoredBackup(
  AppDatabase db,
  BackupDatabase backups,
  StagedImport import,
  int backupId, {
  int page = 1000,
}) async {
  final owner = import.owner.userId;
  final manifest = await storedManifest(backups, backupId, owner);
  if (manifest != null) {
    return _stageStoredParts(db, backups, import, backupId, manifest);
  }
  final meta = await backups
      .customSelect(
        r"SELECT json_extract(json, '$.version') AS v, "
        r"json_type(json, '$.exportedAt') AS e, "
        r"json_extract(json, '$.profile') AS p, "
        "${[
          for (final t in [..._required, ..._optional]) "json_type(json, '\$.$t') AS t_$t",
        ].join(', ')} "
        'FROM backups WHERE id = ? AND owner = ?',
        variables: [Variable.withInt(backupId), Variable.withString(owner)],
        readsFrom: {backups.backups},
      )
      .getSingleOrNull();
  if (meta == null) throw const SourceRefused(StorageFailure());
  final types = meta.data;
  if (types['v'] != ExportBundle.version || types['e'] != 'integer') {
    throw badImportFile;
  }
  if (_required.any((t) => types['t_$t'] != 'array') ||
      _optional.any((t) => types['t_$t'] != null && types['t_$t'] != 'array')) {
    throw badImportFile;
  }
  final profile = types['p'] is String
      ? jsonDecode(types['p']! as String)
      : null;
  if (profile is! Map<String, Object?>) throw badImportFile;
  // A stored backup is its owner's own (today's requireOwner rule).
  if (profile['id'] != owner) throw const SourceRefused(StorageFailure());
  await stagePart(db, import, partIndex: 1, profile: profile, rows: {});
  var part = 1;
  for (final t in [..._required, ..._optional]) {
    var next = 0;
    while (true) {
      final rows = await backups
          .customSelect(
            'SELECT j.key AS k, j.type AS type, j.value AS value FROM '
            "backups, json_each(backups.json, '\$.$t') AS j "
            'WHERE backups.id = ? AND backups.owner = ? AND j.key >= ? '
            'ORDER BY j.key LIMIT ?',
            variables: [
              Variable.withInt(backupId),
              Variable.withString(owner),
              Variable.withInt(next),
              Variable.withInt(page),
            ],
            readsFrom: {backups.backups},
          )
          .get();
      if (rows.isEmpty) break;
      if (rows.any((r) => r.data['type'] != 'object')) throw badImportFile;
      await stagePart(
        db,
        import,
        partIndex: ++part,
        rows: {
          t: [
            for (final r in rows)
              jsonDecode(r.read<String>('value')) as Map<String, Object?>,
          ],
        },
      );
      next = rows.last.read<int>('k') + 1;
    }
  }
  return null;
}

Future<TableCounts> _stageStoredParts(
  AppDatabase db,
  BackupDatabase backups,
  StagedImport import,
  int backupId,
  ExportManifest manifest,
) async {
  final set = PartSet(manifest);
  for (final entry in manifest.parts) {
    final text = await storedPartText(backups, backupId, entry.index);
    if (text == null) throw badImportFile;
    switch (set.add(text)) {
      case PartRefused():
        throw badImportFile;
      case PartAccepted(duplicate: true):
        throw badImportFile;
      case PartAccepted(:final part):
        // A stored backup is its owner's own (today's requireOwner rule).
        if (part.index == 1 && part.profile?['id'] != import.owner.userId) {
          throw const SourceRefused(StorageFailure());
        }
        await stagePart(
          db,
          import,
          partIndex: part.index,
          profile: part.profile,
          rows: part.rows,
        );
    }
  }
  if (!set.complete) throw badImportFile;
  return manifest.totals;
}

/// The size [import] of stored backup [backupId] declares (its bytes), or
/// null when it isn't [owner]'s.
Future<int?> storedBackupBytes(
  BackupDatabase backups,
  int backupId,
  String owner,
) async =>
    (await backups
            .customSelect(
              // A multipart backup's size is its parts' (Stage B4).
              'SELECT COALESCE((SELECT SUM(p.bytes) FROM backup_parts p '
              'WHERE p.backup_id = backups.id), length(CAST(json AS BLOB))) '
              'AS n FROM backups WHERE id = ? AND owner = ?',
              variables: [
                Variable.withInt(backupId),
                Variable.withString(owner),
              ],
              readsFrom: {backups.backups, backups.backupParts},
            )
            .getSingleOrNull())
        ?.read<int>('n');
