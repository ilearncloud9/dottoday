import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/multipart_backup_store.dart';
import 'package:dottoday/domain/export/import_file_kind.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/guest_backup_world.dart';
import '../../support/staged_import_world.dart';

// CR-160 backup memory (option A, 2026-11-11): an account's backup is
// always parts, at any size, so taking one (and so every Undo's safety
// backup) never holds the whole account in memory; a guest's that fits
// the import limit stays one JSON v1 file, the form the I1 privacy scrubs
// clean.

const _after = '01928c3e-0000-7000-8000-0000000007b2';

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  test("a small account's backup is verified parts, and restores", () async {
    final w = await stagedWorld();
    addTearDown(w.dispose);
    final id = await w.backup(stagedOwner);
    expect(await isMultipartBackup(w.store, id), isTrue);
    expect(await verifyStoredMultipart(w.store, id, stagedOwner), isTrue);
    expect(
      importFileKind(await w.json(id)),
      ImportFileKind.manifest,
      reason: 'the row holds the manifest',
    );
    await w.write(stagedOwner, [w.task(stagedOwner, _after, 'Added after')]);
    expect(
      await w.backups.restore(stagedOwner, id),
      isA<Ok<void, AppFailure>>(),
    );
    expect(await w.titlesOf(stagedOwner), isNot(contains('Added after')));
  });

  test("a guest's backup within the limit stays one JSON v1 file", () async {
    final w = GuestBackupWorld();
    addTearDown(w.dispose);
    final guest = await w.app.shown();
    await w.write(guest, [w.task(guest, _after, 'Guest task')]);
    final id = await w.backup(guest);
    expect(await isMultipartBackup(w.store, id), isFalse);
    expect(importFileKind(await w.json(id)), ImportFileKind.legacy);
  });
}
