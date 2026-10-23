import 'package:dottoday/data/sync/account_adoption.dart';
import 'package:dottoday/data/sync/sync_gateway.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/fake_sync_server.dart';
import '../../support/sync_device.dart';

// The sync engine against an in-memory server (docs/08 §2
// `sync_engine_test`, docs/04 §4, ADR-0002, R-08).

const _account = '01928c3e-0000-7000-8000-0000000000ff';
final _t = DateTime.utc(2026, 10, 23, 9);

Occurrence _task(String title) =>
    occurrenceFixture().copyWith(userId: _account, title: title);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  late FakeSyncServer server;
  late SyncDevice a;
  late SyncDevice b;

  setUp(() async {
    server = FakeSyncServer(_account);
    a = SyncDevice(server, _t, name: 'a');
    b = SyncDevice(server, _t, name: 'b');
    await a.start();
    await b.start();
  });
  tearDown(() async {
    await a.close();
    await b.close();
  });

  test('a write goes up; the other device gets it; outboxes empty', () async {
    await a.write([_task('Dentist')]);
    expect(await a.outboxSize(), greaterThan(0));
    final run = await a.sync();
    expect(run.pushed, greaterThan(0));
    expect(await a.outboxSize(), 0);
    expect(server.table('occurrences').values.single['title'], 'Dentist');
    // Instants cross as ISO on the server, milliseconds on the device.
    expect(
      server.table('occurrences').values.single['start_utc'],
      t0.toIso8601String(),
    );

    await b.sync();
    final got = await b.occurrence(occurrenceFixture().id);
    expect(got!.title, 'Dentist');
    expect(got.startUtc, t0);
    expect(await b.outboxSize(), 0, reason: 'a pull adds nothing to push');
  });

  test('offline: nothing lost, nothing sent, the next run sends it', () async {
    await a.write([_task('Dentist')]);
    final waiting = await a.outboxSize();
    server.failNext = SyncTrouble.offline;
    await expectLater(a.sync(), throwsA(isA<SyncGatewayException>()));
    expect(await a.outboxSize(), waiting);
    expect((await a.occurrence(occurrenceFixture().id))!.title, 'Dentist');
    await a.sync();
    expect(await a.outboxSize(), 0);
    expect(server.table('occurrences'), hasLength(1));
  });

  test('a server error never deletes local data or the outbox', () async {
    await a.write([_task('Dentist')]);
    final waiting = await a.outboxSize();
    server.failNext = SyncTrouble.server;
    await expectLater(a.sync(), throwsA(isA<SyncGatewayException>()));
    expect(await a.outboxSize(), waiting);
    expect(await a.occurrence(occurrenceFixture().id), isNotNull);
  });

  group('the same field on two devices', () {
    setUp(() async {
      await a.write([_task('Dentist')]);
      await a.sync();
      await b.sync();
    });

    test('more than a minute apart: the later one wins everywhere', () async {
      await b.write([_task('Dentist (b)')]);
      a.h.clock.advance(const Duration(minutes: 3));
      await a.write([_task('Dentist (a, later)')]);
      await a.sync();
      await b.sync();
      expect(
        (await b.occurrence(occurrenceFixture().id))!.title,
        'Dentist (a, later)',
      );
      expect(await b.outboxSize(), 0, reason: 'its older edit is settled');
      expect(await b.h.db.select(b.h.db.conflicts).get(), isEmpty);
    });

    test('the later local edit is kept and goes up', () async {
      await a.write([_task('Dentist (a)')]);
      await a.sync();
      b.h.clock.advance(const Duration(minutes: 3));
      await b.write([_task('Dentist (b, later)')]);
      await b.sync();
      expect(
        (await b.occurrence(occurrenceFixture().id))!.title,
        'Dentist (b, later)',
      );
      expect(
        server.table('occurrences').values.single['title'],
        'Dentist (b, later)',
      );
    });

    test('within a minute: a conflict; the server value stands', () async {
      await a.write([_task('Dentist (a)')]);
      b.h.clock.advance(const Duration(seconds: 20));
      await b.write([_task('Dentist (b)')]);
      await a.sync();
      final run = await b.sync();
      expect(run.conflicts, 1);
      expect(
        (await b.occurrence(occurrenceFixture().id))!.title,
        'Dentist (a)',
      );
      final conflict = (await b.h.db.select(b.h.db.conflicts).get()).single;
      expect(conflict.field, 'title');
      expect(conflict.mine, '"Dentist (b)"');
      expect(conflict.theirs, '"Dentist (a)"');
      expect(
        server.table('occurrences').values.single['title'],
        'Dentist (a)',
        reason: 'b did not overwrite it',
      );
    });

    test('different fields both survive', () async {
      await a.write([_task('Dentist (a)')]);
      await b.write([
        occurrenceFixture().copyWith(userId: _account, durationMin: 90),
      ]);
      await a.sync();
      await b.sync();
      await a.sync();
      for (final d in [a, b]) {
        final o = (await d.occurrence(occurrenceFixture().id))!;
        expect(o.title, 'Dentist (a)');
        expect(o.durationMin, 90);
      }
    });
  });

  test('a delete is a tombstone on the other device, not a removal', () async {
    await a.write([_task('Dentist')]);
    await a.sync();
    await b.sync();
    await a.write([_task('Dentist').copyWith(deletedAt: _t)]);
    await a.sync();
    await b.sync();
    final row = await b.occurrence(occurrenceFixture().id);
    expect(row, isNotNull);
    expect(row!.deletedAt, _t);
  });

  test('two devices extending one repeat make one set of rows', () async {
    final series = seriesFixture().copyWith(userId: _account);
    await a.h.writes.apply(WriteBatch(userId: _account, series: [series]));
    await b.h.writes.apply(WriteBatch(userId: _account, series: [series]));
    await a.sync();
    await b.sync();
    await a.sync();
    final ids = server.table('occurrences').keys.toSet();
    final aRows = await a.h.db.select(a.h.db.occurrences).get();
    final bRows = await b.h.db.select(b.h.db.occurrences).get();
    expect(aRows.map((r) => r.id).toSet(), ids);
    expect(bRows.map((r) => r.id).toSet(), ids);
  });

  test('signing in re-keys the device profile, its rows and outbox', () async {
    final c = SyncDevice(server, _t, name: 'c');
    addTearDown(c.close);
    // Tasks made before there was an account.
    await c.h.writes.apply(
      WriteBatch(
        userId: 'device-local',
        profile: profileFixture().copyWith(id: 'device-local'),
        occurrences: [occurrenceFixture().copyWith(userId: 'device-local')],
      ),
    );
    expect(await adoptAccount(c.h.db, _account, c.h.hlc), 'device-local');
    expect((await c.h.db.select(c.h.db.profiles).get()).single.id, _account);
    final row = (await c.h.db.select(c.h.db.occurrences).get()).single;
    expect(row.userId, _account);
    final log = await c.h.db.select(c.h.db.changeLog).get();
    expect(
      log.where((r) => r.entity == 'profiles').map((r) => r.entityId).toSet(),
      {_account},
    );
    // And they go up under the account.
    await c.sync();
    expect(server.table('occurrences'), hasLength(1));
    expect(server.table('profiles').keys, [_account]);
    expect(
      await adoptAccount(c.h.db, _account, c.h.hlc),
      isNull,
      reason: 'once',
    );
  });

  // M6.5: the account this device synced with was deleted (or another
  // signs in): its server has none of the rows, the outbox was emptied.
  test('another account: everything on the device goes up again', () async {
    await a.write([_task('Dentist')]);
    await a.sync();
    expect(await a.outboxSize(), 0);
    const other = '01928c3e-0000-7000-8000-0000000000ee';
    final next = FakeSyncServer(other);
    expect(await adoptAccount(a.h.db, other, a.h.hlc), _account);
    expect(await a.outboxSize(), greaterThan(0));
    await SyncDevice.engineFor(a, next).run(other);
    expect(next.table('occurrences').keys, [occurrenceFixture().id]);
    expect(next.table('profiles').keys, [other]);
  });

  test('pages: more rows than a page all arrive', () async {
    await a.write([
      for (var i = 0; i < 7; i++)
        _task('Task $i').copyWith(id: '01928c3e-0000-7000-8000-00000000010$i'),
    ]);
    await a.sync();
    final run = await b.sync();
    expect(run.pulled, greaterThanOrEqualTo(7));
    expect(await b.h.db.select(b.h.db.occurrences).get(), hasLength(7));
  });
}
