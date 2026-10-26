import 'package:dottoday/data/db/tables/calendar_tables.dart';
import 'package:dottoday/data/db/tables/columns.dart';
import 'package:dottoday/data/db/tables/profiles.dart';
import 'package:dottoday/data/db/tables/series_table.dart';
import 'package:drift/drift.dart';

/// Timeline blocks and inbox items (docs/05 `occurrences`).
@DataClassName('OccurrenceRow')
@TableIndex(name: 'occurrences_user_start', columns: {#userId, #startUtc})
@TableIndex(name: 'occurrences_user_updated', columns: {#userId, #updatedAt})
@TableIndex(
  name: 'occurrences_series_original',
  columns: {#userId, #seriesId, #originalStartUtc},
  unique: true,
)
@TableIndex.sql(
  'CREATE INDEX occurrences_user_deleted ON occurrences (user_id, deleted_at) '
  'WHERE deleted_at IS NOT NULL',
)
@TableIndex.sql(
  'CREATE INDEX occurrences_inbox ON occurrences (user_id, sort_order) '
  'WHERE start_utc IS NULL AND deleted_at IS NULL',
)
@TableIndex.sql(
  'CREATE INDEX occurrences_dirty ON occurrences (dirty) WHERE dirty = 1',
)
class Occurrences extends Table with TimestampColumns, SyncColumns {
  TextColumn get id => text()();
  TextColumn get userId => text().references(
    Profiles,
    #id,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();
  TextColumn get seriesId => text().nullable().references(
    SeriesTable,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get originalStartUtc => integer().nullable()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get colorKey => text().withDefault(const Constant('indigo'))();
  TextColumn get iconKey => text().withDefault(const Constant('circle'))();

  /// Null = inbox.
  IntColumn get startUtc => integer().nullable()();
  TextColumn get tzId => text()();
  IntColumn get durationMin => integer()();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  IntColumn get travelBufferMin => integer().withDefault(const Constant(0))();
  IntColumn get energy => integer().nullable()();

  /// Null inherits the series alerts; `[]` is an explicit "no alerts".
  TextColumn get alerts => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('planned'))();
  IntColumn get completedAtUtc => integer().nullable()();
  RealColumn get sortOrder => real().withDefault(const Constant(0))();
  TextColumn get source => text().withDefault(const Constant('user'))();
  TextColumn get calendarLinkId => text().nullable().references(
    CalendarLinks,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get snoozedUntilUtc => integer().nullable()();

  // Schema 3 (M6.5.1, 11 B1/B2). Added by ALTER TABLE, so no table CHECK.
  IntColumn get actualStartUtc => integer().nullable()();
  IntColumn get actualEndUtc => integer().nullable()();
  BoolColumn get durationFromSteps =>
      boolean().withDefault(const Constant(false))();

  // Schema 5 (M10.7, 11 B3): moves, for Unstick. ALTER TABLE, no CHECK.
  IntColumn get moveCount => integer().withDefault(const Constant(0))();

  // Schema 6 (M11.4, 11 C2): a routine's first step, alarm-loud (A0).
  BoolColumn get routineStart => boolean().withDefault(const Constant(false))();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    'CHECK (length(trim(title)) BETWEEN 1 AND 200)',
    'CHECK (notes IS NULL OR length(notes) <= 10000)',
    'CHECK (length(color_key) <= 24)',
    'CHECK (length(icon_key) <= 48)',
    'CHECK (length(tz_id) <= 64)',
    'CHECK (duration_min BETWEEN 5 AND 1440)',
    'CHECK (travel_buffer_min BETWEEN 0 AND 180)',
    'CHECK (energy IS NULL OR energy BETWEEN 1 AND 3)',
    'CHECK (alerts IS NULL '
        'OR (json_valid(alerts) AND json_array_length(alerts) <= 5))',
    "CHECK (status IN ('planned', 'done', 'skipped'))",
    "CHECK (source IN ('user', 'calendar'))",
    // A series instance must say which instance it is (idempotent
    // materialisation, docs/05 "Rules").
    'CHECK (series_id IS NULL OR original_start_utc IS NOT NULL)',
  ];

  @override
  bool get isStrict => true;
}

/// Per-occurrence checklist items (docs/05 `subtasks`, R-09).
@DataClassName('SubtaskRow')
@TableIndex(name: 'subtasks_occurrence', columns: {#occurrenceId})
@TableIndex(name: 'subtasks_user_updated', columns: {#userId, #updatedAt})
@TableIndex.sql(
  'CREATE INDEX subtasks_dirty ON subtasks (dirty) WHERE dirty = 1',
)
class Subtasks extends Table with TimestampColumns, SyncColumns {
  TextColumn get id => text()();
  TextColumn get userId => text().references(
    Profiles,
    #id,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();
  TextColumn get occurrenceId =>
      text().references(Occurrences, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  RealColumn get sortOrder => real().withDefault(const Constant(0))();

  /// Schema 3 (M6.5.1, 11 B2): optional step length, 1–1440 min.
  IntColumn get durationMin => integer().nullable().check(
    const CustomExpression<bool>(
      'duration_min IS NULL OR duration_min BETWEEN 1 AND 1440',
    ),
  )();

  /// Schema 7 (M13.2, ADR-0012): when it was ticked done, epoch ms.
  IntColumn get doneAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    'CHECK (length(trim(title)) BETWEEN 1 AND 200)',
  ];

  @override
  bool get isStrict => true;
}
