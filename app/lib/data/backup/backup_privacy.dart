/// The fenced steps that keep guest backups private (CR-160 I1), in one
/// place so every caller runs them in the same order. Each runs inside
/// `guestBackupFence.run`, never around it.
library;

import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/guest_backup_cutoff.dart';
import 'package:dottoday/data/backup/guest_backup_scrub.dart';
import 'package:dottoday/data/backup/legacy_guest_quarantine.dart';
import 'package:dottoday/data/db/app_database.dart';

/// First thing in every fenced backup operation: the legacy boundary (once
/// per device) and any cutoff a crash left pending.
Future<void> prepareFencedBackupWork(
  AppDatabase db,
  BackupDatabase backups, {
  required DateTime nowUtc,
}) async {
  await recordLegacyGuestBoundary(db, backups);
  await recordPendingGuestCutoffs(db, backups, nowUtc: nowUtc);
}

/// Maintenance (start and resume): P3, then the legacy evidence scrub when
/// due. Counts only are logged, never content.
Future<void> runBackupMaintenance(
  AppDatabase db,
  BackupDatabase backups, {
  required DateTime nowUtc,
  required Logger logger,
}) async {
  final left = await scrubExpiredGuestBackups(db, backups, nowUtc: nowUtc);
  if (left > 0) {
    logger.warn('backup.guest_scrub_left', fields: {'count': left});
  }
  final legacy = await scrubLegacyIfDue(db, backups, nowUtc: nowUtc);
  if (legacy != null && legacy.unreadable > 0) {
    logger.warn(
      'backup.legacy_scrub_unreadable',
      fields: {'count': legacy.unreadable},
    );
  }
}

/// After [account]'s deletion is confirmed, before its rows leave the
/// device: the legacy evidence scrub (the last moment its rows can prove
/// what is its), then P2.
Future<void> cleanUpGuestBackupsForDeletedAccount(
  AppDatabase db,
  BackupDatabase backups,
  String account, {
  required DateTime nowUtc,
  required Logger logger,
}) async {
  await prepareFencedBackupWork(db, backups, nowUtc: nowUtc);
  await scrubLegacyByEvidence(db, backups, accounts: {account});
  final left = await scrubForDeletedAccount(db, backups, account);
  if (left > 0) {
    logger.warn('backup.guest_scrub_left', fields: {'count': left});
  }
}
