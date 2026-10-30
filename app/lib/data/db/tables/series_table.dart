import 'package:dottoday/data/db/tables/columns.dart';
import 'package:dottoday/data/db/tables/profiles.dart';
import 'package:drift/drift.dart';

/// Recurring task templates (docs/05 `series`, ADR-0004).
@DataClassName('SeriesRow')
@TableIndex(name: 'series_user', columns: {#userId})
@TableIndex(name: 'series_user_updated', columns: {#userId, #updatedAt})
@TableIndex.sql('CREATE INDEX series_dirty ON series (dirty) WHERE dirty = 1')
class SeriesTable extends Table with TimestampColumns, SyncColumns {
  @override
  String get tableName => 'series';

  TextColumn get id => text()();
  TextColumn get userId => text().references(
    Profiles,
    #id,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get colorKey => text().withDefault(const Constant('indigo'))();
  TextColumn get iconKey => text().withDefault(const Constant('circle'))();
  IntColumn get durationMin => integer()();
  TextColumn get rrule => text()();

  /// ISO-8601 wall clock without offset, read in [tzId] (R-01).
  TextColumn get dtstartLocal => text()();
  TextColumn get tzId => text()();
  IntColumn get untilUtc => integer().nullable()();
  IntColumn get count => integer().nullable()();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  IntColumn get travelBufferMin => integer().withDefault(const Constant(0))();

  /// Schema 3 (M6.5.1, 11 B2).
  BoolColumn get durationFromSteps =>
      boolean().withDefault(const Constant(false))();
  IntColumn get energy => integer().nullable()();
  TextColumn get alerts => text().withDefault(const Constant('[]'))();

  /// The reminder sound (docs/12 §3); column-level CHECK so the v8
  /// migration's ADD COLUMN carries it (a table CHECK needs a rebuild).
  TextColumn get soundId => text().nullable().check(soundIdCheck)();
  TextColumn get subtaskTemplate => text().withDefault(const Constant('[]'))();
  IntColumn get materialisedThroughUtc => integer().nullable()();
  IntColumn get archivedAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  // Mirrors the server checks in supabase/migrations/0001_init.sql.
  @override
  List<String> get customConstraints => const [
    'CHECK (length(trim(title)) BETWEEN 1 AND 200)',
    'CHECK (notes IS NULL OR length(notes) <= 10000)',
    'CHECK (length(color_key) <= 24)',
    'CHECK (length(icon_key) <= 48)',
    'CHECK (duration_min BETWEEN 5 AND 1440)',
    "CHECK (rrule LIKE 'FREQ=%' AND length(rrule) <= 512)",
    'CHECK (length(tz_id) <= 64)',
    'CHECK (count IS NULL OR count BETWEEN 1 AND 10000)',
    'CHECK (travel_buffer_min BETWEEN 0 AND 180)',
    'CHECK (energy IS NULL OR energy BETWEEN 1 AND 3)',
    'CHECK (json_valid(alerts) AND json_array_length(alerts) <= 5)',
    'CHECK (json_valid(subtask_template) '
        'AND json_array_length(subtask_template) <= 50)',
  ];

  @override
  bool get isStrict => true;
}
