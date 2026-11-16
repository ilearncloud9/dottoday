import 'dart:convert';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/sync/guest_settings_choice.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/reveal_hint.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/fake_sync_server.dart';
import '../../support/sync_device.dart';

// An account's first sync on a device (docs/09 M6.4, CR-160 criteria
// 5–7): a guest's work joins the account once and never over it; the
// account's settings stay unless the person chooses otherwise.

const _account = '01928c3e-0000-7000-8000-0000000000ff';
final _t = DateTime.utc(2026, 10, 23, 9);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  late FakeSyncServer server;
  late SyncDevice laptop;

  setUp(() async {
    server = FakeSyncServer(_account);
    laptop = SyncDevice(server, _t, name: 'laptop');
    await laptop.start();
    await laptop.h.writes.apply(
      WriteBatch(
        userId: _account,
        profile: profileFixture().copyWith(
          id: _account,
          tzId: 'Europe/Berlin',
          locale: 'de',
          updatedAt: _t,
        ),
        occurrences: [
          occurrenceFixture().copyWith(userId: _account, title: 'Server'),
        ],
      ),
    );
    await laptop.sync();
  });
  tearDown(() => laptop.close());

  Future<String?> tzOf(SyncDevice d) async =>
      (await DriftSettingsRepository(d.h.db).findLocalProfile())?.tzId;

  test(
    'a returning account: its settings win over a new device defaults',
    () async {
      final phone = SyncDevice(server, _t.add(const Duration(hours: 1)));
      addTearDown(phone.close);
      await phone.start(); // a fresh profile, America/New_York defaults
      await phone.sync();
      expect(await tzOf(phone), 'Europe/Berlin');
      expect(server.table('profiles')[_account]!['tz_id'], 'Europe/Berlin');
      expect(server.table('profiles')[_account]!['locale'], 'de');
    },
  );

  /// A phone used as a guest, then signed in to the existing account.
  Future<SyncDevice> guestPhone(
    Duration after, {
    Profile Function(Profile p)? choose,
    List<Occurrence> tasks = const [],
    List<RevealHint> hints = const [],
    GuestChoice? choice,
  }) async {
    final phone = SyncDevice(server, _t.add(after), name: 'phone');
    addTearDown(phone.close);
    final guest = profileFixture().copyWith(id: 'guest');
    await phone.h.writes.apply(
      WriteBatch(
        userId: 'guest',
        profile: choose?.call(guest) ?? guest,
        occurrences: tasks,
        revealHints: hints,
      ),
    );
    expect(
      await phone.signIn(_account, choice: choice),
      OwnerChange.newAccount,
    );
    return phone;
  }

  // CR-160 criterion 7: the account's settings stay; the guest's are kept
  // aside for an explicit choice (not designed yet), never applied.
  test("a guest's settings never replace the account's", () async {
    final phone = await guestPhone(
      const Duration(hours: 1),
      choose: (p) => p.copyWith(tzId: 'Asia/Tokyo', locale: 'fr'),
    );
    await phone.sync();
    expect(await tzOf(phone), 'Europe/Berlin');
    expect(server.table('profiles')[_account]!['tz_id'], 'Europe/Berlin');
    expect(server.table('profiles')[_account]!['locale'], 'de');
    final kept = await (phone.h.db.select(
      phone.h.db.localMeta,
    )..where((m) => m.key.equals('guest_settings:$_account'))).getSingle();
    expect(jsonDecode(kept.value), containsPair('tz_id', 'Asia/Tokyo'));
    final left = await phone.h.db.select(phone.h.db.changeLog).get();
    expect(
      left.where((c) => c.ownerId == _account),
      isEmpty,
      reason: 'settled once; nothing waits to overwrite them later',
    );
  });

  group("choosing the guest's settings (criterion 7)", () {
    test('keep account settings: nothing changes, the copy goes', () async {
      final phone = await guestPhone(
        const Duration(hours: 1),
        choose: (p) => p.copyWith(tzId: 'Asia/Tokyo'),
      );
      await phone.sync();
      expect(await pendingGuestSettings(phone.h.db, _account), isNotNull);
      await keepAccountSettings(phone.h.db, _account);
      expect(await pendingGuestSettings(phone.h.db, _account), isNull);
      await phone.sync();
      expect(await tzOf(phone), 'Europe/Berlin');
      expect(server.table('profiles')[_account]!['tz_id'], 'Europe/Berlin');
    });

    test("use this device's settings: one ordinary edit that syncs", () async {
      final phone = await guestPhone(
        const Duration(hours: 1),
        choose: (p) => p.copyWith(tzId: 'Asia/Tokyo', locale: 'fr'),
      );
      await phone.sync();
      final account = (await DriftSettingsRepository(
        phone.h.db,
      ).findLocalProfile())!;
      final r = await useGuestSettings(phone.h.db, phone.h.writes, account);
      expect(r, isA<Ok<void, AppFailure>>());
      expect(await pendingGuestSettings(phone.h.db, _account), isNull);
      await phone.sync();
      expect(await tzOf(phone), 'Asia/Tokyo');
      expect(server.table('profiles')[_account]!['tz_id'], 'Asia/Tokyo');
      expect(server.table('profiles')[_account]!['locale'], 'fr');
    });

    test('nothing to choose for a new account', () async {
      final fresh = FakeSyncServer('01928c3e-0000-7000-8000-0000000000ab');
      final phone = SyncDevice(fresh, _t, name: 'new2');
      addTearDown(phone.close);
      await phone.h.writes.apply(
        WriteBatch(
          userId: 'guest',
          profile: profileFixture().copyWith(id: 'guest'),
        ),
      );
      await phone.signIn(fresh.userId);
      await phone.sync();
      expect(await pendingGuestSettings(phone.h.db, fresh.userId), isNull);
    });
  });

  // Criterion 5: a new account (no settings on the server yet) gets the
  // guest's profile and every row, once.
  test("a new account takes the guest's settings and rows, once", () async {
    final fresh = FakeSyncServer('01928c3e-0000-7000-8000-0000000000aa');
    final phone = SyncDevice(fresh, _t, name: 'new');
    addTearDown(phone.close);
    await phone.h.writes.apply(
      WriteBatch(
        userId: 'guest',
        profile: profileFixture().copyWith(id: 'guest', tzId: 'Asia/Tokyo'),
        occurrences: [occurrenceFixture().copyWith(userId: 'guest')],
      ),
    );
    await phone.signIn(fresh.userId, choice: GuestChoice.bringIn);
    await phone.sync();
    await phone.sync();
    expect(fresh.table('profiles')[fresh.userId]!['tz_id'], 'Asia/Tokyo');
    expect(fresh.table('occurrences'), hasLength(1));
    expect(await phone.h.db.select(phone.h.db.occurrences).get(), hasLength(1));
    final left = await phone.h.db.select(phone.h.db.changeLog).get();
    expect(left.where((c) => c.ownerId == fresh.userId), isEmpty);
  });

  // Criterion 6: guest work is added beside the account's, never over it.
  test("a guest's tasks join the account's; the account's stay", () async {
    final phone = await guestPhone(
      const Duration(hours: 1),
      tasks: [
        occurrenceFixture().copyWith(
          id: '01928c3e-0000-7000-8000-0000000000c1',
          userId: 'guest',
          title: 'Guest',
        ),
      ],
      choice: GuestChoice.bringIn,
    );
    await phone.sync();
    final titles = {
      for (final r in server.table('occurrences').values) r['title'],
    };
    expect(titles, {'Server', 'Guest'});
    final local = await phone.h.db.select(phone.h.db.occurrences).get();
    expect({for (final o in local) o.title}, {'Server', 'Guest'});
    expect({for (final o in local) o.userId}, {_account});
  });

  // Owner 2026-11-08: hint records are the guest's own; they never move,
  // so the account's record stands and nothing duplicates.
  test("the guest's hint records stay the guest's", () async {
    await laptop.h.writes.apply(
      WriteBatch(
        userId: _account,
        revealHints: [
          revealHintFixture(_account, HintId.unstick).copyWith(shownCount: 1),
        ],
      ),
    );
    await laptop.sync();
    final phone = await guestPhone(
      const Duration(seconds: 20),
      hints: [
        revealHintFixture('guest', HintId.unstick).copyWith(shownCount: 2),
      ],
    );
    await phone.sync();
    final hints = await phone.h.db.select(phone.h.db.revealHintsTable).get();
    expect(
      {for (final h in hints) h.userId: h.shownCount},
      {_account: 1, 'guest': 2},
    );
    expect(server.table('reveal_hints'), hasLength(1));
  });

  test('progress: from 0 to all of it', () async {
    final phone = SyncDevice(server, _t.add(const Duration(hours: 1)));
    addTearDown(phone.close);
    await phone.start();
    final seen = <(int, int)>[];
    await phone.engine.run(_account, onProgress: (d, t) => seen.add((d, t)));
    expect(seen.first.$1, 0);
    expect(seen.last.$1, seen.last.$2);
    expect(seen.last.$2, greaterThanOrEqualTo(2));
    // Later runs are not a restore.
    seen.clear();
    await phone.engine.run(_account, onProgress: (d, t) => seen.add((d, t)));
    expect(seen, isEmpty);
  });
}
