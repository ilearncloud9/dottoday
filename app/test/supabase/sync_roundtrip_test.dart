@Tags(['supabase'])
library;

import 'package:dottoday/core/router/auth_callback.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/sync/account_adoption.dart';
import 'package:dottoday/data/sync/supabase_sync_gateway.dart';
import 'package:dottoday/data/sync/sync_engine.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../data/writes/write_harness.dart';
import '../domain/fixtures.dart';
import 'local_supabase.dart';

// Two devices, one account, the real sync_push / PostgREST / RLS on local
// Supabase (docs/09 M6.2, docs/04 §4): every column type crosses and
// comes back equal; an edit on one device reaches the other.

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
        profile: profileFixture().copyWith(
          id: 'device-local',
          tzId: 'Europe/Berlin',
        ),
      ),
    );
    await adoptAccount(h.db, account);
  }
}

Future<SupabaseClient> _signIn(String email) async {
  final client = localClient();
  await client.auth.signInWithOtp(
    email: email,
    emailRedirectTo: authCallbackLink,
  );
  await client.auth.getSessionFromUrl(await magicLinkCallback(email));
  return client;
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('a task and a repeat go up from one device and down to another', () async {
    final email = 'm62-${DateTime.now().microsecondsSinceEpoch}@example.com';
    final first = await _signIn(email);
    // The second device: its own session for the same account.
    final second = localClient();
    await second.auth.setSession(first.auth.currentSession!.refreshToken!);
    final a = _Device(first);
    final b = _Device(second);
    addTearDown(() async {
      await a.h.dispose();
      await b.h.dispose();
      await first.dispose();
      await second.dispose();
    });
    await a.start();
    await b.start();

    final now = DateTime.fromMillisecondsSinceEpoch(
      a.h.clock.nowUtc().millisecondsSinceEpoch,
      isUtc: true,
    );
    final task = occurrenceFixture().copyWith(
      id: '01928c3e-0000-7000-8000-${now.millisecondsSinceEpoch.toString().padLeft(12, '0').substring(0, 12)}',
      userId: a.account,
      title: 'Dentist',
      notes: 'Bring card',
      startUtc: now.add(const Duration(hours: 2)),
      tzId: 'Europe/Berlin',
      durationMin: 45,
      energy: Energy.low,
      alerts: const [Alert(kind: AlertKind.before, offsetMin: 10)],
      status: OccurrenceStatus.planned,
      sortOrder: 1.5,
    );
    final series = seriesFixture().copyWith(
      id: '01928c3e-0000-7000-9000-${now.millisecondsSinceEpoch.toString().padLeft(12, '0').substring(0, 12)}',
      userId: a.account,
      dtstartLocal: '2026-10-23T07:00:00',
      tzId: 'Europe/Berlin',
    );
    await a.h.writes.apply(
      WriteBatch(userId: a.account, occurrences: [task], series: [series]),
    );

    final up = await a.engine.run(a.account);
    expect(up.pushed, greaterThan(1));
    expect(await a.h.db.select(a.h.db.changeLog).get(), isEmpty);

    final progress = <(int, int)>[];
    final down = await b.engine.run(
      b.account,
      onProgress: (d, t) => progress.add((d, t)),
    );
    expect(down.pulled, greaterThan(1));
    // "Bringing your tasks… n of m" from the server's own count.
    expect(progress.first, (0, progress.first.$2));
    expect(progress.first.$2, greaterThan(1));
    expect(progress.last.$1, progress.last.$2);
    final got = await b.h.db.select(b.h.db.occurrences).get();
    final mine = await DriftOccurrenceRepository(
      b.h.db,
    ).findById(b.account, task.id);
    expect(mine!.title, 'Dentist');
    expect(mine.notes, 'Bring card');
    expect(mine.startUtc, task.startUtc);
    expect(mine.durationMin, 45);
    expect(mine.energy, Energy.low);
    expect(mine.alerts, task.alerts);
    expect(mine.sortOrder, 1.5);
    expect(mine.tzId, 'Europe/Berlin');
    // The repeat's instances: the same ids on both devices.
    final aIds = (await a.h.db.select(a.h.db.occurrences).get())
        .map((r) => r.id)
        .toSet();
    expect(got.map((r) => r.id).toSet(), aIds);
    final profile = (await b.h.db.select(b.h.db.profiles).get()).single;
    expect(profile.tzId, 'Europe/Berlin');

    // An edit on b reaches a.
    await b.h.writes.apply(
      WriteBatch(
        userId: b.account,
        occurrences: [task.copyWith(title: 'Dentist at 4', updatedAt: now)],
      ),
    );
    await b.engine.run(b.account);
    await a.engine.run(a.account);
    final back = await (a.h.db.select(
      a.h.db.occurrences,
    )..where((o) => o.id.equals(task.id))).getSingle();
    expect(back.title, 'Dentist at 4');
  });
}
