import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/drift_backup_service.dart';
import 'package:dottoday/data/backup/guest_backup_cutoff.dart';
import 'package:dottoday/data/backup/user_data_snapshot.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/guest_backup_world.dart';
import '../../support/owner_app.dart';

// CR-160 I1 final verification: failures injected into the guest-backup
// privacy steps (a SQLite trigger aborts the write, as a full disk or a
// crash mid-statement would). Every failure must fail closed: the backup
// stays hidden and unchanged or hidden and rewritten, the account's
// removal stays pending (its rows hidden, never anyone else's touched),
// and a rerun finishes the work. Restore and scrub never interleave.

const _a = '01928c3e-0000-7000-8000-00000000000a';
const _secret = '01928c3e-0000-7000-8000-000000000fa1';
const _kept = '01928c3e-0000-7000-8000-000000000fb1';

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  late GuestBackupWorld w;
  late String guest;
  setUp(() async {
    w = GuestBackupWorld();
    guest = await w.app.shown();
  });
  tearDown(() => w.dispose());

  /// A backup holding the guest's kept work and work then moved into [_a];
  /// back to the guest afterwards.
  Future<int> mixedThenPromote() async {
    await w.write(guest, [w.task(guest, _kept, 'Kept')]);
    await w.app.owners.signOut(); // a new guest session
    await w.write(guest, [w.task(guest, _secret, 'Secret plan')]);
    final mixed = await w.backup(guest);
    await w.promote(_a);
    await w.app.owners.signOut();
    return mixed;
  }

  /// A guest backup as an earlier build stored it (no fence, no record).
  Future<int> legacyBackup() async {
    final bundle = await w.db.transaction(
      () => readUserData(w.db, guest, ownerAppNow),
    );
    return w.store
        .into(w.store.backups)
        .insert(
          BackupsCompanion.insert(
            createdAt: ownerAppNow.millisecondsSinceEpoch,
            reason: 'daily',
            appSchemaVersion: 19,
            json: encodeExportJson(bundle!),
            owner: Value(guest),
          ),
        );
  }

  /// Every row (with its owner), the outbox, both write revisions and the
  /// owner shown: what a failed privacy step must leave as it was.
  Future<String> state() async => [
    for (final r in await w.db.select(w.db.occurrences).get())
      '${r.id}|${r.userId}|${r.title}|${r.deletedAt}',
    for (final c in await w.db.select(w.db.changeLog).get())
      '${c.ownerId}|${c.entityId}',
    await writeRevision(w.db, guest),
    await writeRevision(w.db, _a),
    await activeOwnerId(w.db),
  ].join(';');

  Future<Map<int, String>> stored() async => {
    for (final r in await w.store.select(w.store.backups).get()) r.id: r.json,
  };

  Future<bool> hidden(int id) async =>
      (await guestBackupVisibility(w.db, guest)).hides(id);

  /// Aborts every write to the backups file (before the rewrite lands).
  Future<void> failBackupWrites() => w.store.customStatement(
    'CREATE TRIGGER fail_rewrite BEFORE UPDATE ON backups '
    "BEGIN SELECT RAISE(ABORT, 'injected'); END",
  );

  /// Aborts recording a backup as scrubbed (after the rewrite landed).
  Future<void> failScrubbedMarker() async {
    for (final op in ['INSERT', 'UPDATE']) {
      await w.db.customStatement(
        'CREATE TRIGGER fail_marker_$op BEFORE $op ON local_meta '
        "WHEN NEW.key LIKE 'guest_backup_promotions:%' "
        "BEGIN SELECT RAISE(ABORT, 'injected'); END",
      );
    }
  }

  /// Confirms [_a]'s deletion, expecting the injected failure.
  Future<void> deletionFails() async {
    await expectLater(w.app.owners.accountDeleted(_a), throwsA(anything));
    expect(await isRemovalPending(w.db, _a), isTrue);
    expect(await activeOwnerId(w.db), isNot(_a));
  }

  test('the legacy scrub failing right before the deletion: the removal '
      'stays pending, nothing changes or shows; the rerun finishes', () async {
    await w.write(guest, [w.task(guest, _secret, 'Secret plan')]);
    final legacy = await legacyBackup();
    await w.promote(_a); // records the legacy boundary above it
    // As an earlier build moved it: no promotion, so only the legacy
    // evidence scrub can take the moved work out.
    await w.db.customStatement(
      "DELETE FROM local_meta WHERE key LIKE 'guest_backup_promotions:%'",
    );
    await w.app.owners.signOut();
    expect(await w.json(legacy), contains(_secret));
    final was = await state();
    final files = await stored();
    await failBackupWrites();
    await deletionFails();
    expect(await state(), was, reason: "A's rows kept, no other change");
    expect(await stored(), files, reason: 'no backup rewritten or deleted');
    expect(await hidden(legacy), isTrue);
    expect(await w.listed(), isNot(contains(legacy)));
    await w.store.customStatement('DROP TRIGGER fail_rewrite');
    await w.app.owners.finishRemoval(_a);
    expect(await isRemovalPending(w.db, _a), isFalse);
    expect(await w.json(legacy), isNot(contains(_secret)));
    expect(await hidden(legacy), isTrue, reason: 'quarantine never lifts');
  });

  test('the P2 rewrite failing before it lands: unchanged and hidden, '
      'pending; the rerun scrubs and shows it', () async {
    final mixed = await mixedThenPromote();
    final was = await state();
    final files = await stored();
    await failBackupWrites();
    await deletionFails();
    expect(await state(), was);
    expect(await stored(), files);
    expect(await hidden(mixed), isTrue);
    expect((await guestPromotions(w.db, guest)).single.scrubbed, isEmpty);
    await w.store.customStatement('DROP TRIGGER fail_rewrite');
    await w.app.owners.finishRemoval(_a);
    expect(await hidden(mixed), isFalse);
    expect(await w.json(mixed), isNot(contains(_secret)));
    expect(await w.json(mixed), contains(_kept));
  });

  test('a crash between the rewrite and its record: rewritten but still '
      'hidden; the rerun records it without rewriting again', () async {
    final mixed = await mixedThenPromote();
    final was = await state();
    await failScrubbedMarker();
    await deletionFails();
    expect(await state(), was);
    final rewritten = await w.json(mixed);
    expect(rewritten, isNot(contains(_secret)));
    expect(await hidden(mixed), isTrue, reason: 'not recorded: fail closed');
    expect(await w.backups.restore(guest, mixed), isA<Err<void, AppFailure>>());
    for (final op in ['INSERT', 'UPDATE']) {
      await w.db.customStatement('DROP TRIGGER fail_marker_$op');
    }
    await w.app.owners.finishRemoval(_a);
    expect(await hidden(mixed), isFalse);
    expect(await w.json(mixed), rewritten);
  });

  test('restore holds the fence: a deletion confirmed during it scrubs '
      'only after it ends', () async {
    final mixed = await mixedThenPromote();
    final visible = await w.backup(guest);
    late Future<void> deleting;
    String? duringRestore;
    final racing = DriftBackupService(
      db: w.db,
      backups: w.store,
      writes: w.app.container.read(writeUseCaseProvider),
      clock: w.clock,
      logger: w.app.container.read(loggerProvider),
      afterRead: () async {
        deleting = w.app.owners.accountDeleted(_a);
        await Future.any([
          deleting,
          Future<void>.delayed(const Duration(milliseconds: 200)),
        ]);
        duringRestore = await w.json(mixed);
      },
    );
    expect(await racing.restore(guest, visible), isA<Ok<void, AppFailure>>());
    expect(duringRestore, contains(_secret), reason: 'the scrub waited');
    await deleting;
    expect(await w.json(mixed), isNot(contains(_secret)));
    expect(await w.titlesOf(guest), isNot(contains('Secret plan')));
    for (final json in (await stored()).values) {
      expect(json, isNot(contains(_secret)));
    }
  });

  test('a restore queued behind the deletion\'s scrub never exposes the '
      'moved work, whichever runs first', () async {
    final mixed = await mixedThenPromote();
    final deleting = w.app.owners.accountDeleted(_a);
    final restoring = w.backups.restore(guest, mixed);
    final result = await restoring;
    await deleting;
    expect(await w.titlesOf(guest), isNot(contains('Secret plan')));
    if (result is Ok) expect(await w.titlesOf(guest), contains('Kept'));
    expect(await hidden(mixed), isFalse);
    expect(await w.json(mixed), isNot(contains(_secret)));
  });

  test('a recreated backups file under a P1 cutoff: new guest backups are '
      'hidden (fail closed) until the scrub proves them clean', () async {
    await mixedThenPromote();
    for (var i = 0; i < 3; i++) {
      await w.backup(guest);
    }
    final cutoff = (await guestPromotions(w.db, guest)).single.cutoff!;
    await w.store.customStatement('DELETE FROM backups');
    await w.store.customStatement('DELETE FROM sqlite_sequence');
    final fresh = await w.backup(guest);
    expect(fresh, lessThanOrEqualTo(cutoff));
    expect(await w.listed(), isNot(contains(fresh)));
    expect(await w.backups.restore(guest, fresh), isA<Err<void, AppFailure>>());
    await w.app.owners.accountDeleted(_a);
    expect(await w.json(fresh), isNot(contains(_secret)));
    expect(await w.listed(), contains(fresh));
  });
}
