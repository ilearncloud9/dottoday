import 'dart:io';

import 'package:dottoday/data/db/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// Forward-only migrations (persistence-drift). 1 → 2 (M6.2): field_seen.
void main() {
  test('a version 1 file gains field_seen and keeps its rows', () async {
    final dir = await Directory.systemTemp.createTemp('dottoday-mig');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/db.sqlite');

    // A version 1 database: today's schema minus the new table.
    final v1 = AppDatabase(NativeDatabase(file));
    await v1.customInsert(
      'INSERT INTO local_meta (key, value) VALUES (?, ?)',
      variables: [const Variable('probe'), const Variable('kept')],
    );
    await v1.customStatement('DROP TABLE field_seen');
    await v1.customStatement('PRAGMA user_version = 1');
    await v1.close();

    final v2 = AppDatabase(NativeDatabase(file));
    addTearDown(v2.close);
    await v2
        .into(v2.fieldSeen)
        .insert(
          FieldSeenCompanion.insert(
            entity: 'occurrences',
            entityId: 'o1',
            field: 'title',
            hlc: '1761033600000-0000-00000000000000aa',
          ),
        );
    expect(await v2.select(v2.fieldSeen).get(), hasLength(1));
    final probe = await v2
        .customSelect("SELECT value FROM local_meta WHERE key = 'probe'")
        .getSingle();
    expect(probe.read<String>('value'), 'kept');
    final version = await v2.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), AppDatabase.latestSchemaVersion);
  });
}
