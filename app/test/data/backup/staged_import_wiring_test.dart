import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/staged_import_store.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/owner_app.dart';
import '../../support/staged_import_world.dart';

// CR-160 Stage B5: Settings import and backup restore run through the
// staged pipeline. Staging an earlier run left behind is removed by the
// start/resume maintenance, never this run's; a stored backup over the
// 25 MB import limit restores through the backup service.

const _old = '01928c3e-0000-7000-8000-0000000009a1';
const _mine = '01928c3e-0000-7000-8000-0000000009a2';
const _earlierRun = '01928c3e-0000-7000-8000-0000000009a3';

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  test("maintenance removes an earlier run's staging and keeps this "
      "run's", () async {
    final w = await stagedWorld();
    addTearDown(w.dispose);
    Future<void> session(String id, String owner, String runId) => w.db
        .into(w.db.importSessions)
        .insert(
          ImportSessionsCompanion.insert(
            importId: id,
            owner: owner,
            ownerGeneration: 0,
            runId: runId,
            startedAt: w.clock.nowUtc().millisecondsSinceEpoch,
            declaredBytes: 1,
          ),
        );
    await session(_old, stagedOther, _earlierRun);
    await session(_mine, stagedOwner, importRunId);
    expect(
      await w.backups.runDailyIfDue(stagedOwner),
      isA<Ok<bool, AppFailure>>(),
    );
    final left = [
      for (final s in await w.db.select(w.db.importSessions).get()) s.importId,
    ];
    expect(left, [_mine]);
  });

  test('a stored single-file backup over the 25 MB import limit restores '
      'through the backup service', () async {
    final w = await stagedWorld();
    addTearDown(w.dispose);
    final json = encodeExportJson(
      ExportBundle(
        exportedAt: ownerAppNow,
        profile: profileFixture().copyWith(id: stagedOwner),
        occurrences: [
          for (var i = 0; i < 2700; i++)
            occurrenceFixture().copyWith(
              id: '01928c3e-0000-7000-8009-${i.toString().padLeft(12, '0')}',
              userId: stagedOwner,
              seriesId: null,
              title: 'Row $i',
              notes: 'n' * 9990,
            ),
        ],
      ),
    );
    expect(exceedsImportLimit(json), isTrue);
    final id = await w.store
        .into(w.store.backups)
        .insert(
          BackupsCompanion.insert(
            createdAt: ownerAppNow.millisecondsSinceEpoch,
            reason: 'daily',
            appSchemaVersion: AppDatabase.latestSchemaVersion,
            json: json,
            owner: const Value(stagedOwner),
          ),
        );
    expect(
      await w.backups.restore(stagedOwner, id),
      isA<Ok<void, AppFailure>>(),
    );
    final titles = await w.titlesOf(stagedOwner);
    expect(titles, contains('Row 2699'));
    expect(titles, isNot(contains('Not in the file')), reason: 'Trash');
    expect(await stagingLeft(w), 0);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
