import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/feedback/diagnostics_reader.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_series_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/feedback/feedback_diagnostics.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';

const _secretTitle = 'Call Dr. Weiss about the biopsy';
const _secretNotes = 'PIN 4471, ask for Mara';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await DriftSettingsRepository(db).upsert(profileFixture());
  });
  tearDown(() => db.close());

  String id(int n) =>
      '01928c3e-0000-7000-8000-${n.toRadixString(16).padLeft(12, '0')}';

  Future<void> seed() async {
    final base = occurrenceFixture().copyWith(
      title: _secretTitle,
      notes: _secretNotes,
    );
    await DriftOccurrenceRepository(db).upsertAll([
      base.copyWith(id: id(1)),
      base.copyWith(id: id(2), startUtc: null),
      base.copyWith(id: id(3), status: OccurrenceStatus.done),
      base.copyWith(id: id(4), deletedAt: t1),
      base.copyWith(id: id(5), source: OccurrenceSource.calendar),
    ]);
    await DriftSeriesRepository(
      db,
    ).upsertAll([seriesFixture().copyWith(title: _secretTitle)]);
    await db
        .into(db.localMeta)
        .insert(
          LocalMetaCompanion.insert(key: 'hlc_node', value: '0a1b2c3d4e5f6071'),
        );
  }

  test('counts what is on the device and reads the node id', () async {
    await seed();
    final read = await DriftDiagnosticsReader(db).read();
    expect(read.counts.toJson(), {
      'tasks': 3,
      'inbox': 1,
      'done': 1,
      'repeats': 1,
      'trash': 1,
      'calendarEvents': 1,
    });
    expect(read.deviceId, '0a1b2c3d4e5f6071');
  });

  test('an empty device: zeros and no node id', () async {
    final read = await DriftDiagnosticsReader(db).read();
    expect(read.counts.tasks, 0);
    expect(read.deviceId, isNull);
  });

  // Canary (CLAUDE.md §4, docs/04 §9): task text never reaches a report.
  test('the diagnostics text holds no title or note', () async {
    await seed();
    final read = await DriftDiagnosticsReader(db).read();
    final text = FeedbackDiagnostics(
      appVersion: '0.1.0 (1)',
      platform: 'iOS',
      locale: 'en',
      schemaVersion: AppDatabase.latestSchemaVersion,
      deviceId: read.deviceId,
      sync: SyncState.localOnly,
      counts: read.counts,
      generatedUtc: t1,
    ).toText();
    for (final secret in [_secretTitle, _secretNotes, 'Weiss', '4471']) {
      expect(text, isNot(contains(secret)));
    }
    expect(text, contains('"tasks": 3'));
  });
}
