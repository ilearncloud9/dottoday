import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/domain/backup/backup_restorability.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:drift/drift.dart';

/// Retention for [owner]'s backups of [reason] (CR-160 backup safety): the
/// [keep] newest stay, older ones go, except [owner]'s newest backup that
/// still passes the restore check ([isRestorableBackup]), whatever its
/// reason: newer backups that can't be restored (over the import limit,
/// say) never push out the last one that can. That one may be old, so it
/// can hold stale data; it is a last resort, not the account's latest
/// state. At most one extra backup per owner, and only while none newer can
/// be restored; account removal still deletes every one of the owner's
/// backups. Other owners' backups are never read or touched.
Future<void> pruneKeepingRestorable(
  BackupDatabase backups,
  String owner,
  String reason,
  int keep,
) async {
  final rows = await _ownedNewestFirst(backups, owner);
  final doomed = [
    for (final r in rows.where((r) => r.reason == reason).skip(keep)) r.id,
  ];
  if (doomed.isEmpty) return;
  for (final r in rows) {
    // Over the limit is refused by size alone, without reading the text.
    if (r.bytes > maxImportBytes) continue;
    if (!await _restorable(backups, r.id, owner)) continue;
    doomed.remove(r.id); // the last restorable one stays
    break;
  }
  if (doomed.isEmpty) return;
  await (backups.delete(
    backups.backups,
  )..where((b) => b.owner.equals(owner) & b.id.isIn(doomed))).go();
}

typedef _Row = ({int id, String reason, int bytes});

Future<List<_Row>> _ownedNewestFirst(
  BackupDatabase backups,
  String owner,
) async {
  final rows = await backups
      .customSelect(
        'SELECT id, reason, length(CAST(json AS BLOB)) AS bytes FROM backups '
        'WHERE owner = ? ORDER BY created_at DESC, id DESC',
        variables: [Variable.withString(owner)],
        readsFrom: {backups.backups},
      )
      .get();
  return [
    for (final r in rows)
      (
        id: r.read<int>('id'),
        reason: r.read<String>('reason'),
        bytes: r.read<int>('bytes'),
      ),
  ];
}

Future<bool> _restorable(BackupDatabase backups, int id, String owner) async {
  final row = await (backups.select(
    backups.backups,
  )..where((b) => b.id.equals(id) & b.owner.equals(owner))).getSingleOrNull();
  return row != null && isRestorableBackup(row.json, owner);
}
