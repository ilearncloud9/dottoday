import 'dart:io';

import 'package:dottoday/data/db/app_database.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// Forward-only migrations (persistence-drift). 1 → 2 (M6.2): field_seen;
// 2 → 3 (M6.5.1): actual start/end and step durations (11 B1/B2);
// 3 → 4 (M7.5): calendar_links.location (R-17); 4 → 5 (M10.7):
// occurrences.move_count (Unstick, 11 B3); 5 → 6 (M11.4): routines,
// occurrences.routine_start and the outbox CHECK naming routines; 6 → 7
// (M13.2, ADR-0012): subtasks.done_at; 7 → 8 (docs/12 §3): sound_id on
// series and occurrences, and "system" for every null reminder sound;
// 8 → 9 (M16, docs/14 §6): reveal_hints, the outbox CHECK naming them, and
// `uiLayout: "full"` for every existing profile; 9 → 10 (M17.3, docs/15
// §3): the local wake_up_days; 10 → 11 (M17.5): the Wind Down reminder's
// settings key moves from bedtimeReminder to windDownReminder; 11 → 12
// (docs/02 F5.7): calendar_links.series_key.
// Steps are idempotent, so a file an older build opened (user_version
// lowered) upgrades again (M8.5).
void main() {
  test('a version 11 file gains the link series key, rows kept', () async {
    final dir = await Directory.systemTemp.createTemp('dottoday-mig12');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/db.sqlite');

    final v11 = AppDatabase(NativeDatabase(file));
    await v11.customStatement(
      'INSERT INTO profiles (id, tz_id, locale, settings, created_at, '
      "updated_at) VALUES ('u', 'UTC', 'en', '{}', 0, 0)",
    );
    await v11.customStatement(
      'INSERT INTO calendar_accounts (id, user_id, provider, label, '
      "created_at, updated_at) VALUES ('a', 'u', 'apple_device', 'Work', 0, 0)",
    );
    await v11.customStatement(
      'INSERT INTO calendar_links (id, user_id, account_id, '
      'external_calendar_id, external_event_id) '
      "VALUES ('l1', 'u', 'a', 'work', 'E1@0')",
    );
    await v11.customStatement(
      'ALTER TABLE calendar_links DROP COLUMN series_key',
    );
    await v11.customStatement('PRAGMA user_version = 11');
    await v11.close();

    final v12 = AppDatabase(NativeDatabase(file));
    addTearDown(v12.close);
    final row = await v12.select(v12.calendarLinks).getSingle();
    expect(row.externalEventId, 'E1@0');
    expect(row.seriesKey, isNull);
    await expectLater(
      v12.customStatement(
        "UPDATE calendar_links SET series_key = '${'x' * 513}' WHERE id = 'l1'",
      ),
      throwsA(isA<SqliteException>()),
      reason: 'the added column keeps its CHECK',
    );
  });

  test('a version 10 file moves bedtimeReminder to windDownReminder', () async {
    final dir = await Directory.systemTemp.createTemp('dottoday-mig11');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/db.sqlite');

    final v10 = AppDatabase(NativeDatabase(file));
    for (final (id, settings) in [
      ('off', '{"bedtimeReminder":false,"snapMinutes":10}'),
      ('on', '{"bedtimeReminder":true}'),
      ('unset', '{"snapMinutes":5}'),
    ]) {
      await v10.customStatement(
        'INSERT INTO profiles (id, tz_id, locale, settings, created_at, '
        "updated_at) VALUES ('$id', 'UTC', 'en', '$settings', 0, 0)",
      );
    }
    await v10.customStatement('PRAGMA user_version = 10');
    await v10.close();

    final v11 = AppDatabase(NativeDatabase(file));
    addTearDown(v11.close);
    Future<Map<String, Object?>> settings(String id) async =>
        (await v11
                .customSelect(
                  "SELECT json_extract(settings, '\$.windDownReminder') AS w, "
                  "json_type(settings, '\$.bedtimeReminder') AS b, "
                  "json_extract(settings, '\$.snapMinutes') AS s "
                  'FROM profiles WHERE id = ?',
                  variables: [Variable.withString(id)],
                )
                .getSingle())
            .data;
    expect(await settings('off'), {'w': 0, 'b': null, 's': 10});
    expect(await settings('on'), {'w': 1, 'b': null, 's': null});
    expect(await settings('unset'), {'w': null, 'b': null, 's': 5});
  });

  test('a version 9 file gains wake_up_days and keeps its rows', () async {
    final dir = await Directory.systemTemp.createTemp('dottoday-mig10');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/db.sqlite');

    final v9 = AppDatabase(NativeDatabase(file));
    await v9.customStatement(
      'INSERT INTO profiles (id, tz_id, locale, settings, created_at, '
      "updated_at) VALUES ('p1', 'UTC', 'en', '{}', 0, 0)",
    );
    await v9.customStatement('DROP TABLE wake_up_days');
    await v9.customStatement('PRAGMA user_version = 9');
    await v9.close();

    final v10 = AppDatabase(NativeDatabase(file));
    addTearDown(v10.close);
    expect(await v10.select(v10.profiles).get(), hasLength(1));
    await v10.customStatement(
      "INSERT INTO wake_up_days (date, snoozes) VALUES ('2026-11-02', 1)",
    );
    expect(await v10.select(v10.wakeUpDaysTable).get(), hasLength(1));
    // Its CHECKs: a civil date, never a negative count.
    await expectLater(
      v10.customStatement("INSERT INTO wake_up_days (date) VALUES ('soon')"),
      throwsA(isA<SqliteException>()),
    );
    final version = (await v10.customSelect('PRAGMA user_version').getSingle());
    expect(version.read<int>('user_version'), AppDatabase.latestSchemaVersion);
  });

  test(
    'a version 8 file keeps the full layout and gains reveal hints',
    () async {
      final dir = await Directory.systemTemp.createTemp('dottoday-mig9');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/db.sqlite');

      final v8 = AppDatabase(NativeDatabase(file));
      for (final (id, settings) in [
        ('missing', '{"snapMinutes":10}'),
        ('chosen', '{"uiLayout":"minimal"}'),
      ]) {
        await v8.customStatement(
          'INSERT INTO profiles (id, tz_id, locale, settings, created_at, '
          "updated_at) VALUES ('$id', 'UTC', 'en', '$settings', 0, 0)",
        );
      }
      await v8.customStatement(
        'INSERT INTO change_log (entity, entity_id, field, value, hlc) '
        "VALUES ('routines', 'r1', 'title', '\"Morning\"', 'h1')",
      );
      await v8.customStatement('DROP TABLE reveal_hints');
      await v8.customStatement('PRAGMA user_version = 8');
      await v8.close();

      final v9 = AppDatabase(NativeDatabase(file));
      addTearDown(v9.close);
      Future<Object?> layout(String id) async =>
          (await v9
                  .customSelect(
                    "SELECT json_extract(settings, '\$.uiLayout') AS l "
                    'FROM profiles WHERE id = ?',
                    variables: [Variable.withString(id)],
                  )
                  .getSingle())
              .data['l'];
      // Nobody's app changes on upgrade (docs/14 §6).
      expect(await layout('missing'), 'full');
      expect(await layout('chosen'), 'minimal', reason: 'a choice is kept');
      expect(await v9.select(v9.changeLog).get(), hasLength(1));
      await v9.customStatement(
        'INSERT INTO reveal_hints (id, user_id, hint_id, created_at, '
        "updated_at) VALUES ('h1', 'missing', 'unstick', 0, 0)",
      );
      await v9.customStatement(
        'INSERT INTO change_log (entity, entity_id, field, value, hlc) '
        "VALUES ('reveal_hints', 'h1', 'shown_count', '1', 'h2')",
      );
      expect(await v9.select(v9.revealHintsTable).get(), hasLength(1));
    },
  );

  test('a version 7 file gains task sounds and keeps the OS sound', () async {
    final dir = await Directory.systemTemp.createTemp('dottoday-mig8');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/db.sqlite');

    final v7 = AppDatabase(NativeDatabase(file));
    for (final (id, settings) in [
      ('missing', '{}'),
      ('null', '{"reminderSound":null,"snapMinutes":10}'),
      ('chosen', '{"reminderSound":"bell"}'),
    ]) {
      await v7.customStatement(
        'INSERT INTO profiles (id, tz_id, locale, settings, created_at, '
        "updated_at) VALUES ('$id', 'UTC', 'en', '$settings', 0, 0)",
      );
    }
    await v7.customStatement('ALTER TABLE occurrences DROP COLUMN sound_id');
    await v7.customStatement('ALTER TABLE series DROP COLUMN sound_id');
    await v7.customStatement(
      'INSERT INTO occurrences (id, user_id, title, tz_id, duration_min, '
      "created_at, updated_at) VALUES ('o1', 'chosen', 'Run', 'UTC', 30, 0, 0)",
    );
    await v7.customStatement('PRAGMA user_version = 7');
    await v7.close();

    final v8 = AppDatabase(NativeDatabase(file));
    addTearDown(v8.close);
    final row = await v8.select(v8.occurrences).getSingle();
    expect((row.title, row.soundId), ('Run', null), reason: 'inherits');
    Future<Object?> sound(String id) async =>
        (await v8
                .customSelect(
                  "SELECT json_extract(settings, '\$.reminderSound') AS s "
                  'FROM profiles WHERE id = ?',
                  variables: [Variable.withString(id)],
                )
                .getSingle())
            .data['s'];
    // Null meant the OS sound; it still does, now said out loud.
    expect(await sound('missing'), 'system');
    expect(await sound('null'), 'system');
    expect(await sound('chosen'), 'bell', reason: 'a choice is kept');
    final other = await v8
        .customSelect(
          "SELECT json_extract(settings, '\$.snapMinutes') AS v "
          "FROM profiles WHERE id = 'null'",
        )
        .getSingle();
    expect(other.data['v'], 10, reason: 'the rest of the JSON is kept');
    // The added column carries its CHECK.
    await expectLater(
      v8.customStatement("UPDATE occurrences SET sound_id = 'Free text!'"),
      throwsA(isA<SqliteException>()),
    );
    final version = await v8.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), AppDatabase.latestSchemaVersion);
  });

  test(
    'a new database leaves the reminder sound unset (the Dot tone)',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db.customStatement(
        'INSERT INTO profiles (id, tz_id, locale, settings, created_at, '
        "updated_at) VALUES ('u', 'UTC', 'en', '{}', 0, 0)",
      );
      final row = await db
          .customSelect(
            "SELECT json_extract(settings, '\$.reminderSound') AS s "
            'FROM profiles',
          )
          .getSingle();
      expect(row.data['s'], null);
      await expectLater(
        db.customStatement(
          'INSERT INTO series (id, user_id, title, duration_min, rrule, '
          'dtstart_local, tz_id, created_at, updated_at, sound_id) VALUES '
          "('s', 'u', 'x', 30, 'FREQ=DAILY', '2026-10-30T09:00', 'UTC', 0, 0, "
          "'a b')",
        ),
        throwsA(isA<SqliteException>()),
      );
    },
  );

  test('a version 6 file gains step tick times, null, rows kept', () async {
    final dir = await Directory.systemTemp.createTemp('dottoday-mig7');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/db.sqlite');

    final v6 = AppDatabase(NativeDatabase(file));
    await v6.customStatement(
      'INSERT INTO profiles (id, tz_id, locale, settings, created_at, '
      "updated_at) VALUES ('u', 'UTC', 'en', '{}', 0, 0)",
    );
    await v6.customStatement(
      'INSERT INTO occurrences (id, user_id, title, tz_id, duration_min, '
      "created_at, updated_at) VALUES ('o1', 'u', 'Clean', 'UTC', 30, 0, 0)",
    );
    await v6.customStatement('ALTER TABLE subtasks DROP COLUMN done_at');
    await v6.customStatement(
      'INSERT INTO subtasks (id, user_id, occurrence_id, title, done, '
      "created_at, updated_at) VALUES ('s1', 'u', 'o1', 'Dishes', 1, 0, 0)",
    );
    await v6.customStatement('PRAGMA user_version = 6');
    await v6.close();

    final v7 = AppDatabase(NativeDatabase(file));
    addTearDown(v7.close);
    final row = await v7.select(v7.subtasks).getSingle();
    // Ticked before the column existed: never backfilled (B1).
    expect((row.title, row.done, row.doneAt), ('Dishes', true, null));
    final version = await v7.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), AppDatabase.latestSchemaVersion);
  });

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
