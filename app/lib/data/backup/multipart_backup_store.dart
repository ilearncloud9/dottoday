/// Reading multipart backups (CR-160 Stage B4,
/// docs/cr-160-multipart-export.md §8): a backup over the import limit is
/// stored as parts in `backup_parts`, its `backups` row holding the
/// manifest. Every read is by the backup's id and checked against its
/// owner; parts are read one at a time.
library;

import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/domain/export/import_file_kind.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_part.dart';
import 'package:drift/drift.dart';

/// Backup [id]'s manifest when it is [owner]'s and stored as parts; null
/// otherwise (not a multipart backup, not [owner]'s, or no such backup).
Future<ExportManifest?> storedManifest(
  BackupDatabase backups,
  int id,
  String owner,
) async {
  final row = await backups
      .customSelect(
        'SELECT json FROM backups WHERE id = ? AND owner = ?',
        variables: [Variable.withInt(id), Variable.withString(owner)],
        readsFrom: {backups.backups},
      )
      .getSingleOrNull();
  if (row == null) return null;
  final json = row.read<String>('json');
  if (importFileKind(json) != ImportFileKind.manifest) return null;
  return ExportManifest.decode(json);
}

/// Part [index] of backup [id], as stored; null when missing.
Future<String?> storedPartText(
  BackupDatabase backups,
  int id,
  int index,
) async =>
    (await backups
            .customSelect(
              'SELECT json FROM backup_parts WHERE backup_id = ? AND '
              'part_index = ?',
              variables: [Variable.withInt(id), Variable.withInt(index)],
              readsFrom: {backups.backupParts},
            )
            .getSingleOrNull())
        ?.read<String>('json');

/// Whether backup [id] is stored as parts.
Future<bool> isMultipartBackup(BackupDatabase backups, int id) async =>
    (await backups
        .customSelect(
          'SELECT 1 FROM backup_parts WHERE backup_id = ? LIMIT 1',
          variables: [Variable.withInt(id)],
          readsFrom: {backups.backupParts},
        )
        .getSingleOrNull()) !=
    null;

/// Whether multipart backup [id] reads back as [owner]'s complete set: the
/// manifest decodes, every part is present and matches its hash, index,
/// total and counts, part 1's profile is [owner]'s, and (when given) the
/// totals are [totals]. Parts are read one at a time.
Future<bool> verifyStoredMultipart(
  BackupDatabase backups,
  int id,
  String owner, {
  TableCounts? totals,
}) async {
  final manifest = await storedManifest(backups, id, owner);
  if (manifest == null) return false;
  if (totals != null &&
      partTables.any((t) => manifest.totals[t] != totals[t])) {
    return false;
  }
  final set = PartSet(manifest);
  for (final entry in manifest.parts) {
    final text = await storedPartText(backups, id, entry.index);
    if (text == null) return false;
    switch (set.add(text)) {
      case PartRefused():
        return false;
      case PartAccepted(:final part):
        if (part.index == 1 && part.profile?['id'] != owner) return false;
    }
  }
  return set.complete;
}

/// Whether [owner]'s latest backup was too large for one file (stored as
/// parts, or over [limit]): the next one starts as parts, without first
/// reading the whole account into memory.
Future<bool> previousBackupLarge(
  BackupDatabase backups,
  String owner, {
  required int limit,
}) async {
  final row = await backups
      .customSelect(
        'SELECT length(CAST(json AS BLOB)) AS n, EXISTS (SELECT 1 FROM '
        'backup_parts p WHERE p.backup_id = backups.id) AS parts FROM backups '
        'WHERE owner = ? ORDER BY created_at DESC, id DESC LIMIT 1',
        variables: [Variable.withString(owner)],
        readsFrom: {backups.backups, backups.backupParts},
      )
      .getSingleOrNull();
  if (row == null) return false;
  return row.read<int>('parts') == 1 || row.read<int>('n') > limit;
}
