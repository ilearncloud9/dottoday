import 'package:dottoday/data/db/tables/calendar_tables.dart';
import 'package:dottoday/data/db/tables/occurrences.dart';
import 'package:dottoday/data/db/tables/profiles.dart';
import 'package:dottoday/data/db/tables/series_table.dart';
import 'package:dottoday/data/db/tables/sync_tables.dart';
import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// The local source of truth (docs/04 §4): server tables mirrored with sync
/// columns, plus the local-only `change_log`, `sync_cursors` and `local_meta`.
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
    LocalMeta,
  ],
  include: {'search.drift'},
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Bump with every migration step (persistence-drift: forward-only).
  static const latestSchemaVersion = 1;

  @override
  int get schemaVersion => latestSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      // Per-connection, never persisted: re-assert on every open. Without
      // it SQLite silently ignores every FK action declared above.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
