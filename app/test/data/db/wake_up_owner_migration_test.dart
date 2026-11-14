import 'dart:io';

import 'package:dottoday/data/db/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// Schema 21 → 22 (CR-160 Wake Up audit): wake_up_days gets its owner. One
// profile claims every row; with several, no one can, so the rows go to ''
// and no account sees them.

Future<AppDatabase> _v21(Directory dir, List<String> profiles) async {
  final file = File('${dir.path}/db.sqlite');
  final db = AppDatabase(NativeDatabase(file));
  for (final id in profiles) {
    await db.customStatement(
      'INSERT INTO profiles (id, tz_id, locale, settings, created_at, '
      "updated_at) VALUES ('$id', 'UTC', 'en', '{}', 0, 0)",
    );
  }
  // The table as schema 21 had it: one row per day, no owner.
  await db.customStatement('DROP TABLE wake_up_days');
  await db.customStatement(
    'CREATE TABLE wake_up_days (date TEXT NOT NULL PRIMARY KEY, '
    'rang_at_utc INTEGER, stopped_at_utc INTEGER, snoozes INTEGER NOT NULL '
    'DEFAULT 0, card_shown_at_utc INTEGER, started_at_utc INTEGER, '
    'mission_skipped_at_utc INTEGER) STRICT',
  );
  await db.customStatement(
    'INSERT INTO wake_up_days (date, rang_at_utc, snoozes) '
    "VALUES ('2026-11-10', 1000, 2)",
  );
  await db.customStatement('PRAGMA user_version = 21');
  await db.close();
  return AppDatabase(NativeDatabase(file));
}

Future<String> _owner(AppDatabase db) async =>
    (await db
            .customSelect(
              "SELECT owner_id FROM wake_up_days WHERE date = '2026-11-10'",
            )
            .getSingle())
        .read<String>('owner_id');

void main() {
  late Directory dir;
  setUp(
    () async => dir = await Directory.systemTemp.createTemp('dottoday-mig22'),
  );
  tearDown(() => dir.delete(recursive: true));

  test('one profile: its mornings stay its own, values kept', () async {
    final db = await _v21(dir, ['p1']);
    addTearDown(db.close);
    expect(await _owner(db), 'p1');
    final row = await db.select(db.wakeUpDaysTable).getSingle();
    expect((row.rangAtUtc, row.snoozes), (1000, 2));
  });

  test(
    'several profiles: no one can claim them, so no one sees them',
    () async {
      final db = await _v21(dir, ['p1', 'p2']);
      addTearDown(db.close);
      expect(await _owner(db), '');
    },
  );

  test('two owners can each have the same day', () async {
    final db = await _v21(dir, ['p1']);
    addTearDown(db.close);
    await db.customStatement(
      'INSERT INTO wake_up_days (owner_id, date, snoozes) '
      "VALUES ('p2', '2026-11-10', 0)",
    );
    expect(await db.select(db.wakeUpDaysTable).get(), hasLength(2));
  });
}
