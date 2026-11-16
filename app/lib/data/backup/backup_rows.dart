/// Stored backups read one at a time (CR-160 I1, scrub memory). A backup's
/// text can be close to 25 MB, so the privacy scrubs list ids and owners
/// first, without any text, and then read each backup's text on its own:
/// never more than one backup's text is held at once.
library;

import 'package:dottoday/data/backup/backup_database.dart';
import 'package:drift/drift.dart';

/// A stored backup's id and owner, without its text.
typedef BackupKey = ({int id, String? owner});

/// The ids and owners of every stored backup ([owner]'s only when given),
/// in id order, without their text.
Future<List<BackupKey>> backupKeys(
  BackupDatabase backups, {
  String? owner,
}) async {
  final rows = await backups
      .customSelect(
        'SELECT id, owner FROM backups '
        '${owner == null ? '' : 'WHERE owner = ? '}ORDER BY id',
        variables: [if (owner != null) Variable.withString(owner)],
        readsFrom: {backups.backups},
      )
      .get();
  return [
    for (final r in rows)
      (id: r.read<int>('id'), owner: r.readNullable<String>('owner')),
  ];
}

/// What reading one listed backup found. Only [BackupGone] may be skipped
/// silently; a read that fails throws (never swallowed).
sealed class BackupRead {
  const BackupRead();
}

/// The row no longer exists (removed after it was listed).
final class BackupGone extends BackupRead {
  const BackupGone();
}

/// The row exists but is no longer the expected owner's: never scrubbed,
/// never shown, counted as left (fail closed).
final class BackupOwnerChanged extends BackupRead {
  const BackupOwnerChanged();
}

/// The row's current text, read now (never a copy from the listing).
final class BackupText extends BackupRead {
  const BackupText(this.json);
  final String json;
}

/// Reads backup [id]'s text now, checking it is still [owner]'s.
Future<BackupRead> readBackupOf(
  BackupDatabase backups,
  int id,
  String owner,
) async {
  final row = await backups
      .customSelect(
        'SELECT owner, json FROM backups WHERE id = ?',
        variables: [Variable.withInt(id)],
        readsFrom: {backups.backups},
      )
      .getSingleOrNull();
  if (row == null) return const BackupGone();
  if (row.readNullable<String>('owner') != owner) {
    return const BackupOwnerChanged();
  }
  return BackupText(row.read<String>('json'));
}
