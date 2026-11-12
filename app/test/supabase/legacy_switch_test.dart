@Tags(['supabase'])
library;

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/router/auth_callback.dart';
import 'package:dottoday/data/db/legacy_outbox.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/sync/supabase_sync_gateway.dart';
import 'package:dottoday/data/sync/sync_engine.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../data/writes/write_harness.dart';
import '../domain/fixtures.dart';
import 'local_supabase.dart';

// CR-160 blocker 8 on the real sync_push, PostgREST and RLS (local stack):
// a device on which an old build signed into B after A holds A's rows, and
// nothing of A's reaches B's account; a refusal names its row as the
// gateway expects.

final class _Device {
  _Device(this.client) : h = WriteHarness(DateTime.now().toUtc());

  final SupabaseClient client;
  final WriteHarness h;
  late final SyncEngine engine = SyncEngine(
    db: h.db,
    gateway: SupabaseSyncGateway(client),
    hlc: h.hlc,
    clock: h.clock,
  );

  String get account => client.auth.currentUser!.id;

  Future<void> start() async {
    await h.writes.apply(
      WriteBatch(
        userId: 'device-local',
        profile: profileFixture().copyWith(id: 'device-local'),
      ),
    );
    await signInOwner(
      h.db,
      account,
      h.hlc,
      freshProfile: (id) => profileFixture().copyWith(id: id),
    );
  }

  Future<void> write(List<Occurrence> rows) async {
    final r = await h.writes.apply(
      WriteBatch(userId: account, occurrences: rows),
    );
    expect(r, isA<Ok<void, AppFailure>>());
  }

  Future<String?> ownerOf(String id) async =>
      (await h.db
              .customSelect(
                'SELECT user_id FROM occurrences WHERE id = ?',
                variables: [Variable<String>(id)],
              )
              .getSingleOrNull())
          ?.read<String>('user_id');
}

Future<_Device> _device(String tag) async {
  final client = localClient();
  final email = '$tag-${DateTime.now().microsecondsSinceEpoch}@example.com';
  await client.auth.signInWithOtp(
    email: email,
    emailRedirectTo: authCallbackLink,
  );
  await client.auth.getSessionFromUrl(await magicLinkCallback(email));
  final d = _Device(client);
  addTearDown(() async {
    await d.h.dispose();
    await client.dispose();
  });
  await d.start();
  return d;
}

String _id(int n) {
  final t = '${DateTime.now().microsecondsSinceEpoch * 10 + n}';
  return '01928c3e-0000-7000-8b08-${t.substring(t.length - 12)}';
}

Occurrence _task(String id, String owner) =>
    occurrenceFixture().copyWith(id: id, userId: owner, title: 'Row');

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('an old-build switch: A\'s rows held, none reach B', () async {
    final a = await _device('b8a');
    final aSynced = _id(1);
    await a.write([_task(aSynced, a.account)]);
    await a.engine.run(a.account);

    final b = await _device('b8b');
    // The old build re-keyed A's pulled task to B here and kept no change
    // for it; A's offline task is pending; the upgrade recorded the outbox.
    await b.write([_task(aSynced, b.account)]);
    await b.h.db.customStatement(
      "DELETE FROM change_log WHERE entity_id = '$aSynced'",
    );
    await b.h.db.customStatement(
      'INSERT INTO field_seen (entity, entity_id, field, hlc) '
      "VALUES ('occurrences', '$aSynced', 'title', 'x')",
    );
    final aOffline = _id(2);
    await b.write([_task(aOffline, b.account)]);
    await recordLegacyOutbox(b.h.db);
    final bNew = _id(3);
    await b.write([_task(bNew, b.account)]);

    await b.engine.run(b.account);

    final bServer = {
      for (final r in await adminRows('occurrences', b.account))
        (r! as Map)['id'],
    };
    expect(bServer, contains(bNew));
    expect(bServer, isNot(contains(aOffline)));
    expect(bServer, isNot(contains(aSynced)));
    expect(await b.ownerOf(aSynced), isNot(b.account));
    expect(await b.ownerOf(aOffline), isNot(b.account));
    final aServer = {
      for (final r in await adminRows('occurrences', a.account))
        (r! as Map)['id'],
    };
    expect(aServer, contains(aSynced), reason: 'A keeps its own');
  });

  test('the real refusal names its row: held, the rest goes up', () async {
    final a = await _device('b8c');
    final taken = _id(4);
    await a.write([_task(taken, a.account)]);
    await a.engine.run(a.account);

    final b = await _device('b8d');
    await b.write([_task(taken, b.account)]);
    final mine = _id(5);
    await b.write([_task(mine, b.account)]);
    await b.engine.run(b.account);

    expect(await b.ownerOf(taken), isNot(b.account));
    final bServer = {
      for (final r in await adminRows('occurrences', b.account))
        (r! as Map)['id'],
    };
    expect(bServer, contains(mine));
    expect(bServer, isNot(contains(taken)));
  });
}
