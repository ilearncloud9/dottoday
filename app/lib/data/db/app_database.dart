import 'package:dottoday/data/db/tables/calendar_tables.dart';
// The generated part copies `soundIdCheck` (a column CHECK) verbatim.
import 'package:dottoday/data/db/tables/columns.dart';
import 'package:dottoday/data/db/tables/occurrences.dart';
import 'package:dottoday/data/db/tables/profiles.dart';
import 'package:dottoday/data/db/tables/reveal_hints_table.dart';
import 'package:dottoday/data/db/tables/routines_table.dart';
import 'package:dottoday/data/db/tables/series_table.dart';
import 'package:dottoday/data/db/tables/sync_tables.dart';
import 'package:dottoday/data/db/tables/wake_up_days_table.dart';
import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// The local source of truth (docs/04 §4): server tables mirrored with sync
/// columns, plus the local-only `change_log`, `sync_cursors`, `field_seen`,
/// `local_meta` and `wake_up_days`.
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
    RoutinesTable,
    RevealHintsTable,
    Conflicts,
    ChangeLog,
    SyncCursors,
    FieldSeen,
    LocalMeta,
    WakeUpDaysTable,
  ],
  include: {'search.drift'},
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Bump with every migration step (persistence-drift: forward-only).
  static const latestSchemaVersion = 11;

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
      // 6 (M11.4): routines (11 C2), the routine-start flag, and the
      // outbox / conflicts entity CHECK that now names routines. SQLite
      // can't alter a CHECK: the two tables are rebuilt, rows kept.
      if (from < 6) {
        await _createTableOnce(m, routinesTable);
        await _addColumnOnce(m, occurrences, occurrences.routineStart);
        await m.alterTable(TableMigration(changeLog));
        await m.alterTable(TableMigration(conflicts));
      }
      // 7 (M13.2): when a step was ticked, for learned step lengths.
      if (from < 7) await _addColumnOnce(m, subtasks, subtasks.doneAt);
      // 8 (docs/12 §3): a task's reminder sound, and "system" for every
      // profile whose reminder sound was null — null meant the OS sound
      // until now and means the Dot tone from here, so no one's reminders
      // change on upgrade. Only on upgrade: a new install keeps null.
      if (from < 8) {
        await _addColumnOnce(m, seriesTable, seriesTable.soundId);
        await _addColumnOnce(m, occurrences, occurrences.soundId);
        await _keepSystemReminderSound();
      }
      // 9 (M16, docs/14 §6): minimal mode's reveal hints, the outbox /
      // conflicts CHECK that now names them (rebuilt, rows kept, as in 6),
      // and `uiLayout: "full"` for every existing profile, so nobody's
      // app changes on upgrade. Only on upgrade: a new install picks its
      // layout in onboarding step 0.
      if (from < 9) {
        await _createTableOnce(m, revealHintsTable);
        await m.alterTable(TableMigration(changeLog));
        await m.alterTable(TableMigration(conflicts));
        await _keepFullLayout();
      }
      // 10 (M17.3, docs/15 §3): this device's mornings, local only.
      if (from < 10) await _createTableOnce(m, wakeUpDaysTable);
      // 11 (M17.5, owner 2026-11-01): the Wind Down reminder's settings key
      // is windDownReminder; the value moves from bedtimeReminder.
      if (from < 11) await _moveWindDownReminder();
    },
    beforeOpen: (details) async {
      // Per-connection, never persisted: re-assert on every open. Without
      // it SQLite silently ignores every FK action declared above.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Writes `reminderSound: "system"` where it is missing or null (v8).
  /// Not marked dirty: the server's 0009 does the same to its copy.
  Future<void> _keepSystemReminderSound() => customStatement(
    "UPDATE profiles SET settings = json_set(settings, '\$.reminderSound', "
    "'system') WHERE json_extract(settings, '\$.reminderSound') IS NULL",
  );

  /// Moves `bedtimeReminder` to `windDownReminder` (v11). Not marked
  /// dirty: the server's 0011 does the same to its copy.
  Future<void> _moveWindDownReminder() => customStatement(
    'UPDATE profiles SET settings = json_remove(json_set(settings, '
    "'\$.windDownReminder', json_extract(settings, '\$.bedtimeReminder')), "
    "'\$.bedtimeReminder') "
    "WHERE json_type(settings, '\$.bedtimeReminder') IS NOT NULL",
  );

  /// Writes `uiLayout: "full"` where it is missing (v9). Not marked dirty:
  /// the server's 0010 does the same to its copy.
  Future<void> _keepFullLayout() => customStatement(
    "UPDATE profiles SET settings = json_set(settings, '\$.uiLayout', 'full') "
    "WHERE json_extract(settings, '\$.uiLayout') IS NULL",
  );

  /// Creates [table] unless it exists (see [_addColumnOnce] for why).
  Future<void> _createTableOnce(
    Migrator m,
    TableInfo<Table, Object?> table,
  ) async {
    final found = await customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      variables: [Variable.withString(table.actualTableName)],
    ).get();
    if (found.isEmpty) await m.createTable(table);
  }

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
