import 'dart:convert';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/guest_backup_cutoff.dart';
import 'package:dottoday/data/backup/multipart_backup_store.dart';
import 'package:dottoday/data/backup/multipart_backup_writer.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:drift/drift.dart' show BooleanExpressionOperators, Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/guest_backup_world.dart';
import '../../support/owner_app.dart';
import '../../support/staged_import_world.dart';

// CR-160 Stage B4 gate, in the running app: a backup stored as parts
// restores through the staged pipeline (B3) to exactly what the same
// account's single-file backup restores to; a guest's one stays hidden
// and untouched through promotion and P2; removing an account removes its
// parts.

const _a = '01928c3e-0000-7000-8000-00000000000c';
const _after = '01928c3e-0000-7000-8000-0000000007b1';

Future<StoredParts> _parts(GuestBackupWorld w, String owner) async =>
    (await writeMultipartBackup(
      w.db,
      w.store,
      owner,
      reason: 'daily',
      nowUtc: ownerAppNow,
      exportId: '01928c3e-0000-7000-8000-0000000000e2',
      schemaVersion: AppDatabase.latestSchemaVersion,
      targetBytes: 4000,
    ))!;

Future<int> _partsOf(GuestBackupWorld w, int id) async =>
    (await (w.store.select(
      w.store.backupParts,
    )..where((p) => p.backupId.equals(id))).get()).length;

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  /// [stagedOwner]'s account (the hostile file imported), backed up as
  /// parts or as one file, changed, then restored from that backup.
  Future<Object> restoredFrom({required bool parts}) async {
    final w = await stagedWorld();
    addTearDown(w.dispose);
    final imported = await stagedImporter(w).importText(
      stagedOwner,
      encodeExportJson(stagedFile()),
      safety: () async => const Ok(null),
    );
    expect(imported, isA<Ok<void, AppFailure>>());
    await w.app.idle();
    final int id;
    if (parts) {
      id = (await _parts(w, stagedOwner)).id;
      expect(await _partsOf(w, id), greaterThan(1));
    } else {
      id = await w.backup(stagedOwner);
      expect(await _partsOf(w, id), 0);
    }
    await w.write(stagedOwner, [w.task(stagedOwner, _after, 'Added after')]);
    final r = await stagedImporter(w, runId: 'run-2').restoreBackup(
      stagedOwner,
      w.store,
      id,
      safety: () async => const Ok(null),
    );
    expect(r, isA<Ok<void, AppFailure>>());
    expect(await stagingLeft(w), 0);
    expect(await w.titlesOf(stagedOwner), isNot(contains('Added after')));
    return stagedState(w);
  }

  test('restoring parts gives exactly what restoring one file gives', () async {
    expect(await restoredFrom(parts: true), await restoredFrom(parts: false));
  });

  test("a guest's backup stored as parts stays hidden, unchanged and stored "
      'through promotion and P2; removing the account removes its '
      'parts', () async {
    final w = GuestBackupWorld();
    addTearDown(w.dispose);
    final guest = await w.app.shown();
    await w.write(guest, [
      for (var i = 0; i < 8; i++)
        w
            .task(guest, '01928c3e-0000-7000-8000-0000000008${i}0', 'Guest $i')
            .copyWith(notes: 'n' * 3000),
    ]);
    await w.backup(guest); // the first fenced work: the boundary
    final hidden = (await _parts(w, guest)).id;
    final parts = await _partsOf(w, hidden);
    expect(parts, greaterThan(1));
    final before = await w.json(hidden);

    await w.promote(_a);
    final own = (await _parts(w, _a)).id;
    expect(await _partsOf(w, own), greaterThan(1));
    await w.app.owners.signOut();
    await w.app.owners.accountDeleted(_a); // P2, then the account's removal

    expect((await guestBackupVisibility(w.db, guest)).hides(hidden), isTrue);
    expect(await w.listed(), isNot(contains(hidden)));
    expect(await w.json(hidden), before);
    expect(await _partsOf(w, hidden), parts);
    expect(
      await w.backups.restore(guest, hidden),
      isA<Err<void, AppFailure>>(),
    );
    expect(await _partsOf(w, own), 0, reason: "the account's parts went");
  });

  test("parts that are wholly another account's (profile and every row) "
      'are refused, even with every hash right', () async {
    final w = await stagedWorld();
    addTearDown(w.dispose);
    final id = (await _parts(w, stagedOwner)).id;
    // Every part re-written as [stagedOther]'s, hashes, sizes and the
    // manifest recomputed: a set that is whole and has one owner, just not
    // this backup's. Only the profile-is-the-owner check refuses it.
    final stored = (await storedManifest(w.store, id, stagedOwner))!;
    final manifest =
        jsonDecode(canonicalJson(stored.toJson())) as Map<String, Object?>;
    for (final entry in manifest['parts']! as List) {
      final e = entry as Map<String, Object?>;
      final index = e['index']! as int;
      final text = (await storedPartText(
        w.store,
        id,
        index,
      ))!.replaceAll(stagedOwner, stagedOther);
      e['sha256'] = sha256Hex(text);
      e['bytes'] = utf8.encode(text).length;
      await (w.store.update(
        w.store.backupParts,
      )..where((p) => p.backupId.equals(id) & p.partIndex.equals(index))).write(
        BackupPartsCompanion(
          json: Value(text),
          sha256: Value(e['sha256']! as String),
          bytes: Value(e['bytes']! as int),
        ),
      );
    }
    await (w.store.update(w.store.backups)..where((b) => b.id.equals(id)))
        .write(BackupsCompanion(json: Value(canonicalJson(manifest))));

    expect(await verifyStoredMultipart(w.store, id, stagedOwner), isFalse);
    final before = await stagedState(w);
    final r = await stagedImporter(w).restoreBackup(
      stagedOwner,
      w.store,
      id,
      safety: () async => const Ok(null),
    );
    expect(r, isA<Err<void, AppFailure>>());
    expect(await stagedState(w), before);
    expect(await stagingLeft(w), 0);
  });
}
