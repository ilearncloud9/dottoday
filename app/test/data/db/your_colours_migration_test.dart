import 'dart:io';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';

// 23 → 24 (ED-220, server 0017): profiles.your_colours and accent_hex,
// empty and null on upgrade, rows kept. Kept apart from migration_test.dart
// (already past the file size rule).
void main() {
  test('a version 23 file gains your colours, empty, rows kept', () async {
    final dir = await Directory.systemTemp.createTemp('dottoday-mig24');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/db.sqlite');
    final v23 = AppDatabase(NativeDatabase(file));
    await v23.customStatement(
      'INSERT INTO profiles (id, tz_id, locale, settings, created_at, '
      "updated_at) VALUES ('u', 'UTC', 'en', '{}', 0, 0)",
    );
    await v23.customStatement('ALTER TABLE profiles DROP COLUMN your_colours');
    await v23.customStatement('ALTER TABLE profiles DROP COLUMN accent_hex');
    await v23.customStatement('PRAGMA user_version = 23');
    await v23.close();

    final v24 = AppDatabase(NativeDatabase(file));
    addTearDown(v24.close);
    final row = await v24.select(v24.profiles).getSingle();
    expect(row.id, 'u');
    expect(row.yourColours, '[]');
    expect(row.accentHex, isNull);
  });

  test('a profile keeps its colours through the repository', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DriftSettingsRepository(db);
    final p = profileFixture().copyWith(
      yourColours: ['#8C6A4F', '#1A2B3C'],
      accentHex: '#9E4F8F',
    );
    await repo.upsert(p);
    final back = await repo.watchProfile(p.id).first;
    expect(back?.yourColours, ['#8C6A4F', '#1A2B3C']);
    expect(back?.accentHex, '#9E4F8F');
  });
}
