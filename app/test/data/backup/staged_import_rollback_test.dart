import 'dart:io';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/staged_import.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_splitter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/guest_backup_world.dart';
import '../../support/staged_import_world.dart';

// CR-160 Stage B3 gate: a staged import that fails anywhere leaves the
// owner's data, every other owner's, the outbox and the write revisions
// exactly as they were, and its staging gone: a bad row in a later part,
// a reference that doesn't resolve, two owners in one file, another
// account's row (Finding X, inside the commit), the owner changing between
// staging and commit (A → B, A → B → A), a seal or a removal begun, a
// refused safety backup, a failure part-way through the commit, and a full
// disk.

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  late GuestBackupWorld w;
  late Object before;
  late String beforeOther;
  setUp(() async {
    w = await stagedWorld();
    // Another account on the device, with a row of its own.
    await w.app.signIn(stagedOther);
    await w.write(stagedOther, [
      w.task(stagedOther, '01928c3e-0000-7000-8000-0000000009f1', 'B\'s own'),
    ]);
    await w.app.signIn(stagedOwner);
    before = await stagedState(w);
    beforeOther =
        '${await w.titlesOf(stagedOther)}'
        '${await writeRevision(w.db, stagedOther)}';
  });
  tearDown(() => w.dispose());

  Future<void> expectUnchanged(ImportResult r) async {
    expect(r, isA<Err<void, AppFailure>>());
    if (await activeOwnerId(w.db) != stagedOwner) {
      await w.app.signIn(stagedOwner);
    }
    expect(await stagedState(w), before);
    expect(
      '${await w.titlesOf(stagedOther)}'
      '${await writeRevision(w.db, stagedOther)}',
      beforeOther,
    );
    expect(await stagingLeft(w), 0);
  }

  ExportBundle edit(ExportBundle Function(ExportBundle b) f) => f(stagedFile());

  Future<ImportResult> importText(
    String text, {
    SafetyBackup? safety,
    Future<void> Function()? afterChunk,
  }) => stagedImporter(
    w,
    afterChunk: afterChunk,
  ).importText(stagedOwner, text, safety: safety ?? () async => const Ok(null));

  test('a bad row in a later part: refused, nothing changed', () async {
    final b = stagedFile();
    final bad = ExportBundle(
      exportedAt: b.exportedAt,
      profile: b.profile,
      series: b.series,
      occurrences: [
        ...b.occurrences,
        occurrenceFixture().copyWith(
          id: '01928c3e-0000-7000-8000-0000000009e9',
          title: 'x' * 201, // over the title limit
        ),
      ],
      subtasks: b.subtasks,
      routines: b.routines,
    );
    final split =
        splitExport(
              bad,
              exportId: '01928c3e-0000-7000-8000-0000000000e1',
              appVersion: '1',
              schemaVersion: 21,
              purpose: ExportPurpose.export,
              date: '2026-11-11',
              targetBytes: 2048,
            )
            as MultipartSplit;
    await expectUnchanged(
      await stagedImporter(w).importMultipart(
        stagedOwner,
        split.files.first.content,
        parts: [
          for (final ExportFile(:content) in split.files.skip(1))
            () async => content,
        ],
        safety: () async => const Ok(null),
      ),
    );
  });

  test('a step whose task isn\'t in the file, or two owners in one file: '
      'refused', () async {
    final orphan = edit(
      (b) => ExportBundle(
        exportedAt: b.exportedAt,
        profile: b.profile,
        series: b.series,
        occurrences: b.occurrences,
        subtasks: [
          ...b.subtasks,
          subtaskFixture().copyWith(
            id: '01928c3e-0000-7000-8000-0000000009e8',
            occurrenceId: '01928c3e-0000-7000-8000-0000000009e7',
          ),
        ],
      ),
    );
    await expectUnchanged(await importText(encodeExportJson(orphan)));
    final twoOwners = edit(
      (b) => ExportBundle(
        exportedAt: b.exportedAt,
        profile: b.profile,
        occurrences: [
          ...b.occurrences,
          occurrenceFixture().copyWith(
            id: '01928c3e-0000-7000-8000-0000000009e6',
            userId: stagedOther,
          ),
        ],
        series: b.series,
        subtasks: b.subtasks,
      ),
    );
    await expectUnchanged(await importText(encodeExportJson(twoOwners)));
  });

  test('another account\'s row id (Finding X, inside the commit): rolled '
      'back whole', () async {
    final foreign = edit(
      (b) => ExportBundle(
        exportedAt: b.exportedAt,
        profile: b.profile,
        series: b.series,
        occurrences: [
          ...b.occurrences,
          occurrenceFixture().copyWith(
            id: '01928c3e-0000-7000-8000-0000000009f1', // B's
            title: 'Taken over?',
          ),
        ],
        subtasks: b.subtasks,
      ),
    );
    final r = await importText(encodeExportJson(foreign));
    expect(
      r,
      isA<Err<void, AppFailure>>().having(
        (e) => e.failure,
        'f',
        isA<ForeignRowsFailure>(),
      ),
    );
    await expectUnchanged(r);
  });

  for (final (name, change) in [
    (
      'the owner changes (A → B)',
      (GuestBackupWorld w) => w.app.signIn(stagedOther),
    ),
    (
      'A → B → A',
      (GuestBackupWorld w) async {
        await w.app.signIn(stagedOther);
        await w.app.signIn(stagedOwner);
      },
    ),
    (
      'the owner is sealed for deletion',
      (GuestBackupWorld w) => sealForDeletion(w.db, stagedOwner),
    ),
    (
      'a removal begins',
      (GuestBackupWorld w) => beginAccountRemoval(w.db, stagedOwner),
    ),
  ]) {
    test(
      '$name between staging and commit: refused, nothing changed',
      () async {
        final r = await importText(
          encodeExportJson(stagedFile()),
          safety: () async {
            await change(w);
            return const Ok(null);
          },
        );
        expect(r, isA<Err<void, AppFailure>>());
        if (name.contains('sealed') || name.contains('removal')) {
          // The owner's data is untouched; its state is no longer comparable
          // through the shown-owner helpers, so compare the rows directly.
          expect(await stagingLeft(w), 0);
          expect(await w.titlesOf(stagedOwner), contains('Not in the file'));
          return;
        }
        await expectUnchanged(r);
      },
    );
  }

  test('a refused safety backup: nothing changed', () async {
    await expectUnchanged(
      await importText(
        encodeExportJson(stagedFile()),
        safety: () async => const Err(BackupNotRestorableFailure()),
      ),
    );
  });

  test('a failure part-way through the commit: rolled back whole', () async {
    var chunks = 0;
    await expectUnchanged(
      await importText(
        encodeExportJson(stagedFile()),
        afterChunk: () async {
          if (++chunks == 3) throw const FileSystemException('injected');
        },
      ),
    );
    expect(chunks, 3);
  });

  test('a full disk during the commit: rolled back whole', () async {
    var first = true;
    await expectUnchanged(
      await importText(
        encodeExportJson(stagedFile()),
        afterChunk: () async {
          if (!first) return;
          first = false;
          final pages = await w.db
              .customSelect('PRAGMA page_count')
              .getSingle();
          await w.db.customStatement(
            'PRAGMA max_page_count = ${pages.data.values.first}',
          );
        },
      ),
    );
    await w.db.customStatement('PRAGMA max_page_count = 1073741823');
  });
}
