import 'package:dottoday/data/db/tables/columns.dart';
import 'package:dottoday/data/db/tables/profiles.dart';
import 'package:drift/drift.dart';

/// Saved slices of thread (docs/05 `routines`, 11 C2). Schema 6 (M11.4).
@DataClassName('RoutineRow')
@TableIndex(name: 'routines_user', columns: {#userId})
@TableIndex(name: 'routines_user_updated', columns: {#userId, #updatedAt})
@TableIndex.sql(
  'CREATE INDEX routines_dirty ON routines (dirty) WHERE dirty = 1',
)
class RoutinesTable extends Table with TimestampColumns, SyncColumns {
  @override
  String get tableName => 'routines';

  TextColumn get id => text()();
  TextColumn get userId => text().references(
    Profiles,
    #id,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();
  TextColumn get title => text()();
  TextColumn get anchor => text().withDefault(const Constant('wake'))();
  IntColumn get anchorMinute => integer().nullable()();

  /// JSON array of steps (camelCase keys, as `series.subtask_template`).
  TextColumn get items => text().withDefault(const Constant('[]'))();
  RealColumn get sortOrder => real().withDefault(const Constant(0))();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  // Mirrors the server checks in supabase/migrations/0007_routines.sql.
  @override
  List<String> get customConstraints => const [
    'CHECK (length(trim(title)) BETWEEN 1 AND 200)',
    "CHECK (anchor IN ('wake', 'bed', 'time'))",
    'CHECK (anchor_minute IS NULL OR anchor_minute BETWEEN 0 AND 1439)',
    "CHECK (json_valid(items) AND json_type(items) = 'array' "
        'AND json_array_length(items) <= 30)',
  ];

  @override
  bool get isStrict => true;
}
