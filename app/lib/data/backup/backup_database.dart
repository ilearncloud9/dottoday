import 'package:drift/drift.dart';

part 'backup_database.g.dart';

/// One stored backup: an export bundle (JSON v1) of one user's data.
@DataClassName('BackupRow')
class Backups extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get createdAt => integer()();
  TextColumn get reason => text()();

  /// `AppDatabase.latestSchemaVersion` when taken, for diagnostics.
  IntColumn get appSchemaVersion => integer()();
  TextColumn get json => text()();

  @override
  List<String> get customConstraints => const [
    "CHECK (reason IN ('daily', 'preImport', 'preRestore'))",
    'CHECK (json_valid(json))',
  ];

  @override
  bool get isStrict => true;
}

/// Local backups, in their own encrypted file (`dottoday-backups.db`, same
/// key as the app database, 06 §4) so damage to one file can't take the
/// other with it.
@DriftDatabase(tables: [Backups])
class BackupDatabase extends _$BackupDatabase {
  BackupDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}
