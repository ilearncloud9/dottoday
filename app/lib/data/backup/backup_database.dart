import 'package:drift/drift.dart';

part 'backup_database.g.dart';

/// One stored backup: an export bundle (JSON v1) of one owner's data.
@DataClassName('BackupRow')
class Backups extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get createdAt => integer()();
  TextColumn get reason => text()();

  /// `AppDatabase.latestSchemaVersion` when taken, for diagnostics.
  IntColumn get appSchemaVersion => integer()();
  TextColumn get json => text()();

  /// The profile id the backup was taken for (CR-160 I2). Listing,
  /// restoring, the daily check and retention only ever see one owner's
  /// backups. Null only for a schema-1 backup whose owner could not be
  /// proven: such a backup belongs to nobody and is never listed or
  /// restored.
  TextColumn get owner => text().nullable()();

  @override
  List<String> get customConstraints => const [
    "CHECK (reason IN ('daily', 'preImport', 'preRestore'))",
    'CHECK (json_valid(json))',
  ];

  @override
  bool get isStrict => true;
}

/// One part of a multipart backup (CR-160 Stage B4, backup schema 3,
/// docs/cr-160-multipart-export.md §8): a backup over the import limit is
/// stored as parts, its `backups` row holding the manifest. Ownership,
/// privacy cutoffs and quarantine stay keyed by the backup's id, and the
/// parts go with their backup (ON DELETE CASCADE).
@DataClassName('BackupPartRow')
class BackupParts extends Table {
  IntColumn get backupId => integer()();

  /// 1-based, as the manifest numbers them.
  IntColumn get partIndex => integer()();
  TextColumn get sha256 => text()();
  IntColumn get bytes => integer()();
  TextColumn get json => text()();

  @override
  Set<Column<Object>> get primaryKey => {backupId, partIndex};

  @override
  List<String> get customConstraints => const [
    'FOREIGN KEY (backup_id) REFERENCES backups (id) ON DELETE CASCADE',
    'CHECK (part_index >= 1)',
    'CHECK (length(sha256) = 64)',
    'CHECK (bytes > 0)',
    'CHECK (json_valid(json))',
  ];

  @override
  bool get isStrict => true;
}

/// Local backups, in their own encrypted file (`dottoday-backups.db`, same
/// key as the app database, 06 §4) so damage to one file can't take the
/// other with it.
@DriftDatabase(tables: [Backups, BackupParts])
class BackupDatabase extends _$BackupDatabase {
  BackupDatabase(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createOwnerIndex();
    },
    onUpgrade: (m, from, to) async {
      // Forward-only steps, one per version.
      if (from < 2) await _addOwner(m);
      // 3 (CR-160 Stage B4): multipart backups' parts, empty.
      if (from < 3) await m.createTable(backupParts);
    },
    // Per connection, never persisted: parts cascade with their backup
    // only while foreign keys are on (the web connection sets none).
    beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
  );

  /// Schema 2 (CR-160 I2): every backup gets an owner. A schema-1 backup
  /// was only ever written by `DriftBackupService.create`, from
  /// `readUserData(userId)`, whose bundle profile is that user's own
  /// profile row; so `$.profile.id` proves whose it is. A row where that is
  /// missing stays ownerless (nobody's) rather than being guessed.
  Future<void> _addOwner(Migrator m) async {
    await m.addColumn(backups, backups.owner);
    await customStatement(
      r"UPDATE backups SET owner = json_extract(json, '$.profile.id') "
      'WHERE owner IS NULL '
      r"AND json_type(json, '$.profile.id') = 'text'",
    );
    await _createOwnerIndex();
  }

  /// Every query filters by owner and reason, newest first.
  Future<void> _createOwnerIndex() => customStatement(
    'CREATE INDEX IF NOT EXISTS backups_owner_reason_created '
    'ON backups (owner, reason, created_at)',
  );

  /// Removes every backup of [owner] (account removal, CR-160). Idempotent:
  /// a second call, or an owner with no backups, deletes nothing.
  Future<void> deleteBackupsOf(String owner) =>
      (delete(backups)..where((b) => b.owner.equals(owner))).go();
}
