import 'dart:convert';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/owner_meta.dart';
import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/data/owners/account_meta.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/sync/guest_sessions.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/profile/settings_difference.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';
import '../writes/write_harness.dart';

// CR-160: which account screen the app shows, read from this device's
// owners (docs/cr-160-ownership-policy.md §2–§4).

const _guest = '01928c3e-0000-7000-8000-0000000000f0';
const _a = '01928c3e-0000-7000-8000-00000000000a';
final _t = DateTime.utc(2026, 10, 23, 9);

Occurrence _task(String id) => occurrenceFixture().copyWith(
  id: '01928c3e-0000-7000-8000-0000000001$id',
  userId: _guest,
  seriesId: null,
);

void main() {
  late WriteHarness h;

  Future<AccountGate> gate({
    String? account,
    bool browser = false,
    bool settled = false,
  }) => readAccountGate(
    h.db,
    accountId: account,
    email: 'sam@example.com',
    browser: browser,
    settled: settled,
  );

  Future<void> signIn(String id) => signInOwner(
    h.db,
    id,
    h.hlc,
    freshProfile: (a) =>
        profileFixture().copyWith(id: a, tzId: 'Europe/Berlin'),
  );

  setUp(() async {
    h = WriteHarness(_t);
    await h.writes.apply(
      WriteBatch(
        userId: _guest,
        profile: profileFixture().copyWith(id: _guest),
        occurrences: [_task('01'), _task('02')],
      ),
    );
  });
  tearDown(() => h.dispose());

  test('nothing to show: the planner', () async {
    expect(await gate(), isA<NoAccountGate>());
  });

  test('A3 while the signed-out mark is set, also with an account', () async {
    await setSignedOutGate(h.db);
    expect(await gate(), isA<SignedOutGate>());
    expect(await gate(account: _a), isA<SignedOutGate>());
    await clearSignedOutGate(h.db);
    expect(await gate(), isA<NoAccountGate>());
  });

  test('G1: the guest has eligible tasks; a recorded choice ends it', () async {
    final g = await gate(account: _a);
    expect(g, isA<GuestWorkGate>());
    expect((g as GuestWorkGate).eligible, 2);
    expect(g.email, 'sam@example.com');
    await recordGuestChoice(h.db, _a, GuestChoice.keepSeparate);
    expect(await gate(account: _a), isA<NoAccountGate>());
  });

  test('G1b once: ineligible guest work, counted, then gone', () async {
    await rotateGuestSession(h.db); // the tasks are from an older session
    expect(await gate(account: _a), isA<NoAccountGate>());
    await signIn(_a);
    final g = await gate(account: _a);
    expect(g, isA<GuestNoticeGate>());
    expect((g as GuestNoticeGate).count, 2);
    await clearGuestNotice(h.db, _a);
    expect(await gate(account: _a), isA<NoAccountGate>());
  });

  group('B1', () {
    Future<void> keepGuest(Profile device) => h.db
        .into(h.db.localMeta)
        .insertOnConflictUpdate(
          LocalMetaCompanion.insert(
            key: guestSettingsKey(_a),
            value: jsonEncode(device.toJson()),
          ),
        );

    setUp(() async {
      await rotateGuestSession(h.db);
      await signIn(_a);
      await clearGuestNotice(h.db, _a);
    });

    test('after the first sync, only when a shown setting differs', () async {
      await keepGuest(
        profileFixture().copyWith(id: _guest, tzId: 'Asia/Tokyo'),
      );
      expect(
        await gate(account: _a),
        isA<NoAccountGate>(),
        reason: 'unsettled',
      );
      final g = await gate(account: _a, settled: true);
      expect(g, isA<SettingsChoiceGate>());
      expect((g as SettingsChoiceGate).fields, [SettingsField.timeZone]);
    });

    test('Decide later keeps the snapshot and asks no more', () async {
      await keepGuest(
        profileFixture().copyWith(id: _guest, tzId: 'Asia/Tokyo'),
      );
      await deferGuestSettings(h.db, _a, later: true);
      expect(await gate(account: _a, settled: true), isA<NoAccountGate>());
      expect(await guestSettingsDeferred(h.db, _a), isTrue);
      await deferGuestSettings(h.db, _a, later: false);
      expect(await gate(account: _a, settled: true), isA<SettingsChoiceGate>());
    });

    test('nothing differs that B1 shows: no B1', () async {
      await keepGuest(
        profileFixture().copyWith(
          id: _guest,
          tzId: 'Europe/Berlin',
          settings: const Settings(snapMinutes: 15),
        ),
      );
      expect(await gate(account: _a, settled: true), isA<NoAccountGate>());
    });
  });

  test('web: an unfinished removal comes first; native never', () async {
    await signIn(_a);
    await beginAccountRemoval(h.db, _a);
    final g = await gate(browser: true);
    expect(g, isA<RemovalPendingGate>());
    expect((g as RemovalPendingGate).accountIds, [_a]);
    expect(await gate(), isA<NoAccountGate>());
  });

  test('the deletion summary counts the owner tasks and changes', () async {
    final s = await ownerSummary(h.db, _guest);
    expect(s.tasks, 2);
    expect(s.pending, greaterThan(0));
    expect(await ownerSummary(h.db, _a), (tasks: 0, pending: 0));
  });
}
