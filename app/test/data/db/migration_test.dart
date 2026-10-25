import 'dart:io';

import 'package:dottoday/data/db/app_database.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// Forward-only migrations (persistence-drift). 1 → 2 (M6.2): field_seen;
// 2 → 3 (M6.5.1): actual start/end and step durations (11 B1/B2);
// 3 → 4 (M7.5): calendar_links.location (R-17); 4 → 5 (M10.7):
// occurrences.move_count (Unstick, 11 B3); 5 → 6 (M11.4): routines,
// occurrences.routine_start and the outbox CHECK naming routines. Steps are idempotent, so
// a file an older build opened (user_version lowered) upgrades again (M8.5).
void main() {
  test('a version 5 file gains routines and keeps its outbox', () async {
    final dir = await Directory.systemTemp.createTemp('dottoday-mig6');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/db.sqlite');

    final v5 = AppDatabase(NativeDatabase(file));
    await v5.customStatement(
      'INSERT INTO profiles (id, tz_id, locale, settings, created_at, '
      "updated_at) VALUES ('u', 'UTC', 'en', '{}', 0, 0)",
    );
    await v5.customStatement('DROP TABLE routines');
    await v5.customStatement(
      'ALTER TABLE occurrences DROP COLUMN routine_start',
    );
    // The schema-5 outbox, whose CHECK doesn't know routines.
    await v5.customStatement('DROP TABLE change_log');
    await v5.customStatement(
      'CREATE TABLE change_log (seq INTEGER NOT NULL PRIMARY KEY '
      'AUTOINCREMENT, entity TEXT NOT NULL, entity_id TEXT NOT NULL, '
      'field TEXT NOT NULL, value TEXT NOT NULL, hlc TEXT NOT NULL, '
      "CHECK (entity IN ('series', 'occurrences', 'subtasks', 'profiles')), "
      'CHECK (length(field) <= 64), CHECK (json_valid(value))) STRICT',
    );
    await v5.customStatement(
      'INSERT INTO change_log (entity, entity_id, field, value, hlc) '
      "VALUES ('occurrences', 'o1', 'title', '\"Do taxes\"', 'h1')",
    );
    await v5.customStatement('PRAGMA user_version = 5');
    await v5.close();

    final v6 = AppDatabase(NativeDatabase(file));
    addTearDown(v6.close);
    final kept = await v6.select(v6.changeLog).getSingle();
    expect((kept.entityId, kept.hlc), ('o1', 'h1'));
    await v6.customStatement(
      'INSERT INTO change_log (entity, entity_id, field, value, hlc) '
      "VALUES ('routines', 'r1', 'title', '\"Morning\"', 'h2')",
    );
    await v6.customStatement(
      'INSERT INTO routines (id, user_id, title, created_at, updated_at) '
      "VALUES ('r1', 'u', 'Morning', 0, 0)",
    );
    expect(await v6.select(v6.routinesTable).get(), hasLength(1));
    final version = await v6.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), AppDatabase.latestSchemaVersion);
  });

  test('a version 4 file gains the move count at 0 and keeps its rows', () async {
    final dir = await Directory.systemTemp.createTemp('dottoday-mig5');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/db.sqlite');

    final v4 = AppDatabase(NativeDatabase(file));
    await v4.customStatement(
      'INSERT INTO profiles (id, tz_id, locale, settings, created_at, '
      "updated_at) VALUES ('u', 'UTC', 'en', '{}', 0, 0)",
    );
    await v4.customStatement('ALTER TABLE occurrences DROP COLUMN move_count');
    await v4.customStatement(
      'INSERT INTO occurrences (id, user_id, title, tz_id, duration_min, '
      "created_at, updated_at) VALUES ('o1', 'u', 'Do taxes', 'UTC', 30, 0, 0)",
    );
    await v4.customStatement('PRAGMA user_version = 4');
    await v4.close();

    final v5 = AppDatabase(NativeDatabase(file));
    addTearDown(v5.close);
    final row = await v5.select(v5.occurrences).getSingle();
    expect((row.title, row.moveCount), ('Do taxes', 0));
    final version = await v5.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), AppDatabase.latestSchemaVersion);
  });

  test('a version 3 file gains the link place and keeps its rows', () async {
    final dir = await Directory.systemTemp.createTemp('dottoday-mig4');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/db.sqlite');

    final v3 = AppDatabase(NativeDatabase(file));
    await v3.customStatement(
      'INSERT INTO profiles (id, tz_id, locale, settings, created_at, '
      "updated_at) VALUES ('u', 'UTC', 'en', '{}', 0, 0)",
    );
    await v3.customStatement(
      'INSERT INTO calendar_accounts (id, user_id, provider, label, '
      "created_at, updated_at) VALUES ('a', 'u', 'apple_device', 'Work', 0, 0)",
    );
    await v3.customStatement(
      'INSERT INTO calendar_links (id, user_id, account_id, '
      'external_calendar_id, external_event_id) '
      "VALUES ('l1', 'u', 'a', 'work', 'E1@0')",
    );
    await _dropSchema4Columns(v3);
    await v3.customStatement('PRAGMA user_version = 3');
    await v3.close();

    final v4 = AppDatabase(NativeDatabase(file));
    addTearDown(v4.close);
    final row = await v4.select(v4.calendarLinks).getSingle();
    expect(row.externalEventId, 'E1@0');
    expect(row.location, isNull);
    await v4.customStatement(
      "UPDATE calendar_links SET location = 'Main St 4' WHERE id = 'l1'",
    );
    await expectLater(
      v4.customStatement(
        "UPDATE calendar_links SET location = '${'x' * 201}' WHERE id = 'l1'",
      ),
      throwsA(isA<SqliteException>()),
      reason: 'the added column keeps its CHECK',
    );
    final version = await v4.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), AppDatabase.latestSchemaVersion);
  });

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
    await _dropSchema4Columns(v2);
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

  // An older build opened the file (TestFlight lets testers pick one):
  // drift lowered user_version but the newer columns stayed. The next
  // upgrade must open it, not stop at "duplicate column" (found in M8.5).
  test('a file an older build opened upgrades again', () async {
    final dir = await Directory.systemTemp.createTemp('dottoday-downgrade');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/db.sqlite');

    final latest = AppDatabase(NativeDatabase(file));
    await latest.customStatement(
      'INSERT INTO profiles (id, tz_id, locale, settings, created_at, '
      "updated_at) VALUES ('u', 'UTC', 'en', '{}', 0, 0)",
    );
    await latest.customStatement(
      'INSERT INTO occurrences (id, user_id, title, tz_id, duration_min, '
      "created_at, updated_at) VALUES ('o1', 'u', 'Run', 'UTC', 30, 0, 0)",
    );
    await latest.customStatement('PRAGMA user_version = 2');
    await latest.close();

    final again = AppDatabase(NativeDatabase(file));
    addTearDown(again.close);
    final row = await again.select(again.occurrences).getSingle();
    expect(row.title, 'Run');
    final version = await again.customSelect('PRAGMA user_version').getSingle();
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
    await _dropSchema4Columns(v1);
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

/// Today's schema minus what version 4 added.
Future<void> _dropSchema4Columns(AppDatabase db) =>
    db.customStatement('ALTER TABLE calendar_links DROP COLUMN location');
