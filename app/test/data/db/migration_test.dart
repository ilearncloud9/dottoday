import 'dart:io';

import 'package:dottoday/data/db/app_database.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// Forward-only migrations (persistence-drift). 1 → 2 (M6.2): field_seen;
// 2 → 3 (M6.5.1): actual start/end and step durations (11 B1/B2).
void main() {
  test('a version 2 file gains the B1/B2 columns and keeps its rows', () async {
    final dir = await Directory.systemTemp.createTemp('dottoday-mig3');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/db.sqlite');

    // A version 2 database: today's schema minus the five new columns.
    final v2 = AppDatabase(NativeDatabase(file));
    await v2.customStatement(
      'INSERT INTO profiles (id, tz_id, locale, settings, created_at, '
      "updated_at) VALUES ('u', 'UTC', 'en', '{}', 0, 0)",
    );
    await v2.customStatement(
      'INSERT INTO occurrences (id, user_id, title, tz_id, duration_min, '
      "created_at, updated_at) VALUES ('o1', 'u', 'Run', 'UTC', 30, 0, 0)",
    );
    await _dropSchema3Columns(v2);
    await v2.customStatement('PRAGMA user_version = 2');
    await v2.close();

    final v3 = AppDatabase(NativeDatabase(file));
    addTearDown(v3.close);
    final row = await v3.select(v3.occurrences).getSingle();
    expect(row.title, 'Run');
    expect(row.actualStartUtc, isNull);
    expect(row.durationFromSteps, isFalse);
    await v3.customStatement(
      'INSERT INTO subtasks (id, user_id, occurrence_id, title, duration_min, '
      "created_at, updated_at) VALUES ('s1', 'u', 'o1', 'Stretch', 2, 0, 0)",
    );
    await expectLater(
      v3.customStatement(
        'INSERT INTO subtasks (id, user_id, occurrence_id, title, '
        'duration_min, created_at, updated_at) '
        "VALUES ('s2', 'u', 'o1', 'x', 0, 0, 0)",
      ),
      throwsA(isA<SqliteException>()),
      reason: 'the added column keeps its CHECK',
    );
    final version = await v3.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), AppDatabase.latestSchemaVersion);
  });

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
    await _dropSchema3Columns(v1);
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

/// Today's schema minus what version 3 added, to fake an older file.
Future<void> _dropSchema3Columns(AppDatabase db) async {
  for (final (table, column) in const [
    ('occurrences', 'actual_start_utc'),
    ('occurrences', 'actual_end_utc'),
    ('occurrences', 'duration_from_steps'),
    ('series', 'duration_from_steps'),
    ('subtasks', 'duration_min'),
  ]) {
    await db.customStatement('ALTER TABLE $table DROP COLUMN $column');
  }
}
