import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/drift_backup_service.dart';
import 'package:dottoday/data/db/connection/connection.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'backup_providers.g.dart';

/// The encrypted backups file. Tests override with an in-memory database.
@Riverpod(keepAlive: true)
BackupDatabase backupDatabase(Ref ref) {
  final db = BackupDatabase(
    openEncryptedExecutor(
      ref.watch(databaseKeyStoreProvider),
      'dottoday-backups',
    ),
  );
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
BackupService backupService(Ref ref) => DriftBackupService(
  db: ref.watch(appDatabaseProvider),
  backups: ref.watch(backupDatabaseProvider),
  writes: ref.watch(writeUseCaseProvider),
  clock: ref.watch(clockProvider),
  logger: ref.watch(loggerProvider),
);

/// The backups on this device, newest first (Settings › Export). Invalidate
/// after taking or restoring one.
@riverpod
Future<List<BackupInfo>> backupList(Ref ref) {
  // The shown owner's backups only; a change of owner reads them again
  // (CR-160 I2).
  ref.watch(ownerEpochProvider);
  return ref.watch(backupServiceProvider).list();
}
