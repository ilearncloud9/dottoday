import 'dart:io';

import 'package:dottoday/data/db/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// A file main's build took to 18 had the devices cache (ED-084) but none of
// CR-160's steps, which now hold 18–22. Its outbox must still get owners.

void main() {
  test('a main-18 file still gains change_log.owner_id', () async {
    final dir = await Directory.systemTemp.createTemp('dottoday-main18');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/db.sqlite');
    final first = AppDatabase(NativeDatabase(file));
    await first.customStatement(
      'INSERT INTO profiles (id, tz_id, locale, settings, created_at, '
      "updated_at) VALUES ('p1', 'UTC', 'en', '{}', 0, 0)",
    );
    // change_log as before CR-160: no owner_id.
    await first.customStatement('DROP TABLE change_log');
    await first.customStatement(
      'CREATE TABLE change_log (seq INTEGER PRIMARY KEY AUTOINCREMENT, '
      'entity TEXT NOT NULL, entity_id TEXT NOT NULL, field TEXT NOT NULL, '
      'value TEXT NOT NULL, hlc TEXT NOT NULL) STRICT',
    );
    await first.customStatement(
      'INSERT INTO change_log (entity, entity_id, field, value, hlc) '
      "VALUES ('series', 's1', 'title', '\"x\"', 'h1')",
    );
    await first.customStatement('PRAGMA user_version = 18');
    await first.close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    final cols = await db.customSelect('PRAGMA table_info(change_log)').get();
    expect(cols.map((c) => c.read<String>('name')), contains('owner_id'));
    expect((await db.select(db.changeLog).getSingle()).ownerId, 'p1');
    expect(await db.select(db.devicesTable).get(), isEmpty);
  });
}
