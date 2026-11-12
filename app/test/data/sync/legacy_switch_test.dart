import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/legacy_outbox.dart';
import 'package:dottoday/data/owners/account_meta.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/sync/legacy_switch.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/fake_sync_server.dart';
import '../../support/sync_device.dart';

// CR-160 blocker 8: a device on which a build before schema 18 signed into
// account B after A. A's rows sit under B here; the first sync after the
// upgrade holds what proves to be another account's, before any push.

const _b = '01928c3e-0000-7000-8000-0000000000bb';
final _t = DateTime.utc(2026, 11, 12, 9);

Occurrence _task(String id) =>
    occurrenceFixture().copyWith(id: id, userId: _b, title: 'Row');

const _aSynced = '01928c3e-0000-7000-8001-000000000001';
const _bSynced = '01928c3e-0000-7000-8001-000000000002';
const _aOffline = '01928c3e-0000-7000-8001-000000000003';
const _bNew = '01928c3e-0000-7000-8001-000000000004';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  late FakeSyncServer server;
  late SyncDevice device;
  AppDatabase db() => device.h.db;

  setUp(() async {
    server = FakeSyncServer(_b);
    device = SyncDevice(server, _t);
    await device.start();
    await device.sync();
  });
  tearDown(() => device.close());

  Future<String?> ownerOf(String id) async =>
      (await db()
              .customSelect(
                'SELECT user_id FROM occurrences WHERE id = ?',
                variables: [Variable<String>(id)],
              )
              .getSingleOrNull())
          ?.read<String>('user_id');

  Future<void> seen(String id) => db().customStatement(
    'INSERT OR REPLACE INTO field_seen (entity, entity_id, field, hlc) '
    "VALUES ('occurrences', ?, 'title', 'x')",
    [id],
  );

  /// The device as the upgrade left it: [aSynced] pulled once (from A's
  /// server, which B can't see unless [aIsB]), B's own synced task, and
  /// A's offline task pending; then B makes a new task after the upgrade.
  Future<void> oldBuildDevice({bool aIsB = false}) async {
    await device.write([_task(_bSynced)]);
    await device.sync();
    await seen(_bSynced);
    await device.write([_task(_aSynced)]);
    if (aIsB) {
      await device.sync(); // it really is B's, on B's server
    } else {
      // Pulled from A's server once: no pending change, B can't see it.
      await db().customStatement(
        "DELETE FROM change_log WHERE entity_id = '$_aSynced'",
      );
      server.foreignIds.add(_aSynced);
    }
    await seen(_aSynced);
    await device.write([_task(_aOffline)]);
    await recordLegacyOutbox(db());
    await device.write([_task(_bNew)]);
  }

  test('a proven switch holds A\'s rows before anything goes up', () async {
    await oldBuildDevice();
    await device.sync();
    expect(await ownerOf(_bSynced), _b);
    expect(await ownerOf(_bNew), _b);
    expect(await ownerOf(_aSynced), isNot(_b));
    expect(await ownerOf(_aOffline), await ownerOf(_aSynced));
    final up = server.table('occurrences');
    expect(up.keys, contains(_bNew));
    expect(up.keys, isNot(contains(_aOffline)), reason: 'never in B');
    expect(await watchHeldTaskCount(db()).first, 2);
  });

  test('one account only: nothing held, offline work goes up', () async {
    await oldBuildDevice(aIsB: true);
    await device.sync();
    expect(await ownerOf(_aSynced), _b);
    expect(await ownerOf(_aOffline), _b);
    expect(server.table('occurrences').keys, contains(_aOffline));
    expect(await watchHeldTaskCount(db()).first, 0);
  });

  test('a refused row is held, never retried; the rest goes up', () async {
    await device.write([_task(_aOffline), _task(_bNew)]);
    server.foreignIds.add(_aOffline);
    await device.sync();
    expect(await ownerOf(_aOffline), isNot(_b));
    expect(server.table('occurrences').keys, contains(_bNew));
    final again = await device.sync();
    expect(again.pushed, 0, reason: 'nothing left to retry');
  });

  test('the check runs once', () async {
    await oldBuildDevice(aIsB: true);
    await device.sync();
    final due = await db()
        .customSelect(
          'SELECT 1 FROM local_meta WHERE key = ?',
          variables: [const Variable<String>(legacyCheckDueKey)],
        )
        .getSingleOrNull();
    expect(due, isNull);
  });

  test('held rows never become a guest\'s, after a sign-out too', () async {
    await oldBuildDevice();
    await device.sync();
    final held = (await ownerOf(_aSynced))!;
    expect(await isAccount(db(), held), isTrue, reason: 'never a guest');
    await signOutOwner(db());
    expect(await activeOwnerId(db()), isNot(held));
    expect(await leftGuestTaskCount(db()), 0);
  });
}
