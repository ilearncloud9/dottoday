import 'package:dottoday/data/backup/backup_database.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// CR-160 I2: schema 1 -> 2 gives every backup its owner where the content
// proves it ($.profile.id), and leaves the rest ownerless (nobody's).

const _v1 = '''
CREATE TABLE backups (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  created_at INTEGER NOT NULL,
  reason TEXT NOT NULL,
  app_schema_version INTEGER NOT NULL,
  json TEXT NOT NULL,
  CHECK (reason IN ('daily', 'preImport', 'preRestore')),
  CHECK (json_valid(json))
) STRICT;
''';

void main() {
  test('schema 1 backups get their owner from their profile row', () async {
    final db = BackupDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw
            ..execute(_v1)
            ..execute(
              'INSERT INTO backups (created_at, reason, app_schema_version, '
              "json) VALUES (1, 'daily', 17, '{\"profile\":{\"id\":\"p-1\"}}'), "
              "(2, 'daily', 17, '{\"version\":1}')",
            )
            ..userVersion = 1;
        },
      ),
    );
    addTearDown(db.close);

    final rows = await (db.select(
      db.backups,
    )..orderBy([(b) => OrderingTerm(expression: b.id)])).get();
    expect(rows.map((r) => r.owner), ['p-1', null]);

    final index = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name = 'backups_owner_reason_created'",
        )
        .get();
    expect(index, hasLength(1));

    // Removal works on migrated rows and leaves the ownerless one alone.
    await db.deleteBackupsOf('p-1');
    expect(await db.select(db.backups).get(), hasLength(1));
  });

  test('a fresh database is created at schema 2 with the index', () async {
    final db = BackupDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    expect(db.schemaVersion, 2);
    final index = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name = 'backups_owner_reason_created'",
        )
        .get();
    expect(index, hasLength(1));
  });
}
