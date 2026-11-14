import 'package:drift/drift.dart';

// Staged import (CR-160 Stage B2, schema 21, docs/cr-160-multipart-export.md
// §5–§6, ADR-0019 D4). Local only: never in the outbox, never synced, never
// read by a repository or DAO; only `data/backup/staged_import_store.dart`
// touches these tables (policy-tested). They live in the encrypted main
// database, so staged rows are encrypted at rest like every other row.
//
// Neither table references `profiles`: re-keying a profile (a guest's work
// moving into an account) cascades `user_id` everywhere else, and an
// import's owner must never move with it. A staged import belongs to the
// owner session it began in; any owner change refuses it (owner generation)
// and account removal deletes it explicitly.

/// One import in progress: whose it is and in which owner session.
@DataClassName('ImportSessionRow')
class ImportSessions extends Table {
  TextColumn get importId => text()();
  TextColumn get owner => text()();

  /// `owner_generation` when it began: A → B → A refuses it.
  IntColumn get ownerGeneration => integer()();

  /// The app run that began it: a later run never continues it.
  TextColumn get runId => text()();
  IntColumn get startedAt => integer()();

  /// The size the import says it is; staging never grows past it.
  IntColumn get declaredBytes => integer()();
  IntColumn get stagedBytes => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {importId};

  @override
  List<String> get customConstraints => const [
    // One import per owner at a time.
    'UNIQUE (owner)',
    // The target of import_staging's (import_id, owner) reference.
    'UNIQUE (import_id, owner)',
    'CHECK (length(import_id) = 36)',
    'CHECK (length(owner) BETWEEN 1 AND 64)',
    'CHECK (declared_bytes >= 0)',
    'CHECK (staged_bytes BETWEEN 0 AND declared_bytes)',
  ];

  @override
  bool get isStrict => true;
}

/// One staged row, in v1's storage form, keyed by its import and owner.
@DataClassName('ImportStagingRow')
class ImportStaging extends Table {
  TextColumn get importId => text()();
  TextColumn get owner => text()();

  /// `profile` or a part table name (multipart_format.dart `partTables`).
  TextColumn get entity => text()();
  TextColumn get rowId => text()();
  IntColumn get partIndex => integer()();
  TextColumn get json => text()();

  /// Ids are unique per table across the whole import.
  @override
  Set<Column<Object>> get primaryKey => {importId, entity, rowId};

  @override
  List<String> get customConstraints => const [
    // The row's owner is its session's owner, and goes with it.
    'FOREIGN KEY (import_id, owner) REFERENCES import_sessions '
        '(import_id, owner) ON DELETE CASCADE ON UPDATE RESTRICT',
    "CHECK (entity IN ('profile', 'series', 'occurrences', 'subtasks', "
        "'routines', 'calendarSeries'))",
    'CHECK (length(row_id) BETWEEN 1 AND 64)',
    'CHECK (part_index >= 1)',
    'CHECK (json_valid(json))',
  ];

  @override
  bool get isStrict => true;
}
