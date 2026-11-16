import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/sync/guest_sessions.dart';
import 'package:dottoday/data/sync/guest_settings_choice.dart';
import 'package:dottoday/data/sync/outbox.dart';
import 'package:dottoday/data/sync/sync_gateway.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/onboarding/starter_habits.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/fixtures.dart';
import '../../support/fake_sync_server.dart';
import '../../support/sync_device.dart';
import '../writes/write_harness.dart';

// CR-160 (ED-193): two accounts on one device. Every row and outbox entry
// has one owner; signing in as B never uploads, shows or merges A's data;
// A's unsynced work waits for A. One FakeSyncServer per account stands in
// for RLS: each only ever sees what was pushed as that account.

const _a = '01928c3e-0000-7000-8000-00000000000a';
const _b = '01928c3e-0000-7000-8000-00000000000b';
final _t = DateTime.utc(2026, 10, 23, 9);

Occurrence _task(String owner, String id, String title) => occurrenceFixture()
    .copyWith(id: '01928c3e-0000-7000-8000-0000000001$id', userId: owner)
    .copyWith(title: title);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  late FakeSyncServer serverA;
  late FakeSyncServer serverB;
  late SyncDevice device;

  Future<void> write(String owner, List<Occurrence> rows) async =>
      device.h.writes.apply(WriteBatch(userId: owner, occurrences: rows));

  Future<List<String>> titles(String owner) async => [
    for (final o in await (device.h.db.select(
      device.h.db.occurrences,
    )..where((o) => o.userId.equals(owner))).get())
      o.title,
  ];

  Future<String?> shown() async =>
      (await DriftSettingsRepository(device.h.db).findLocalProfile())?.id;

  /// Every outbox entry belongs to the owner of the row it changes.
  Future<void> expectOneOwnerEach() async {
    final db = device.h.db;
    final owners = <String, String>{
      for (final p in await db.select(db.profiles).get()) p.id: p.id,
      for (final o in await db.select(db.occurrences).get()) o.id: o.userId,
    };
    for (final c in await db.select(db.changeLog).get()) {
      expect(c.ownerId, owners[c.entityId], reason: '${c.entity} ${c.field}');
    }
  }

  /// A device used as a guest, then A signed in, wrote, synced and signed
  /// out (signing out only stops sync: the rows stay A's).
  setUp(() async {
    serverA = FakeSyncServer(_a);
    serverB = FakeSyncServer(_b);
    device = SyncDevice(serverA, _t);
    await device.start(); // guest 'device-local' adopted into A
    await write(_a, [_task(_a, '01', 'A synced')]);
    await device.sync();
    // Signed out; offline work stays A's.
    await write(_a, [_task(_a, '02', 'A offline')]);
  });
  tearDown(() => device.close());

  test('B signs in: none of A goes up, shows, or changes owner', () async {
    expect(await device.signIn(_b), OwnerChange.newAccount);
    final run = await SyncDevice.engineFor(device, serverB).run(_b);

    // Server side (RLS-scoped): B's account holds only B's profile.
    expect(serverB.table('occurrences'), isEmpty);
    expect(serverB.table('profiles').keys, [_b]);
    expect(run.pushed, greaterThan(0));
    // The app shows B, and B's rows only.
    expect(await shown(), _b);
    expect(await titles(_b), isEmpty);
    // A's rows and pending change are A's, untouched.
    expect(await titles(_a), unorderedEquals(['A synced', 'A offline']));
    final pending = await device.h.db.select(device.h.db.changeLog).get();
    expect(
      pending.map((c) => c.ownerId).toSet().difference({'device-local'}),
      {_a},
      reason: "A's pending changes stay A's (the device's guest keeps its own)",
    );
    await expectOneOwnerEach();
  });

  test("A's unsynced work goes up when A signs back in, never to B", () async {
    await device.signIn(_b);
    final engineB = SyncDevice.engineFor(device, serverB);
    await engineB.run(_b);
    await write(_b, [_task(_b, '03', 'B task')]);
    await engineB.run(_b);

    expect(await device.signIn(_a), OwnerChange.returned);
    expect(await shown(), _a);
    await device.sync();

    final upA = {
      for (final r in serverA.table('occurrences').values) r['title'],
    };
    expect(upA, {'A synced', 'A offline'});
    final upB = {
      for (final r in serverB.table('occurrences').values) r['title'],
    };
    expect(upB, {'B task'});
    final left = await device.h.db.select(device.h.db.changeLog).get();
    expect(left.where((c) => c.ownerId == _a || c.ownerId == _b), isEmpty);
    await expectOneOwnerEach();
  });

  test("B's outbox count and batches never include A's entries", () async {
    await device.signIn(_b);
    final outbox = Outbox(device.h.db);
    expect(await outbox.watchCount(_a).first, greaterThan(0));
    expect(await outbox.watchCount(_b).first, greaterThan(0));
    for (final batch in await outbox.batches(_b)) {
      expect(batch.changes.map((c) => c.owner).toSet(), {_b});
      expect(
        batch.changes.map((c) => c.id),
        isNot(contains(_task(_a, '02', '').id)),
      );
    }
  });

  test('only a guest is adopted: an account is never re-keyed', () async {
    await device.signIn(_b);
    final profiles = await device.h.db.select(device.h.db.profiles).get();
    expect(
      profiles.map((p) => p.id),
      unorderedEquals(['device-local', _a, _b]),
    );
    // A third account: A and B both stay as they are.
    const c = '01928c3e-0000-7000-8000-00000000000c';
    expect(await device.signIn(c), OwnerChange.newAccount);
    expect(await titles(_a), hasLength(2));
    expect(await isAccount(device.h.db, _a), isTrue);
  });

  // Criterion 2 (owner direction 2026-11-08): signing out hides the
  // account at once; its rows and pending change stay its own.
  group('signing out', () {
    test(
      "hides A's tasks and profile; keeps them, and the outbox, A's",
      () async {
        await signOutOwner(device.h.db);
        expect(
          await shown(),
          'device-local',
          reason: "only the device's own guest (no tasks) may show, never A",
        );
        expect(await titles(_a), hasLength(2), reason: 'nothing deleted');
        final pending = await device.h.db.select(device.h.db.changeLog).get();
        expect(pending, isNotEmpty);
        expect(
          pending
              .where((c) => c.ownerId != 'device-local')
              .map((c) => c.ownerId)
              .toSet(),
          {_a},
        );
      },
    );

    test('the next person starts as a new guest, never on A', () async {
      await signOutOwner(device.h.db);
      // The next person uses the device's guest plan.
      expect(await shown(), 'device-local');
      await device.h.writes.apply(
        WriteBatch(
          userId: 'device-local',
          occurrences: [_task('device-local', '20', 'Guest task')],
        ),
      );
      // That guest signs in as B: only the guest's work moves.
      expect(
        await device.signIn(_b, choice: GuestChoice.bringIn),
        OwnerChange.newAccount,
      );
      await SyncDevice.engineFor(device, serverB).run(_b);
      final upB = {
        for (final r in serverB.table('occurrences').values) r['title'],
      };
      expect(upB, {'Guest task'});
      expect(await titles(_a), hasLength(2));
    });

    test(
      'A signs back in: its tasks show again and its changes go up',
      () async {
        await signOutOwner(device.h.db);
        expect(await device.signIn(_a), OwnerChange.returned);
        expect(await shown(), _a);
        await device.sync();
        expect(serverA.table('occurrences'), hasLength(2));
      },
    );
  });

  // Owner 2026-11-08: guest work has no authenticated owner; it never goes
  // to whoever signs in next without an informed choice.
  group("someone else's guest work", () {
    late SyncDevice shared;

    setUp(() async {
      shared = SyncDevice(serverB, _t, name: 'shared');
      await shared.h.writes.apply(
        WriteBatch(
          userId: 'g',
          profile: profileFixture().copyWith(id: 'g'),
          occurrences: [_task('g', '30', 'Guest task')],
        ),
      );
    });
    tearDown(() => shared.close());

    Future<String?> shownOn(SyncDevice d) async =>
        (await DriftSettingsRepository(d.h.db).findLocalProfile())?.id;

    test('signing in changes nothing until the person chooses', () async {
      expect(await shared.signIn(_b), OwnerChange.guestChoiceNeeded);
      final db = shared.h.db;
      expect(await shownOn(shared), 'g');
      expect((await db.select(db.profiles).get()).map((p) => p.id), ['g']);
      expect((await db.select(db.occurrences).getSingle()).userId, 'g');
      expect(await isAccount(db, _b), isFalse);
    });

    test('keep separate (the default): B starts with only its own', () async {
      expect(
        await shared.signIn(_b, choice: GuestChoice.keepSeparate),
        OwnerChange.newAccount,
      );
      expect(await shownOn(shared), _b);
      await shared.sync();
      expect(serverB.table('occurrences'), isEmpty);
      final db = shared.h.db;
      expect((await db.select(db.occurrences).getSingle()).userId, 'g');
      final log = await db.select(db.changeLog).get();
      expect(log.where((c) => c.ownerId == 'g'), isNotEmpty);
      // Signed out again: the device's own guest plan, never B's.
      await signOutOwner(db);
      expect(await shownOn(shared), 'g');
    });

    test('bring them in: moved once, on an explicit choice', () async {
      expect(
        await shared.signIn(_b, choice: GuestChoice.bringIn),
        OwnerChange.newAccount,
      );
      await shared.sync();
      await shared.sync();
      expect(serverB.table('occurrences'), hasLength(1));
      expect(
        await shared.signIn(_b, choice: GuestChoice.bringIn),
        OwnerChange.unchanged,
        reason: 'a repeated choice moves nothing again',
      );
    });

    test("a guest's settings alone are never copied into an existing "
        'account; they wait for the explicit choice (B1)', () async {
      final fresh = SyncDevice(serverB, _t, name: 'fresh');
      addTearDown(fresh.close);
      await fresh.h.writes.apply(
        WriteBatch(
          userId: 'g0',
          profile: profileFixture().copyWith(id: 'g0', tzId: 'Asia/Tokyo'),
        ),
      );
      expect(await fresh.signIn(_b), OwnerChange.newAccount);
      expect(await pendingGuestSettings(fresh.h.db, _b), isNotNull);
      expect(await shownOn(fresh), _b);
      // The guest's profile stays its own.
      final profiles = await fresh.h.db.select(fresh.h.db.profiles).get();
      expect(profiles.map((p) => p.id), unorderedEquals(['g0', _b]));
    });
  });

  // Owner 2026-11-08: only guest work from the current, uninterrupted guest
  // session may move; decided in the data layer when the move runs.
  group('guest eligibility', () {
    late SyncDevice shared;

    setUp(() async {
      shared = SyncDevice(serverB, _t, name: 'elig');
      await shared.h.writes.apply(
        WriteBatch(
          userId: 'g',
          profile: profileFixture().copyWith(id: 'g'),
          occurrences: [_task('g', '40', 'Before')],
        ),
      );
    });
    tearDown(() => shared.close());

    Future<void> signOutAndBack() async {
      // Someone signs in (keeping the guest separate) and out again: the
      // guest session ends twice.
      await shared.signIn(_a, choice: GuestChoice.keepSeparate);
      await signOutOwner(shared.h.db);
    }

    test('work from before the last change of owner can never move', () async {
      await signOutAndBack();
      expect(await guestWork(shared.h.db), (eligible: 0, ineligible: 1));
      // Even a stale or repeated "bring in" moves nothing.
      expect(
        await shared.signIn(_b, choice: GuestChoice.bringIn),
        OwnerChange.newAccount,
      );
      final row = await shared.h.db.select(shared.h.db.occurrences).getSingle();
      expect(row.userId, 'g');
      final notice = await (shared.h.db.select(
        shared.h.db.localMeta,
      )..where((m) => m.key.equals('guest_notice:$_b'))).getSingleOrNull();
      expect(notice?.value, 'ineligible', reason: 'G1b is shown once');
    });

    test('a mix: only the current session moves', () async {
      await signOutAndBack();
      await shared.h.writes.apply(
        WriteBatch(userId: 'g', occurrences: [_task('g', '41', 'After')]),
      );
      expect(await guestWork(shared.h.db), (eligible: 1, ineligible: 1));
      await shared.signIn(_b, choice: GuestChoice.bringIn);
      final rows = await shared.h.db.select(shared.h.db.occurrences).get();
      expect(
        {for (final o in rows) o.title: o.userId},
        {'Before': 'g', 'After': _b},
      );
      await shared.sync();
      final up = {
        for (final r in serverB.table('occurrences').values) r['title'],
      };
      expect(up, {'After'});
    });

    test('a clock moved back or forward changes nothing', () async {
      await signOutAndBack();
      shared.h.clock.advance(const Duration(days: -400));
      await shared.h.writes.apply(
        WriteBatch(
          userId: 'g',
          occurrences: [
            _task('g', '40', 'Before').copyWith(title: 'Before, edited'),
          ],
        ),
      );
      shared.h.clock.advance(const Duration(days: 800));
      expect(
        (await guestWork(shared.h.db)).eligible,
        0,
        reason: 'editing old work in a new session does not make it new',
      );
    });

    test('a sign-in that waits for the choice keeps the session', () async {
      expect(await shared.signIn(_b), OwnerChange.guestChoiceNeeded);
      expect(await shared.signIn(_b), OwnerChange.guestChoiceNeeded);
      expect((await guestWork(shared.h.db)).eligible, 1);
      expect(
        await shared.signIn(_b, choice: GuestChoice.bringIn),
        OwnerChange.newAccount,
      );
    });

    test(
      'the session survives a restart (it is stored, not in memory)',
      () async {
        final before = await currentGuestSession(shared.h.db);
        final again = WriteHarness(_t, db: shared.h.db);
        expect(await currentGuestSession(again.db), before);
      },
    );
  });

  // Owner 2026-11-08 (policy §4): after the server confirms the deletion,
  // the copy here is hidden at once and removed; nothing of it ever becomes
  // guest data or goes to another account, even after an interruption.
  group('a deleted account', () {
    test('is hidden at once and never goes to the next account', () async {
      await beginAccountRemoval(device.h.db, _a);
      expect(await isRemovalPending(device.h.db, _a), isTrue);
      expect(await shown(), isNot(_a));
      expect(await device.signIn(_b), OwnerChange.newAccount);
      await SyncDevice.engineFor(device, serverB).run(_b);
      expect(serverB.table('occurrences'), isEmpty);
    });

    test('removal takes every row, pending change and owner value of A '
        'and nothing of anyone else', () async {
      await device.signIn(_b);
      await write(_b, [_task(_b, '50', 'B task')]);
      await beginAccountRemoval(device.h.db, _a);
      await finishAccountRemoval(device.h.db, _a);
      final db = device.h.db;
      expect(await titles(_a), isEmpty);
      expect(
        (await db.select(db.changeLog).get()).where((c) => c.ownerId == _a),
        isEmpty,
      );
      expect(
        (await db.select(db.profiles).get()).map((p) => p.id),
        unorderedEquals(['device-local', _b]),
      );
      final keys = [for (final m in await db.select(db.localMeta).get()) m.key];
      expect(keys.where((k) => k.endsWith(':$_a')), isEmpty);
      expect(await titles(_b), ['B task']);
      expect(await pendingRemovals(db), isEmpty);
    });

    test(
      'an interrupted removal stays pending and hidden; a retry finishes',
      () async {
        await beginAccountRemoval(device.h.db, _a);
        await expectLater(
          finishAccountRemoval(
            device.h.db,
            _a,
            alsoRemove: () async => throw StateError('backup store busy'),
          ),
          throwsA(isA<StateError>()),
        );
        expect(await pendingRemovals(device.h.db), [_a]);
        expect(await shown(), isNot(_a));
        expect(await titles(_a), hasLength(2), reason: 'nothing half-removed');
        expect(
          await isAccount(device.h.db, _a),
          isTrue,
          reason: 'never a guest',
        );
        await finishAccountRemoval(device.h.db, _a);
        await finishAccountRemoval(device.h.db, _a); // repeated: harmless
        expect(await titles(_a), isEmpty);
      },
    );
  });

  group('the server guard (fake of migration 0014)', () {
    test("a push of A's change while signed in as B is refused", () {
      expect(
        () => serverB.forDevice().push([
          const PushChange(
            owner: _a,
            entity: 'occurrences',
            id: '01928c3e-0000-7000-8000-0000000001ff',
            hlc: '0000000000001-0000-node',
            fields: {'title': 'leak'},
          ),
        ]),
        throwsA(isA<SyncGatewayException>()),
      );
      expect(serverB.table('occurrences'), isEmpty);
    });
  });

  group('interrupted (criterion 9)', () {
    late SyncDevice guest;

    setUp(() async {
      guest = SyncDevice(serverB, _t, name: 'g');
      await guest.h.writes.apply(
        WriteBatch(
          userId: 'g',
          profile: profileFixture().copyWith(id: 'g'),
          occurrences: [_task('g', '10', 'Guest')],
        ),
      );
    });
    tearDown(() => guest.close());

    test(
      'a failed adoption leaves the guest whole; a retry adopts once',
      () async {
        // The last step of the transaction fails.
        await guest.h.db.customStatement(
          'CREATE TEMP TRIGGER boom BEFORE INSERT ON local_meta '
          "WHEN NEW.key LIKE 'owner_account:%' "
          "BEGIN SELECT RAISE(ABORT, 'boom'); END",
        );
        await expectLater(
          guest.signIn(_b, choice: GuestChoice.bringIn),
          throwsA(anything),
        );
        final db = guest.h.db;
        expect((await db.select(db.profiles).get()).map((p) => p.id), ['g']);
        expect((await db.select(db.occurrences).getSingle()).userId, 'g');
        final log = await db.select(db.changeLog).get();
        expect(log.map((c) => c.ownerId).toSet(), {'g'});
        expect(await isAccount(db, _b), isFalse);

        await db.customStatement('DROP TRIGGER boom');
        expect(
          await guest.signIn(_b, choice: GuestChoice.bringIn),
          OwnerChange.newAccount,
        );
        await guest.sync();
        expect(serverB.table('occurrences'), hasLength(1));
      },
    );

    test('a push cut off mid-way resumes without duplicates', () async {
      await guest.signIn(_b, choice: GuestChoice.bringIn);
      serverB.failNext = SyncTrouble.offline;
      await expectLater(guest.sync(), throwsA(isA<SyncGatewayException>()));
      final db = guest.h.db;
      expect((await db.select(db.occurrences).getSingle()).userId, _b);
      await guest.sync();
      await guest.sync();
      expect(serverB.table('occurrences'), hasLength(1));
      expect(serverB.table('profiles').keys, [_b]);
      final left = await db.select(db.changeLog).get();
      expect(left.where((c) => c.ownerId == _b), isEmpty);
    });

    test(
      "a new account's profile that can't be made changes nothing",
      () async {
        await expectLater(
          signInOwner(
            device.h.db,
            _b,
            device.h.hlc,
            freshProfile: (_) => throw StateError('no zone'),
          ),
          throwsA(isA<StateError>()),
        );
        expect(await shown(), _a);
        expect(
          (await device.h.db.select(device.h.db.profiles).get()).map(
            (p) => p.id,
          ),
          unorderedEquals(['device-local', _a]),
        );
      },
    );
  });

  // Criterion 8: the same person onboarding on two devices (one as a
  // guest later signed in) plants one starter, not two.
  test('starters planted on two devices merge into one', () async {
    final berlin = tz.getLocation('Europe/Berlin');
    final shape = DayShape(
      wakeUtc: tz.TZDateTime(berlin, 2026, 10, 24, 7).toUtc(),
      bedUtc: tz.TZDateTime(berlin, 2026, 10, 24, 22).toUtc(),
    );
    List<Occurrence> plant(String owner) => starterTasks(
      picked: {StarterHabit.lunch, StarterHabit.read},
      titleOf: (h) => h.name,
      shape: shape,
      zone: berlin,
      userId: owner,
      nowUtc: _t,
    );
    await write(_a, plant(_a));
    await device.sync();

    final phone = SyncDevice(serverA, _t, name: 'phone');
    addTearDown(phone.close);
    await phone.h.writes.apply(
      WriteBatch(
        userId: 'g2',
        profile: profileFixture().copyWith(id: 'g2'),
        occurrences: plant('g2'),
      ),
    );
    expect(
      await phone.signIn(_a, choice: GuestChoice.bringIn),
      OwnerChange.newAccount,
    );
    await phone.sync();
    final names = [
      for (final r in serverA.table('occurrences').values) r['title'],
    ];
    expect(names.where((t) => t == 'lunch'), hasLength(1));
    expect(names.where((t) => t == 'read'), hasLength(1));
  });
}
