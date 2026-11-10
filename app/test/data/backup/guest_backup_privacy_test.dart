import 'dart:convert';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/backup_providers.dart';
import 'package:dottoday/data/backup/drift_backup_service.dart';
import 'package:dottoday/data/backup/guest_backup_cutoff.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/sync/shared_hlc.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/onboarding/starter_habits.dart';
import 'package:dottoday/domain/profile/local_profile_service.dart';
import 'package:dottoday/domain/sync/stable_ids.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:drift/drift.dart' show BooleanExpressionOperators;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/fake_clock.dart';
import '../../support/fake_notification_platform.dart';
import '../../support/owner_app.dart';
import '../../support/shared_action_queue.dart';
import '../../support/timeline_fakes.dart';
import '../writes/write_harness.dart';

// CR-160 guest-backup privacy (P1): a guest backup taken before the guest's
// work moved into an account holds that work. Later guest sessions must not
// list or restore it, whoever calls the backup service; a backup taken after
// the move stays the guest's to restore.

const _a = '01928c3e-0000-7000-8000-00000000000a';
const _promoted = '01928c3e-0000-7000-8000-0000000005a1';

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  late AppDatabase db;
  late OwnerApp app;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    app = OwnerApp(
      db,
      FakeNotificationPlatform(),
      FakeSink(),
      FakeAlarmGateway(),
      SharedActionQueue(),
    );
  });
  tearDown(() async {
    await app.idle();
    app.container.dispose();
    await db.close();
  });

  BackupService backups() => app.container.read(backupServiceProvider);
  BackupDatabase store() => app.container.read(backupDatabaseProvider);

  Future<void> write(String owner, List<Occurrence> rows) async {
    expect(
      await app.container
          .read(writeUseCaseProvider)
          .apply(WriteBatch(userId: owner, occurrences: rows)),
      isA<Ok<void, AppFailure>>(),
    );
    await app.idle();
  }

  Occurrence task(String owner, String id, String title) => occurrenceFixture()
      .copyWith(id: id, userId: owner, seriesId: null, title: title);

  /// The guest's starter task for today (re-keyed when it moves).
  Occurrence starter(String guest) {
    final day = DateTime.utc(
      ownerAppNow.year,
      ownerAppNow.month,
      ownerAppNow.day,
    );
    return occurrenceFixture().copyWith(
      id: starterTaskId(guest, StarterHabit.walk, day),
      userId: guest,
      seriesId: null,
      tzId: 'UTC',
      startUtc: ownerAppNow,
      title: 'Walk',
    );
  }

  Future<int> backup(String owner) async => (await backups().create(
    owner,
    BackupReason.daily,
  )).when(ok: (b) => b.id, err: (f) => fail(f.code));

  Future<void> promote() async {
    expect(await app.signInAs(_a), OwnerChange.guestChoiceNeeded);
    await recordGuestChoice(db, _a, GuestChoice.bringIn);
    await app.signInAs(_a);
  }

  Future<Set<String>> titlesOf(String owner) async => {
    for (final r in await (db.select(
      db.occurrences,
    )..where((o) => o.userId.equals(owner) & o.deletedAt.isNull())).get())
      r.title,
  };

  test(
    'a pre-promotion guest backup holds the promoted work (the risk)',
    () async {
      final guest = await app.shown();
      await write(guest, [task(guest, _promoted, 'Secret plan')]);
      final id = await backup(guest);
      await promote();
      final row = await (store().select(
        store().backups,
      )..where((b) => b.id.equals(id))).getSingle();
      expect(row.json, contains(_promoted));
      expect(jsonDecode(row.json), isA<Map<String, Object?>>());
    },
  );

  test(
    'later guest sessions can neither list nor restore it, even by id',
    () async {
      final guest = await app.shown();
      await write(guest, [task(guest, _promoted, 'Secret plan')]);
      final before = await backup(guest);
      await promote();
      await app.owners.signOut();
      expect(await app.shown(), guest);
      expect(
        (await backups().list()).map((b) => b.id),
        isNot(contains(before)),
      );
      expect(
        await backups().restore(guest, before),
        isA<Err<void, AppFailure>>(),
      );
    },
  );

  test('a re-keyed starter task (which Finding X cannot see) does not come '
      'back to the guest', () async {
    final guest = await app.shown();
    await write(guest, [starter(guest)]);
    final before = await backup(guest);
    await promote();
    await app.owners.signOut();
    final result = await backups().restore(guest, before);
    expect(result, isA<Err<void, AppFailure>>());
    expect(await titlesOf(guest), isNot(contains('Walk')));
  });

  test("after A's deletion is confirmed (P2), the backup comes back without "
      "A's work", () async {
    final guest = await app.shown();
    await write(guest, [task(guest, _promoted, 'Secret plan')]);
    final before = await backup(guest);
    await promote();
    await app.owners.accountDeleted(_a);
    expect(await app.shown(), guest);
    expect((await backups().list()).map((b) => b.id), contains(before));
    expect(await backups().restore(guest, before), isA<Ok<void, AppFailure>>());
    expect(await titlesOf(guest), isNot(contains('Secret plan')));
  });

  test('a guest backup taken after the promotion stays the guest\'s', () async {
    final guest = await app.shown();
    await write(guest, [task(guest, _promoted, 'Secret plan')]);
    await promote();
    await app.owners.signOut();
    await write(guest, [
      task(guest, '01928c3e-0000-7000-8000-0000000005b1', 'Later note'),
    ]);
    final after = await backup(guest);
    expect((await backups().list()).map((b) => b.id), contains(after));
    expect(await backups().restore(guest, after), isA<Ok<void, AppFailure>>());
  });

  test('mixed promoted and kept guest work: the backup is hidden; the kept '
      'work stays live for the guest', () async {
    final guest = await app.shown();
    await write(guest, [task(guest, _promoted, 'Secret plan')]);
    final before = await backup(guest);
    // Not this session's: never moves (only current-session work does).
    await app.owners.signOut();
    await write(guest, [
      task(guest, '01928c3e-0000-7000-8000-0000000005c1', 'Kept'),
    ]);
    final mixed = await backup(guest);
    await promote();
    await app.owners.signOut();
    final listed = (await backups().list()).map((b) => b.id);
    expect(listed, isNot(contains(before)));
    expect(listed, isNot(contains(mixed)));
    expect(
      await titlesOf(guest),
      contains('Secret plan'),
      reason: 'the earlier session\'s work never moved',
    );
  });

  test('a backup read before the move but stored during it is hidden '
      '(the race the fence closes)', () async {
    final guest = await app.shown();
    await write(guest, [task(guest, _promoted, 'Secret plan')]);
    expect(await app.signInAs(_a), OwnerChange.guestChoiceNeeded);
    await recordGuestChoice(db, _a, GuestChoice.bringIn);
    await app.owners.signOut(); // back to the guest, choice recorded
    await write(guest, [
      task(guest, '01928c3e-0000-7000-8000-0000000005d1', 'Also secret'),
    ]);
    late Future<void> move;
    final racing = DriftBackupService(
      db: db,
      backups: store(),
      writes: app.container.read(writeUseCaseProvider),
      clock: FakeClock(ownerAppNow),
      logger: app.container.read(loggerProvider),
      afterRead: () async {
        move = app.signInAs(_a);
        // Give the move every chance to run now: the fence holds it.
        await Future.any([
          move,
          Future<void>.delayed(const Duration(milliseconds: 200)),
        ]);
      },
    );
    final id = (await racing.create(
      guest,
      BackupReason.daily,
    )).when(ok: (b) => b.id, err: (f) => fail(f.code));
    await move;
    final v = await guestBackupVisibility(db, guest);
    expect(v.promotions.single.pending, isFalse);
    expect(v.hides(id), isTrue);
  });

  test('crash after the move, before the cutoff: hidden (fail closed); the '
      'first backup work records it, and only pre-move backups stay '
      'hidden', () async {
    final guest = await app.shown();
    await write(guest, [task(guest, _promoted, 'Secret plan')]);
    final before = await backup(guest);
    expect(await app.signInAs(_a), OwnerChange.guestChoiceNeeded);
    await recordGuestChoice(db, _a, GuestChoice.bringIn);
    // The move commits; the app dies before OwnerSwitch records the cutoff.
    await signInOwner(
      db,
      _a,
      SharedHlc(db, FakeClock(ownerAppNow)),
      freshProfile: (id) => freshAccountProfile(id, 'UTC', 'en', ownerAppNow),
    );
    final pending = await guestBackupVisibility(db, guest);
    expect(pending.promotions.single.pending, isTrue);
    expect(pending.hides(before + 1000), isTrue, reason: 'fail closed');
    // After the restart: A's own backup is the first backup work.
    final aBackup = await backup(_a);
    final cut = await guestBackupVisibility(db, guest);
    expect(cut.promotions.single.pending, isFalse);
    expect(cut.hides(before), isTrue);
    expect(cut.hides(aBackup), isFalse, reason: 'not expanded past A');
    await app.owners.signOut();
    await write(guest, [
      task(guest, '01928c3e-0000-7000-8000-0000000005e1', 'After'),
    ]);
    final after = await backup(guest);
    expect((await backups().list()).map((b) => b.id), [after]);
  });

  test('repeated promotions and A -> B -> A: each move hides what came '
      'before it; account backups are never hidden', () async {
    const b = '01928c3e-0000-7000-8000-00000000000b';
    final guest = await app.shown();
    await write(guest, [task(guest, _promoted, 'For A')]);
    final g1 = await backup(guest);
    await promote();
    final aOwn = await backup(_a);
    await app.owners.signOut();
    await write(guest, [
      task(guest, '01928c3e-0000-7000-8000-0000000005f1', 'For B'),
    ]);
    final g2 = await backup(guest);
    expect((await backups().list()).map((x) => x.id), [g2]);
    expect(await app.signInAs(b), OwnerChange.guestChoiceNeeded);
    await recordGuestChoice(db, b, GuestChoice.bringIn);
    await app.signInAs(b);
    await app.owners.signOut();
    expect(
      (await backups().list()).map((x) => x.id),
      isEmpty,
      reason: 'g1 and g2 both predate a move',
    );
    expect(await backups().restore(guest, g1), isA<Err<void, AppFailure>>());
    expect(await backups().restore(guest, g2), isA<Err<void, AppFailure>>());
    await app.signIn(_a);
    expect((await backups().list()).map((x) => x.id), contains(aOwn));
  });

  test(
    'a refused hidden restore changes nothing: rows, outbox, revision',
    () async {
      final guest = await app.shown();
      await write(guest, [task(guest, _promoted, 'Secret plan')]);
      final before = await backup(guest);
      await promote();
      await app.owners.signOut();
      Future<Object> state() async => [
        for (final r in await db.select(db.occurrences).get())
          '${r.id}|${r.userId}|${r.title}',
        (await db.select(db.changeLog).get()).length,
        await writeRevision(db, guest),
        await writeRevision(db, _a),
      ].join(';');
      final was = await state();
      expect(
        await backups().restore(guest, before),
        isA<Err<void, AppFailure>>(),
      );
      expect(await state(), was);
    },
  );
}
