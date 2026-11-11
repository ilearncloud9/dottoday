/// Taking one backup (CR-160 backup safety, Stage B4). Under
/// `guestBackupFence`, called by `DriftBackupService` only.
///
/// A backup that fits the import limit is today's JSON v1 row, unchanged.
/// One over it is written as parts (multipart_backup_writer.dart), so it can
/// be restored (§8): an account whose last backup was already that large
/// goes straight to parts, without first reading itself into memory whole.
///
/// [verify] (the safety backup before an import or restore): the backup is
/// read back and checked the way a restore would read it, complete against
/// the account it was taken of; one that fails is removed and
/// [BackupNotRestorableFailure] stops the operation before any live change.
/// A safety backup may be parts: the staged restore, and so Undo, reads
/// them (B5 lifted B4's refusal). Every backup stored as parts is always
/// read back whole. Pruning runs only after a check passed.
library;

import 'dart:convert';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/backup_retention.dart';
import 'package:dottoday/data/backup/guest_backup_cutoff.dart';
import 'package:dottoday/data/backup/multipart_backup_store.dart';
import 'package:dottoday/data/backup/multipart_backup_writer.dart';
import 'package:dottoday/data/backup/user_data_snapshot.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:drift/drift.dart';

/// Size rules of one backup (tests shrink them).
typedef BackupLimits = ({int singleFile, int part});

const defaultBackupLimits = (
  singleFile: maxImportBytes,
  part: backupPartTargetBytes,
);

/// Takes [owner]'s backup for [reason] at [now] and applies retention
/// ([keep] of that reason).
Future<Result<BackupInfo, AppFailure>> createBackup(
  AppDatabase db,
  BackupDatabase backups,
  String owner,
  BackupReason reason, {
  required DateTime now,
  required int keep,
  required bool verify,
  required IdGenerator ids,
  required Logger logger,
  BackupLimits limits = defaultBackupLimits,
  Future<void> Function()? afterRead,
}) async {
  Result<BackupInfo, AppFailure> notRestorable() {
    logger.warn('backup.not_restorable');
    return const Err(BackupNotRestorableFailure());
  }

  int? id;
  var size = 0;
  if (!await previousBackupLarge(backups, owner, limit: limits.singleFile)) {
    final bundle = await db.transaction(() => readUserData(db, owner, now));
    if (bundle == null) return const Err(StorageFailure());
    final json = encodeExportJson(bundle);
    if (utf8.encode(json).length <= limits.singleFile) {
      await afterRead?.call();
      id = await backups
          .into(backups.backups)
          .insert(
            BackupsCompanion.insert(
              createdAt: now.millisecondsSinceEpoch,
              reason: reason.name,
              appSchemaVersion: AppDatabase.latestSchemaVersion,
              json: json,
              owner: Value(owner),
            ),
          );
      if (verify && !await storedBackupRestorable(backups, id, owner, bundle)) {
        await (backups.delete(
          backups.backups,
        )..where((b) => b.id.equals(id!))).go();
        return notRestorable();
      }
      size = json.length;
    }
  }
  if (id == null) {
    // Too large for one file: parts (CR-160 Stage B4).
    final stored = await writeMultipartBackup(
      db,
      backups,
      owner,
      reason: reason.name,
      nowUtc: now,
      exportId: ids.newId(),
      schemaVersion: AppDatabase.latestSchemaVersion,
      targetBytes: limits.part,
    );
    if (stored == null) return notRestorable();
    id = stored.id;
    size = stored.bytes;
  }
  await pruneKeepingRestorable(
    backups,
    owner,
    reason.name,
    keep,
    hidden: (await guestBackupVisibility(db, owner)).hides,
  );
  return Ok(
    BackupInfo(id: id, createdAtUtc: now, reason: reason, sizeBytes: size),
  );
}
