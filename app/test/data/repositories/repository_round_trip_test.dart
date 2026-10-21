import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_series_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/data/repositories/drift_subtask_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/export/export_fixtures.dart';
import '../../domain/fixtures.dart';

void main() {
  late AppDatabase db;
  late DriftOccurrenceRepository occurrences;
  late DriftSeriesRepository series;
  late DriftSubtaskRepository subtasks;
  late DriftSettingsRepository settings;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    occurrences = DriftOccurrenceRepository(db);
    series = DriftSeriesRepository(db);
    subtasks = DriftSubtaskRepository(db);
    settings = DriftSettingsRepository(db);
  });
  tearDown(() => db.close());

  test('hostile bundle survives write → read unchanged', () async {
    final bundle = hostileBundle();
    await settings.upsert(bundle.profile);
    await series.upsertAll(bundle.series);
    await occurrences.upsertAll(bundle.occurrences);
    await subtasks.upsertAll(bundle.subtasks);

    expect(await settings.findLocalProfile(), bundle.profile);
    for (final s in bundle.series) {
      expect(await series.findById(userId, s.id), s);
    }
    for (final o in bundle.occurrences) {
      expect(await occurrences.findById(userId, o.id), o);
    }
    for (final s in bundle.subtasks) {
      expect(await subtasks.findById(userId, s.id), s);
    }
  });

  test('upsert replaces content but keeps sync columns', () async {
    await settings.upsert(profileFixture());
    final o = occurrenceFixture();
    await occurrences.upsertAll([o]);
    await db.customStatement('UPDATE occurrences SET dirty = 1, version = 3');
    await occurrences.upsertAll([o.copyWith(title: 'Renamed')]);

    expect((await occurrences.findById(userId, o.id))!.title, 'Renamed');
    final row = await db.select(db.occurrences).getSingle();
    expect((row.dirty, row.version), (true, 3));
  });

  test('reads are scoped to the owner', () async {
    await settings.upsert(profileFixture());
    await settings.upsert(
      profileFixture().copyWith(id: 'other', createdAt: t1),
    );
    final mine = occurrenceFixture();
    await occurrences.upsertAll([mine]);

    expect(await occurrences.findById('other', mine.id), isNull);
    expect(await series.findById('other', seriesFixture().id), isNull);
    expect(await subtasks.findById('other', subtaskFixture().id), isNull);
    expect(await occurrences.watchRange('other', t0, t1).first, isEmpty);
    // The local owner is the oldest profile.
    expect((await settings.findLocalProfile())!.id, userId);
  });

  test('profile stream re-emits on change', () async {
    final p = profileFixture();
    final emitted = settings.watchProfile(userId).take(2).toList();
    await pumpEventQueue();
    await settings.upsert(p);
    expect(await emitted, [null, p]);
  });

  test('series needing materialisation', () async {
    await settings.upsert(profileFixture());
    final horizon = DateTime.utc(2027);
    final never = seriesFixture();
    final behind = never.copyWith(
      id: 's-behind',
      materialisedThroughUtc: DateTime.utc(2026, 12),
    );
    final ahead = never.copyWith(
      id: 's-ahead',
      materialisedThroughUtc: horizon,
    );
    final archived = never.copyWith(id: 's-archived', archivedAt: t1);
    final deleted = never.copyWith(id: 's-deleted', deletedAt: t1);
    await series.upsertAll([never, behind, ahead, archived, deleted]);

    final due = await series.findNeedingMaterialisation(userId, horizon);
    expect(due.map((s) => s.id), [never.id, behind.id]);
    expect((await series.watchActive(userId).first).map((s) => s.id).toSet(), {
      never.id,
      behind.id,
      ahead.id,
    });
  });

  test('subtasks for a set of occurrences, live only, in order', () async {
    await settings.upsert(profileFixture());
    final o1 = occurrenceFixture();
    final o2 = o1.copyWith(id: 'o2');
    await occurrences.upsertAll([o1, o2]);
    final a = subtaskFixture().copyWith(id: 'a', sortOrder: 2);
    final b = subtaskFixture().copyWith(id: 'b', sortOrder: 1);
    final c = subtaskFixture().copyWith(id: 'c', occurrenceId: 'o2');
    final gone = subtaskFixture().copyWith(id: 'd', deletedAt: t1);
    await subtasks.upsertAll([a, b, c, gone]);

    final got = await subtasks.watchForOccurrences(userId, {o1.id}).first;
    expect(got.map((s) => s.id), ['b', 'a']);
  });

  test('series delete keeps its occurrences (ON DELETE SET NULL)', () async {
    await settings.upsert(profileFixture());
    final s = seriesFixture();
    await series.upsertAll([s]);
    final o = occurrenceFixture().copyWith(
      seriesId: s.id,
      originalStartUtc: t0,
    );
    await occurrences.upsertAll([o]);
    expect(await occurrences.findBySeries(userId, s.id), [o]);

    await (db.delete(db.seriesTable)..where((t) => t.id.equals(s.id))).go();
    expect((await occurrences.findById(userId, o.id))!.seriesId, isNull);
  });
}
