import 'package:dottoday/data/db/tables/calendar_tables.dart';
import 'package:dottoday/data/db/tables/occurrences.dart';
import 'package:dottoday/data/db/tables/profiles.dart';
import 'package:dottoday/data/db/tables/series_table.dart';
import 'package:dottoday/data/db/tables/sync_tables.dart';
import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// The local source of truth (docs/04 §4): server tables mirrored with sync
/// columns, plus the local-only `change_log`, `sync_cursors`, `field_seen`
/// and `local_meta`.
///
/// Open it with `openAppDatabase` (connection/connection.dart) so the
/// SQLCipher key is applied before any statement (06 §4, ADR-0006).
@DriftDatabase(
  tables: [
    Profiles,
    SeriesTable,
    CalendarAccounts,
    CalendarLinks,
    Occurrences,
    Subtasks,
    Conflicts,
    ChangeLog,
    SyncCursors,
    FieldSeen,
    LocalMeta,
  ],
  include: {'search.drift'},
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Bump with every migration step (persistence-drift: forward-only).
  static const latestSchemaVersion = 5;

  @override
  int get schemaVersion => latestSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // 2 (M6.2): the server versions last pulled, for conflict checks.
      if (from < 2) await m.createTable(fieldSeen);
      // 3 (M6.5.1): actual start/end and step durations (11 B1/B2).
      if (from < 3) {
        await _addColumnOnce(m, occurrences, occurrences.actualStartUtc);
        await _addColumnOnce(m, occurrences, occurrences.actualEndUtc);
        await _addColumnOnce(m, occurrences, occurrences.durationFromSteps);
        await _addColumnOnce(m, seriesTable, seriesTable.durationFromSteps);
        await _addColumnOnce(m, subtasks, subtasks.durationMin);
      }
      // 4 (M7.5): an imported event's place, for travel time (R-17).
      if (from < 4) {
        await _addColumnOnce(m, calendarLinks, calendarLinks.location);
      }
      // 5 (M10.7): how often a task was moved, for Unstick (11 B3).
      if (from < 5) {
        await _addColumnOnce(m, occurrences, occurrences.moveCount);
      }
    },
    beforeOpen: (details) async {
      // Per-connection, never persisted: re-assert on every open. Without
      // it SQLite silently ignores every FK action declared above.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Adds [column] unless [table] already has it. Opening a file with an
  /// older build lowers `user_version` but keeps the newer columns (drift
  /// runs no down-steps), so the next upgrade would stop at "duplicate
  /// column" and the app couldn't open its data. TestFlight lets testers
  /// install an older build; found on the Mac in M8.5 (08 §4).
  Future<void> _addColumnOnce(
    Migrator m,
    TableInfo<Table, Object?> table,
    GeneratedColumn<Object> column,
  ) async {
    final info = await customSelect(
      'SELECT name FROM pragma_table_info(?)',
      variables: [Variable.withString(table.actualTableName)],
    ).get();
    if (info.any((r) => r.read<String>('name') == column.name)) return;
    await m.addColumn(table, column);
  }
}
