import 'package:dottoday/data/db/tables/profiles.dart';
import 'package:drift/drift.dart';

/// Same-field edits within 60 s awaiting "keep mine / theirs" (docs/05
/// `conflicts`, ADR-0002).
@DataClassName('ConflictRow')
@TableIndex.sql(
  'CREATE INDEX conflicts_open ON conflicts (user_id) WHERE resolved_at IS NULL',
)
class Conflicts extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(
    Profiles,
    #id,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get field => text()();

  /// JSON-encoded field values (`null` allowed).
  TextColumn get mine => text().nullable()();
  TextColumn get theirs => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get resolvedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    "CHECK (entity IN ('series', 'occurrences', 'subtasks', 'profiles'))",
    'CHECK (length(field) <= 64)',
    'CHECK (mine IS NULL OR json_valid(mine))',
    'CHECK (theirs IS NULL OR json_valid(theirs))',
  ];

  @override
  bool get isStrict => true;
}

/// Local-only outbox: one row per field written locally, pushed in [seq]
/// order via `sync_push` (docs/04 §4). Rows are deleted once acknowledged.
@DataClassName('ChangeLogRow')
@TableIndex(name: 'change_log_entity', columns: {#entity, #entityId})
class ChangeLog extends Table {
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get field => text()();

  /// JSON-encoded new value of [field].
  TextColumn get value => text()();

  /// Fixed-width HLC string (`Hlc`, ADR-0002); string order = clock order.
  TextColumn get hlc => text()();

  @override
  List<String> get customConstraints => const [
    // The `sync_push` allow-list (supabase/migrations/0002).
    "CHECK (entity IN ('series', 'occurrences', 'subtasks', 'profiles'))",
    'CHECK (length(field) <= 64)',
    'CHECK (json_valid(value))',
  ];

  @override
  bool get isStrict => true;
}

/// Local-only pull cursors: the highest server `updated_at` seen per table
/// (docs/04 §4 "periodic since pull").
@DataClassName('SyncCursorRow')
class SyncCursors extends Table {
  TextColumn get entity => text()();
  IntColumn get sinceUtc => integer()();

  @override
  Set<Column<Object>> get primaryKey => {entity};

  @override
  bool get isStrict => true;
}
