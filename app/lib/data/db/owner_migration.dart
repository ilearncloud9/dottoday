import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/owner_meta.dart';
import 'package:drift/drift.dart';

// The upgrades that give local rows an owner (CR-160): schema 18 (outbox,
// pull cursors, which profile is which) and 22 (Wake Up days). Moved out of
// app_database.dart unchanged.

/// Rebuilds `change_log` to the current definition, rows kept. Before
/// schema 18 it had no `owner_id`: a device then held one profile (the
/// sign-in re-keyed it), so every pending change is that profile's.
Future<void> rebuildChangeLog(AppDatabase db, Migrator m) async {
  final changeLog = db.changeLog;
  if (await hasColumn(db, changeLog, changeLog.ownerId)) {
    await m.alterTable(TableMigration(changeLog));
    return;
  }
  await m.alterTable(
    TableMigration(
      changeLog,
      newColumns: [changeLog.ownerId],
      columnTransformer: {
        changeLog.ownerId: const CustomExpression<String>(
          '(SELECT id FROM profiles ORDER BY created_at LIMIT 1)',
        ),
      },
    ),
  );
}

/// Gives the pull cursors their owner (18): the account the device
/// synced with. Without one there was never a pull, so none is kept.
Future<void> ownCursors(AppDatabase db, Migrator m) async {
  final syncCursors = db.syncCursors;
  if (await hasColumn(db, syncCursors, syncCursors.ownerId)) return;
  await db.customStatement(
    'DELETE FROM sync_cursors WHERE NOT EXISTS '
    "(SELECT 1 FROM local_meta WHERE key = '$legacySyncAccountKey')",
  );
  await m.alterTable(
    TableMigration(
      syncCursors,
      newColumns: [syncCursors.ownerId],
      columnTransformer: {
        syncCursors.ownerId: const CustomExpression<String>(
          "(SELECT value FROM local_meta WHERE key = '$legacySyncAccountKey')",
        ),
      },
    ),
  );
}

/// The profile the device synced with is an account; the oldest profile
/// (the only one before 18) is the one shown (18). Not marked dirty.
Future<void> recordOwners(AppDatabase db) async {
  await db.customStatement(
    'INSERT OR IGNORE INTO local_meta (key, value) '
    "SELECT '${accountMarkerKey('')}' || p.id, '1' FROM profiles p "
    "JOIN local_meta s ON s.key = '$legacySyncAccountKey' AND s.value = p.id",
  );
  await db.customStatement(
    'INSERT OR IGNORE INTO local_meta (key, value) '
    "SELECT '$activeOwnerKey', id FROM profiles ORDER BY created_at LIMIT 1",
  );
  await db.customStatement(
    "DELETE FROM local_meta WHERE key = '$legacySyncAccountKey'",
  );
}

/// Schema 22 (CR-160 Wake Up audit): `wake_up_days` gets its owner. A
/// device with one profile gives it its rows; with several, no one can say
/// whose mornings they were, so they go to '' and no one sees them. Rows are
/// times and counts only; nothing else is lost.
Future<void> ownWakeUpDays(AppDatabase db, Migrator m) async {
  final t = db.wakeUpDaysTable;
  final columns = await db
      .customSelect('PRAGMA table_info(wake_up_days)')
      .get();
  if (columns.any((c) => c.read<String>('name') == t.ownerId.name)) return;
  await m.alterTable(
    TableMigration(
      t,
      newColumns: [t.ownerId],
      columnTransformer: {
        t.ownerId: const CustomExpression<String>(
          '(CASE WHEN (SELECT count(*) FROM profiles) = 1 '
          "THEN (SELECT id FROM profiles) ELSE '' END)",
        ),
      },
    ),
  );
}

/// Whether [table] already has [column] (an upgrade run twice, or a
/// database an earlier build half-upgraded).
Future<bool> hasColumn(
  AppDatabase db,
  TableInfo<Table, Object?> table,
  GeneratedColumn<Object> column,
) async {
  final info = await db
      .customSelect(
        'SELECT name FROM pragma_table_info(?)',
        variables: [Variable.withString(table.actualTableName)],
      )
      .get();
  return info.any((r) => r.read<String>('name') == column.name);
}
