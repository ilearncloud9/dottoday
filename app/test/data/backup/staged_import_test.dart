import 'dart:io';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
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

// CR-160 Stage B3 gate, kept by B5: the staged pipeline gives exactly the
// result of the in-memory import or restore it replaced, for the same
// input, from each of its three sources: the same rows (re-owned,
// normalised, Trash rule), the same pending templates, the same outbox
// entries; imported calendar events dropped; staging left empty. That
// path is gone (B5), so its result is the fixture it recorded just before
// (fixtures/pre_b5_replace_state.txt: the in-memory import of this file
// and the in-memory restore of it as a stored backup, which were
// identical).

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  late GuestBackupWorld staged;
  setUp(() async => staged = await stagedWorld());
  tearDown(() => staged.dispose());

  final text = encodeExportJson(stagedFile());

  final before = File(
    'test/data/backup/fixtures/pre_b5_replace_state.txt',
  ).readAsStringSync();

  Future<void> expectSame() async {
    // Compared as text, so a difference shows where.
    expect('${await stagedState(staged)}', before);
    expect(await stagingLeft(staged), 0);
  }

  test('a JSON v1 file: the same result as the in-memory import', () async {
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

  test('Settings import (the backup service): the same result', () async {
    expect(
      await staged.backups.importJson(stagedOwner, text),
      isA<Ok<void, AppFailure>>(),
    );
    await expectSame();
  });

  test('Settings import of a set (the backup service, CR-160 B7b): the '
      'same result, after its pre-import backup', () async {
    final split =
        splitExport(
              stagedFile(),
              exportId: '01928c3e-0000-7000-8000-0000000000e2',
              appVersion: '1',
              schemaVersion: 21,
              purpose: ExportPurpose.export,
              date: '2026-11-11',
              targetBytes: 2048,
            )
            as MultipartSplit;
    expect(
      await staged.backups.importSet(stagedOwner, split.files.first.content, [
        for (final ExportFile(:content) in split.files.skip(1))
          () async => content,
      ]),
      isA<Ok<void, AppFailure>>(),
    );
    await expectSame();
    expect((await staged.backups.list()).map((b) => b.reason), [
      BackupReason.preImport,
    ]);
  });

  test('a multipart set of the same file: the same result', () async {
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

  test('a stored backup, read in place: the same result as the in-memory '
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
    final b = await store(staged);
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

  test('Settings restore (the backup service): the same result', () async {
    final id = await staged.store
        .into(staged.store.backups)
        .insert(
          BackupsCompanion.insert(
            createdAt: ownerAppNow.millisecondsSinceEpoch,
            reason: 'daily',
            appSchemaVersion: 21,
            json: encodeExportJson(stagedFile().reownedTo(stagedOwner)),
            owner: const Value(stagedOwner),
          ),
        );
    expect(
      await staged.backups.restore(stagedOwner, id),
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
