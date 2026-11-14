/// A read-only audit of every stored backup (CR-160 I1): what it is, whose
/// it provably is, whether a supported path can restore it, what refers to
/// it, and whether it would be a deletion candidate under the proposed
/// rules. It changes nothing and deletes nothing; deletion needs the
/// product owner's consent. Counts only may be logged, never content.
library;

import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/guest_backup_cutoff.dart';
import 'package:dottoday/data/backup/multipart_backup_store.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/domain/backup/backup_recovery.dart';

/// What refers to a backup in the app's supported workflows.
enum BackupReference {
  /// Listed to its owner and restorable from Settings.
  listed,

  /// Hidden by a recorded promotion (P1–P3 scrub it).
  promotion,

  /// In the legacy quarantine.
  legacyQuarantine,
}

/// One backup's audit.
final class BackupAuditEntry {
  const BackupAuditEntry({
    required this.id,
    required this.owner,
    required this.appSchemaVersion,
    required this.reason,
    required this.bytes,
    required this.recovery,
    required this.references,
  });

  final int id;
  final String? owner;
  final int appSchemaVersion;
  final String reason;
  final int bytes;
  final BackupRecovery recovery;
  final Set<BackupReference> references;

  /// Whose it is can be proven: an owner column that its content agrees
  /// with (the restore check passed, or only its size stopped the check).
  bool get ownerEstablished =>
      owner != null &&
      (recovery == BackupRecovery.restorable ||
          recovery == BackupRecovery.oversized);

  /// A supported path restores it today: it passes the check and is
  /// listed to its owner.
  bool get restorableNow =>
      recovery == BackupRecovery.restorable &&
      references.contains(BackupReference.listed);

  /// Stage B4's large-backup reader is its only planned path.
  bool get b4Eligible => recovery == BackupRecovery.oversized;

  /// Under the proposed rules (not applied): no supported path can ever
  /// restore it and it is not listed. Never for oversized (B4), storage or
  /// unknown failures (try again), or a listed backup.
  bool get deletionCandidate {
    if (references.contains(BackupReference.listed)) return false;
    return switch (recovery) {
      BackupRecovery.noOwner ||
      BackupRecovery.malformed ||
      BackupRecovery.wrongOwner => true,
      BackupRecovery.restorable ||
      BackupRecovery.oversized ||
      BackupRecovery.storageError ||
      BackupRecovery.unknown => false,
    };
  }
}

/// Audits every stored backup, one at a time.
Future<List<BackupAuditEntry>> auditBackups(
  AppDatabase db,
  BackupDatabase backups,
) async {
  final rows = await backups
      .customSelect(
        'SELECT id, owner, app_schema_version, reason, '
        // A multipart backup's size is its parts' (CR-160 Stage B4).
        'COALESCE((SELECT SUM(p.bytes) FROM backup_parts p WHERE '
        'p.backup_id = backups.id), length(CAST(json AS BLOB))) AS bytes '
        'FROM backups ORDER BY id',
        readsFrom: {backups.backups, backups.backupParts},
      )
      .get();
  return [
    for (final r in rows)
      await _audit(
        db,
        backups,
        id: r.read<int>('id'),
        owner: r.readNullable<String>('owner'),
        schema: r.read<int>('app_schema_version'),
        reason: r.read<String>('reason'),
        bytes: r.read<int>('bytes'),
      ),
  ];
}

Future<BackupAuditEntry> _audit(
  AppDatabase db,
  BackupDatabase backups, {
  required int id,
  required String? owner,
  required int schema,
  required String reason,
  required int bytes,
}) async {
  var recovery = BackupRecovery.unknown;
  try {
    final row = await (backups.select(
      backups.backups,
    )..where((b) => b.id.equals(id))).getSingle();
    try {
      // A multipart backup (CR-160 Stage B4) is read back whole, a part at
      // a time: restorable, or malformed when any part fails its check.
      recovery = owner != null && await isMultipartBackup(backups, id)
          ? (await verifyStoredMultipart(backups, id, owner)
                ? BackupRecovery.restorable
                : BackupRecovery.malformed)
          : classifyBackupJson(row.json, owner);
    } on Object {
      recovery = BackupRecovery.unknown;
    }
  } on Exception {
    recovery = BackupRecovery.storageError;
  }
  final references = <BackupReference>{};
  if (owner != null) {
    final v = await guestBackupVisibility(db, owner);
    if (!v.hides(id)) references.add(BackupReference.listed);
    if (v.quarantines(id)) references.add(BackupReference.legacyQuarantine);
    if (v.governing(id) != null) references.add(BackupReference.promotion);
  }
  return BackupAuditEntry(
    id: id,
    owner: owner,
    appSchemaVersion: schema,
    reason: reason,
    bytes: bytes,
    recovery: recovery,
    references: references,
  );
}
