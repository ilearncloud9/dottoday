import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_splitter.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/guest_backup_world.dart';
import '../../support/owner_app.dart';
import '../../support/staged_import_world.dart';

// CR-160 Stage B3 gate: the staged pipeline gives exactly the result of
// today's in-memory import or restore for the same input, from each of
// its three sources: the same rows (re-owned, normalised, Trash rule),
// the same pending templates, the same outbox entries; imported calendar
// events dropped; staging left empty.

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  late GuestBackupWorld today;
  late GuestBackupWorld staged;
  setUp(() async {
    today = await stagedWorld();
    staged = await stagedWorld();
  });
  tearDown(() async {
    await today.dispose();
    await staged.dispose();
  });

  final text = encodeExportJson(stagedFile());

  Future<void> expectSame() async {
    final want = await stagedState(today);
    expect(await stagedState(staged), want);
    expect(await stagingLeft(staged), 0);
  }

  test('a JSON v1 file: the same result as today\'s import', () async {
    expect(
      await today.backups.importJson(stagedOwner, text),
      isA<Ok<void, AppFailure>>(),
    );
    expect(
      await stagedImporter(
        staged,
      ).importText(stagedOwner, text, safety: preImportBackup(staged)),
      isA<Ok<void, AppFailure>>(),
    );
    await expectSame();
    final titles = await staged.titlesOf(stagedOwner);
    expect(titles, isNot(contains('From the calendar')));
    expect(titles, isNot(contains('Not in the file')), reason: 'Trash');
  });

  test('a multipart set of the same file: the same result', () async {
    expect(
      await today.backups.importJson(stagedOwner, text),
      isA<Ok<void, AppFailure>>(),
    );
    final split =
        splitExport(
              stagedFile(),
              exportId: '01928c3e-0000-7000-8000-0000000000e1',
              appVersion: '1',
              schemaVersion: 21,
              purpose: ExportPurpose.export,
              date: '2026-11-11',
              targetBytes: 2048,
            )
            as MultipartSplit;
    expect(split.files.length, greaterThan(3));
    final reads = <int>[];
    final result = await stagedImporter(staged).importMultipart(
      stagedOwner,
      split.files.first.content,
      parts: [
        for (final (i, ExportFile(:content)) in split.files.skip(1).indexed)
          () async {
            reads.add(i);
            return content;
          },
      ],
      safety: preImportBackup(staged),
    );
    expect(result, isA<Ok<void, AppFailure>>());
    expect(reads, [for (var i = 0; i < split.files.length - 1; i++) i]);
    await expectSame();
  });

  test('a stored backup, read in place: the same result as today\'s '
      'restore', () async {
    final own = encodeExportJson(stagedFile().reownedTo(stagedOwner));
    Future<int> store(GuestBackupWorld w) => w.store
        .into(w.store.backups)
        .insert(
          BackupsCompanion.insert(
            createdAt: ownerAppNow.millisecondsSinceEpoch,
            reason: 'daily',
            appSchemaVersion: 21,
            json: own,
            owner: const Value(stagedOwner),
          ),
        );
    final a = await store(today);
    final b = await store(staged);
    expect(
      await today.backups.restore(stagedOwner, a),
      isA<Ok<void, AppFailure>>(),
    );
    expect(
      await stagedImporter(staged).restoreBackup(
        stagedOwner,
        staged.store,
        b,
        // Inside the fence: today's safety backup would take it again.
        safety: () async => const Ok(null),
      ),
      isA<Ok<void, AppFailure>>(),
    );
    await expectSame();
  });

  test('a stored backup not the owner\'s, or another\'s profile inside, is '
      'refused like today', () async {
    Future<int> put(String json, String? owner) => staged.store
        .into(staged.store.backups)
        .insert(
          BackupsCompanion.insert(
            createdAt: 0,
            reason: 'daily',
            appSchemaVersion: 21,
            json: json,
            owner: Value(owner),
          ),
        );
    final before = await stagedState(staged);
    final others = await put(text, stagedOther);
    final lying = await put(text, stagedOwner); // its profile isn't the owner
    for (final id in [others, lying, 9999]) {
      expect(
        await stagedImporter(staged).restoreBackup(
          stagedOwner,
          staged.store,
          id,
          safety: () async => const Ok(null),
        ),
        isA<Err<void, AppFailure>>(),
        reason: '$id',
      );
    }
    expect(await stagedState(staged), before);
    expect(await stagingLeft(staged), 0);
  });
}
