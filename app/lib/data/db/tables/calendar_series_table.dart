import 'package:dottoday/data/db/tables/calendar_tables.dart';
import 'package:dottoday/data/db/tables/columns.dart';
import 'package:dottoday/data/db/tables/profiles.dart';
import 'package:drift/drift.dart';

/// What the person set for a repeating calendar event's every instance
/// (docs/05 `calendar_series`, docs/02 F5.7). Local only, schema 13: like
/// `calendar_links`, never pushed, so no sync columns and no server table.
@DataClassName('CalendarSeriesRow')
class CalendarSeriesTable extends Table with TimestampColumns {
  @override
  String get tableName => 'calendar_series';

  TextColumn get id => text()();
  TextColumn get userId => text().references(
    Profiles,
    #id,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();
  TextColumn get accountId =>
      text().references(CalendarAccounts, #id, onDelete: KeyAction.cascade)();
  TextColumn get seriesKey => text()();
  TextColumn get title => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get colorKey => text().nullable()();
  TextColumn get iconKey => text().nullable()();
  IntColumn get durationMin => integer().nullable()();
  IntColumn get startMinute => integer().nullable()();
  TextColumn get tzId => text().nullable()();
  BoolColumn get pinned => boolean().nullable()();
  IntColumn get travelBufferMin => integer().nullable()();
  IntColumn get energy => integer().nullable()();
  TextColumn get alerts => text().nullable()();
  TextColumn get soundId => text().nullable().check(soundIdCheck)();
  TextColumn get subtaskTemplate => text().nullable()();
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    'UNIQUE (user_id, account_id, series_key)',
    'CHECK (length(series_key) <= 512)',
    'CHECK (title IS NULL OR length(title) BETWEEN 1 AND 200)',
    'CHECK (notes IS NULL OR length(notes) <= 10000)',
    'CHECK (duration_min IS NULL OR duration_min BETWEEN 5 AND 1440)',
    'CHECK (start_minute IS NULL OR start_minute BETWEEN 0 AND 1439)',
    'CHECK (travel_buffer_min IS NULL OR travel_buffer_min BETWEEN 0 AND 180)',
    'CHECK (energy IS NULL OR energy BETWEEN 1 AND 3)',
    'CHECK (alerts IS NULL OR (json_valid(alerts) '
        'AND json_array_length(alerts) <= 5))',
    'CHECK (subtask_template IS NULL OR (json_valid(subtask_template) '
        'AND json_array_length(subtask_template) <= 50))',
  ];

  @override
  bool get isStrict => true;
}
