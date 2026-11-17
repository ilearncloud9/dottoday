import 'dart:io';

import 'package:dottoday/data/daos/profiles_dao.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/intents/dot_action.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/writes/write_harness.dart';
import '../domain/fixtures.dart';
import 'fake_notification_platform.dart';
import 'owner_app.dart';
import 'shared_action_queue.dart';
import 'timeline_fakes.dart';

// The device of removal_crash_restart_test.dart: a guest, account B and
// account A, each with tasks, Wake Up mornings, devices and owner-keyed
// settings, plus look-alike keys no removal of A may touch. A's account
// deletion was under way (sealed, removal begun) when the app died.

/// The account whose deletion the crash interrupted.
const removedA = '01928c3e-0000-7000-8000-00000000000a';

/// Another account on the same device.
const otherB = '01928c3e-0000-7000-8000-00000000000b';

/// Task [n] (two digits, unique per test) of [owner].
Occurrence task(String owner, String n) => occurrenceFixture().copyWith(
  id: '01928c3e-0000-7000-8000-0000000003$n',
  userId: owner,
  title: 'Task $n',
  startUtc: ownerAppNow.add(const Duration(hours: 1)),
);

/// Keys that look like A's but are not `<kind>:<A>`: never removed with A.
List<String> lookAlikeKeys() => [
  'recent_searches:pre$removedA',
  'recent_searches:${removedA}x',
  '$removedA:recent_searches',
  'recent_searches:${removedA.toUpperCase()}',
];

/// Builds the device on [file] and stops mid-deletion of A, as a crash
/// would; returns the guest's id.
Future<String> crashMidDeletion(File file) async {
  final db = AppDatabase(NativeDatabase(file));
  final app = OwnerApp(
    db,
    FakeNotificationPlatform(),
    FakeSink(),
    FakeAlarmGateway(),
    SharedActionQueue(),
  );
  await app.shown(); // the guest, as on first launch
  await app.signIn(otherB);
  await app.write([task(otherB, '02')]);
  await app.signIn(removedA);
  await app.write([task(removedA, '10'), task(removedA, '11')]);
  await sealForDeletion(db, removedA);
  await beginAccountRemoval(db, removedA); // shows the guest
  // Read from the database: the app's cached profile hasn't caught up.
  final guest = (await ProfilesDao(db).findActive())!.id;
  await app.write([task(guest, '01')]);
  for (final owner in [guest, otherB, removedA]) {
    await db.customStatement(
      'INSERT INTO wake_up_days (owner_id, date, snoozes) VALUES (?, ?, 1)',
      [owner, '2026-10-22'],
    );
    await db.customStatement(
      'INSERT INTO local_meta (key, value) VALUES (?, ?)',
      ['recent_searches:$owner', '["$owner"]'],
    );
  }
  for (final (id, owner) in [('dev-b', otherB), ('dev-a', removedA)]) {
    await db.customStatement(
      'INSERT INTO devices (id, user_id, platform, form, last_seen_utc) '
      "VALUES (?, ?, 'android', 'phone', 0)",
      [id, owner],
    );
  }
  for (final key in lookAlikeKeys()) {
    await db.customStatement(
      'INSERT INTO local_meta (key, value) VALUES (?, ?)',
      [key, 'kept'],
    );
  }
  app.container.dispose();
  await db.close();
  return guest;
}

/// A queue entry for [action], stamped for [owner] as a surface does.
Map<String, Object?> stampedFor(String owner, String id, DotAction action) => {
  ...encodeQueuedAction(
    QueuedAction(id: id, createdAtUtc: ownerAppNow, action: action),
  ),
  'owner': owner,
};

Future<List<String>> titlesOf(AppDatabase db, String owner) async => [
  for (final r
      in await db
          .customSelect(
            'SELECT title FROM occurrences WHERE user_id = ?',
            variables: [Variable(owner)],
          )
          .get())
    r.read<String>('title'),
];

Future<Set<String>> wakeUpOwners(AppDatabase db) async => {
  for (final r
      in await db.customSelect('SELECT owner_id FROM wake_up_days').get())
    r.read<String>('owner_id'),
};

Future<Set<String>> localKeys(AppDatabase db) async => {
  for (final m in await db.select(db.localMeta).get()) m.key,
};

Future<List<String>> _rows(AppDatabase db, String sql) async {
  final rows = await db.customSelect(sql).get();
  return [for (final r in rows) r.data.values.join('|')]..sort();
}

/// Everything of anyone but A: must not change while A is removed.
Future<Map<String, Object?>> othersOf(AppDatabase db) async {
  const a = "'$removedA'";
  return {
    'profiles': await _rows(db, 'SELECT id FROM profiles WHERE id <> $a'),
    'tasks': await _rows(
      db,
      'SELECT user_id, id, title FROM occurrences WHERE user_id <> $a',
    ),
    'wake_up': await _rows(
      db,
      'SELECT owner_id, date, snoozes FROM wake_up_days WHERE owner_id <> $a',
    ),
    'devices': await _rows(
      db,
      'SELECT id, user_id FROM devices WHERE user_id <> $a',
    ),
    'settings': await _rows(
      db,
      'SELECT key, value FROM local_meta '
      "WHERE substr(key, -${removedA.length + 1}) <> ':' || $a",
    ),
  };
}

/// [owner]'s copy is gone from this device: rows, mornings, devices,
/// owner-keyed settings, profile and the pending mark.
Future<void> expectGone(AppDatabase db, String owner) async {
  expect(await pendingRemovals(db), isEmpty);
  expect(await titlesOf(db, owner), isEmpty);
  expect(await wakeUpOwners(db), isNot(contains(owner)));
  final devices = await db
      .customSelect(
        'SELECT id FROM devices WHERE user_id = ?',
        variables: [Variable(owner)],
      )
      .get();
  expect(devices, isEmpty);
  expect((await localKeys(db)).where((k) => k.endsWith(':$owner')), isEmpty);
  expect(
    (await db.select(db.profiles).get()).map((p) => p.id),
    isNot(contains(owner)),
  );
}
