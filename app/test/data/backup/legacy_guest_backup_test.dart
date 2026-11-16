import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/backup_retention.dart';
import 'package:dottoday/data/backup/guest_backup_cutoff.dart';
import 'package:dottoday/data/backup/legacy_guest_quarantine.dart';
import 'package:dottoday/data/backup/user_data_snapshot.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/sync/shared_hlc.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/onboarding/starter_habits.dart';
import 'package:dottoday/domain/profile/local_profile_service.dart';
import 'package:dottoday/domain/sync/stable_ids.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/fake_clock.dart';
import '../../support/guest_backup_world.dart';
import '../../support/owner_app.dart';

// Legacy guest-backup privacy (CR-160 I1): guest backups made before this
// protection first ran are quarantined (fail closed), whatever the device
// can or can't prove about earlier moves; the evidence scrub only removes
// rows an account on the device positively holds; nothing is shown again
// or deleted.

const _a = '01928c3e-0000-7000-8000-00000000000a';
const _b = '01928c3e-0000-7000-8000-00000000000b';
const _secret = '01928c3e-0000-7000-8000-0000000008a1';
const _kept = '01928c3e-0000-7000-8000-0000000008b1';

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

  /// A backup as an earlier build stored it: no fence, no boundary.
  Future<int> legacyBackup(String owner) async {
    final bundle = await w.db.transaction(
      () => readUserData(w.db, owner, ownerAppNow),
    );
    return w.store
        .into(w.store.backups)
        .insert(
          BackupsCompanion.insert(
            createdAt: ownerAppNow.millisecondsSinceEpoch,
            reason: 'daily',
            appSchemaVersion: 19,
            json: encodeExportJson(bundle!),
            owner: Value(owner),
          ),
        );
  }

  /// A move of the guest's work into [account] made by an earlier build:
  /// it recorded no promotion.
  Future<void> legacyPromote(String account) async {
    final hlc = SharedHlc(w.db, FakeClock(ownerAppNow));
    Future<SignInResult> signIn() => signInOwner(
      w.db,
      account,
      hlc,
      freshProfile: (id) => freshAccountProfile(id, 'UTC', 'en', ownerAppNow),
    );
    expect((await signIn()).change, OwnerChange.guestChoiceNeeded);
    await recordGuestChoice(w.db, account, GuestChoice.bringIn);
    await signIn();
    await w.db.customStatement(
      "DELETE FROM local_meta WHERE key LIKE 'guest_backup_promotions:%'",
    );
  }

  /// Back to the guest, as an earlier build's sign-out left it.
  Future<void> legacySignOut() => signOutOwner(w.db);

  /// The first fenced backup work of this build: the "upgrade".
  Future<List<int>> upgradeAndList() => w.listed();

  /// A mixed legacy backup: kept guest work (an earlier session) and work
  /// that then moved into [account] by an earlier build.
  Future<int> mixedLegacy(String account) async {
    await w.write(guest, [w.task(guest, _kept, 'Kept')]);
    await legacySignOut(); // a new guest session
    await w.write(guest, [w.task(guest, _secret, 'Secret plan')]);
    final id = await legacyBackup(guest);
    await legacyPromote(account);
    await legacySignOut();
    return id;
  }

  test('pre-upgrade guest backups are quarantined: not listed, not '
      'restorable by id; post-upgrade ones are the guest\'s', () async {
    await w.write(guest, [w.task(guest, _kept, 'Kept')]);
    final old = await legacyBackup(guest);
    expect(await upgradeAndList(), isEmpty, reason: 'fail closed');
    expect(await w.backups.restore(guest, old), isA<Err<void, AppFailure>>());
    final fresh = await w.backup(guest);
    expect(await w.listed(), [fresh]);
    expect(await w.backups.restore(guest, fresh), isA<Ok<void, AppFailure>>());
  });

  test('evidence scrub: rows an account holds come out, the guest\'s kept '
      'work stays, and the backup stays quarantined', () async {
    final mixed = await mixedLegacy(_a);
    await upgradeAndList();
    await w.backups.runDailyIfDue(guest); // maintenance
    final json = await w.json(mixed);
    expect(json, isNot(contains(_secret)));
    expect(json, contains(_kept));
    expect(await w.listed(), isNot(contains(mixed)));
  });

  test('a re-keyed starter is matched through its account copy', () async {
    final day = DateTime.utc(
      ownerAppNow.year,
      ownerAppNow.month,
      ownerAppNow.day,
    );
    final starter = occurrenceFixture().copyWith(
      id: starterTaskId(guest, StarterHabit.walk, day),
      userId: guest,
      seriesId: null,
      tzId: 'UTC',
      startUtc: ownerAppNow,
      title: 'Walk',
    );
    await w.write(guest, [starter]);
    final id = await legacyBackup(guest);
    await legacyPromote(_a);
    await legacySignOut();
    await upgradeAndList();
    await w.backups.runDailyIfDue(guest);
    expect(await w.json(id), isNot(contains(starter.id)));
  });

  test('promoted, then the account deleted, both before the upgrade: no '
      'evidence left, so it stays quarantined, untouched', () async {
    final mixed = await mixedLegacy(_a);
    await beginAccountRemoval(w.db, _a);
    await finishAccountRemoval(w.db, _a);
    final before = await w.json(mixed);
    await upgradeAndList();
    await w.backups.runDailyIfDue(guest);
    expect(await w.json(mixed), before, reason: 'no positive evidence');
    expect(await w.listed(), isNot(contains(mixed)));
    expect(await w.backups.restore(guest, mixed), isA<Err<void, AppFailure>>());
  });

  test('a confirmed deletion scrubs legacy backups while the account\'s rows '
      'still prove what is its', () async {
    final mixed = await mixedLegacy(_a);
    await upgradeAndList(); // boundary; maintenance not run
    expect(await w.json(mixed), contains(_secret));
    await w.app.owners.accountDeleted(_a);
    expect(await w.json(mixed), isNot(contains(_secret)));
    expect(await w.json(mixed), contains(_kept));
    expect((await guestBackupVisibility(w.db, guest)).hides(mixed), isTrue);
  });

  test('crash before recording: everything of a guest hidden; recording '
      'happens once and never moves; a restart keeps it', () async {
    final old = await legacyBackup(guest);
    final before = await guestBackupVisibility(w.db, guest);
    expect(before.legacyUpTo, isNull);
    expect(before.hides(old + 1000), isTrue, reason: 'fail closed');
    await recordLegacyGuestBoundary(w.db, w.store);
    final first = (await guestBackupVisibility(w.db, guest)).legacyUpTo;
    expect(first, old);
    await legacyBackup(guest); // something stored after
    await recordLegacyGuestBoundary(w.db, w.store); // "after a restart"
    expect((await guestBackupVisibility(w.db, guest)).legacyUpTo, first);
  });

  test(
    'backups started while the upgrade records the boundary are new',
    () async {
      final old = await legacyBackup(guest);
      final c1 = w.backups.create(guest, BackupReason.daily);
      final c2 = w.backups.create(guest, BackupReason.preImport);
      final ids = [
        for (final r in await Future.wait([c1, c2]))
          r.when(ok: (b) => b.id, err: (f) => fail(f.code)),
      ];
      final v = await guestBackupVisibility(w.db, guest);
      expect(v.hides(old), isTrue);
      expect(ids.map(v.hides), [false, false]);
    },
  );

  test('a recreated backups file (ids start again) exposes nothing; new '
      'guest backups under the old boundary are hidden too', () async {
    await w.write(guest, [w.task(guest, _secret, 'Secret plan')]);
    for (var i = 0; i < 3; i++) {
      await legacyBackup(guest);
    }
    await upgradeAndList();
    await w.store.customStatement('DELETE FROM backups');
    await w.store.customStatement('DELETE FROM sqlite_sequence');
    final fresh = await w.backup(guest);
    expect(fresh, 1);
    expect(await w.listed(), isEmpty, reason: 'fail closed, never exposed');
  });

  test('accounts\' own backups are never quarantined; A -> B -> A and a '
      'later move behave as before', () async {
    final mixed = await mixedLegacy(_a);
    await w.app.signIn(_a);
    final aOld = await legacyBackup(_a);
    expect(await upgradeAndList(), contains(aOld));
    await w.app.signIn(_b);
    await w.app.signIn(_a);
    expect(await w.listed(), contains(aOld));
    await w.app.owners.signOut();
    await w.write(guest, [
      w.task(guest, '01928c3e-0000-7000-8000-0000000008c1', 'For B'),
    ]);
    final g = await w.backup(guest);
    expect(await w.listed(), [g]);
    await w.promote(_b);
    await w.app.owners.signOut();
    expect(await w.listed(), isEmpty);
    expect((await guestBackupVisibility(w.db, guest)).hides(mixed), isTrue);
  });

  test('a quarantined backup is never the last restorable one kept', () async {
    await w.write(guest, [w.task(guest, _kept, 'Kept')]);
    final old = await legacyBackup(guest);
    await upgradeAndList();
    for (var i = 0; i < 7; i++) {
      await w.store
          .into(w.store.backups)
          .insert(
            BackupsCompanion.insert(
              createdAt: ownerAppNow.millisecondsSinceEpoch + i + 1,
              reason: 'daily',
              appSchemaVersion: 20,
              json: '{"pad":"${'a' * (maxImportBytes + 1)}"}',
              owner: Value(guest),
            ),
          );
    }
    await pruneKeepingRestorable(
      w.store,
      guest,
      'daily',
      7,
      hidden: (await guestBackupVisibility(w.db, guest)).hides,
    );
    final ids = [
      for (final r in await w.store.select(w.store.backups).get()) r.id,
    ];
    expect(ids, isNot(contains(old)));
  });

  test('the quarantine and scrub change no rows, owners, outbox or '
      'revisions', () async {
    final mixed = await mixedLegacy(_a);
    Future<String> state() async => [
      for (final r in await w.db.select(w.db.occurrences).get())
        '${r.id}|${r.userId}|${r.title}|${r.deletedAt}',
      (await w.db.select(w.db.changeLog).get()).length,
      await writeRevision(w.db, guest),
      await writeRevision(w.db, _a),
    ].join(';');
    final was = await state();
    await upgradeAndList();
    await w.backups.runDailyIfDue(guest);
    await w.backups.restore(guest, mixed);
    final now = await state();
    // The daily backup is the only write: it changes no rows.
    expect(now, was);
  });
}
