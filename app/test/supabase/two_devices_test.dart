@Tags(['supabase'])
library;

import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/router/auth_callback.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/sync/account_adoption.dart';
import 'package:dottoday/data/sync/supabase_sync_gateway.dart';
import 'package:dottoday/data/sync/sync_engine.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../data/writes/write_harness.dart';
import '../domain/fixtures.dart';
import 'local_supabase.dart';

// Two devices of one account against local Supabase (docs/09 M6.6, 08 §6
// "two-device conflict scenario", R-08): both edit while offline, then
// reconnect. Nothing is lost; a conflict is raised only when both changed
// the same field within a minute. "Offline" = not syncing; each device has
// its own clock.

final class _Device {
  _Device(this.client) : h = WriteHarness(DateTime.now().toUtc());

  final SupabaseClient client;
  final WriteHarness h;
  late final _engine = SyncEngine(
    db: h.db,
    gateway: SupabaseSyncGateway(client),
    hlc: h.hlc,
    clock: h.clock,
  );

  String get uid => client.auth.currentUser!.id;

  Future<void> start() async {
    await h.writes.apply(
      WriteBatch(
        userId: 'device-local',
        profile: profileFixture().copyWith(id: 'device-local'),
      ),
    );
    await adoptAccount(h.db, uid, h.hlc);
  }

  Future<int> reconnect() async => (await _engine.run(uid)).conflicts;

  Future<void> edit(Occurrence o) async =>
      h.writes.apply(WriteBatch(userId: uid, occurrences: [o]));

  Future<Occurrence> task(String id) async =>
      (await DriftOccurrenceRepository(h.db).findById(uid, id))!;

  Future<int> openConflicts() async =>
      (await h.db.select(h.db.conflicts).get()).length;
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  late _Device phone;
  late _Device laptop;
  late Occurrence base;
  String newId() => const UuidV7Generator().newId();

  setUpAll(() async {
    final email = 'm66-${DateTime.now().microsecondsSinceEpoch}@example.com';
    final first = localClient();
    await first.auth.signInWithOtp(
      email: email,
      emailRedirectTo: authCallbackLink,
    );
    await first.auth.getSessionFromUrl(await magicLinkCallback(email));
    final second = localClient();
    await second.auth.setSession(first.auth.currentSession!.refreshToken!);
    phone = _Device(first);
    laptop = _Device(second);
    await phone.start();
    await laptop.start();
  });

  setUp(() async {
    final now = DateTime.fromMillisecondsSinceEpoch(
      phone.h.clock.nowUtc().millisecondsSinceEpoch,
      isUtc: true,
    );
    base = occurrenceFixture().copyWith(
      id: newId(),
      userId: phone.uid,
      title: 'Dentist',
      startUtc: now.add(const Duration(hours: 3)),
      durationMin: 30,
    );
    await phone.edit(base);
    await phone.reconnect();
    await laptop.reconnect();
    expect((await laptop.task(base.id)).title, 'Dentist');
  });

  test(
    'different fields offline on both: both edits survive, no conflict',
    () async {
      await phone.edit(base.copyWith(title: 'Dentist (moved)'));
      await laptop.edit(base.copyWith(durationMin: 60));
      expect(await phone.reconnect(), 0);
      expect(await laptop.reconnect(), 0);
      await phone.reconnect();
      for (final d in [phone, laptop]) {
        final t = await d.task(base.id);
        expect(t.title, 'Dentist (moved)');
        expect(t.durationMin, 60);
      }
    },
  );

  test(
    'the same field within a minute: one conflict, server value kept',
    () async {
      await phone.edit(base.copyWith(notes: 'Bring card'));
      laptop.h.clock.advance(const Duration(seconds: 20));
      await laptop.edit(base.copyWith(notes: 'Bring insurance card'));
      expect(await phone.reconnect(), 0);
      expect(await laptop.reconnect(), 1);
      expect((await laptop.task(base.id)).notes, 'Bring card');
      expect(await laptop.openConflicts(), greaterThanOrEqualTo(1));
      // Not lost: the laptop's text waits in the conflict for "keep mine".
      final c = (await laptop.h.db.select(laptop.h.db.conflicts).get()).last;
      expect(c.mine, '"Bring insurance card"');
    },
  );

  test(
    'the same field minutes apart: the later edit wins, no conflict',
    () async {
      final conflictsBefore = await laptop.openConflicts();
      await phone.edit(base.copyWith(title: 'Dentist 3pm'));
      laptop.h.clock.advance(const Duration(minutes: 3));
      await laptop.edit(base.copyWith(title: 'Dentist 4pm'));
      expect(await phone.reconnect(), 0);
      expect(await laptop.reconnect(), 0);
      await phone.reconnect();
      expect((await phone.task(base.id)).title, 'Dentist 4pm');
      expect((await laptop.task(base.id)).title, 'Dentist 4pm');
      expect(await laptop.openConflicts(), conflictsBefore);
    },
  );

  test('new tasks on both while offline: each device ends with both', () async {
    final mine = base.copyWith(id: newId(), title: 'Gym');
    final theirs = base.copyWith(id: newId(), title: 'Groceries');
    await phone.edit(mine);
    await laptop.edit(theirs);
    await phone.reconnect();
    await laptop.reconnect();
    await phone.reconnect();
    for (final d in [phone, laptop]) {
      expect((await d.task(mine.id)).title, 'Gym');
      expect((await d.task(theirs.id)).title, 'Groceries');
    }
  });

  test('deleted on one, edited on the other: in Trash with the edit', () async {
    final at = phone.h.clock.nowUtc();
    await phone.edit(base.copyWith(deletedAt: at));
    laptop.h.clock.advance(const Duration(seconds: 70));
    await laptop.edit(base.copyWith(title: 'Dentist (kept?)'));
    await phone.reconnect();
    await laptop.reconnect();
    await phone.reconnect();
    for (final d in [phone, laptop]) {
      final t = await d.task(base.id);
      expect(t.deletedAt, isNotNull, reason: 'a tombstone, restorable');
      expect(t.title, 'Dentist (kept?)', reason: 'the edit is not lost');
    }
  });
}
