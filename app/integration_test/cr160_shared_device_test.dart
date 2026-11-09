// CR-160 criterion 11 (and the web flows of criterion 10): one device,
// several people, on the real platform: the encrypted database, the
// notification plugin, OwnerSwitch and the sync engine, against the LOCAL
// Supabase stack only (docs/cr-160-verification.md).
//
// Needs, on the host: `supabase start` (and `supabase functions serve` for
// the deleted account), the test-only network switch (a pass-through to
// the stack the test can cut), and the defines SUPABASE_URL (the switch's
// address), SUPABASE_ANON_KEY and CR160_SERVICE_KEY (local stack only).
// Prints `CR160 …` lines with ids and counts, never task text.
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_providers.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/cr160_lab.dart';
import 'support/cr160_start.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'CR-160 shared device: A offline, B, A again, guest, deleted account',
    (tester) async {
      final lab = await startLab(tester);
      final run = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
      final guest = await activeOwnerId(lab.db);
      expect(await isAccount(lab.db, guest!), isFalse);
      final gOld = await lab.addTask(guest, 'cr160 guest $run');
      report('guest $guest task ${gOld.id}');
      final a = await lab.newAccount('a');
      final b = await lab.newAccount('b');
      final d = await lab.newAccount('d');
      report('accounts a=${a.id} b=${b.id} d=${d.id}');

      final aIds = await _aSignsInAndGoesOffline(tester, lab, a, run);
      await _bSignsIn(tester, lab, b, a, aIds, (
        guest: guest,
        task: gOld.id,
      ), run);
      await _aReturns(lab, a, b, aIds, gOld.id, run);
      await _deletedAccount(lab, a, d, aIds, run);
      report('RESULT PASS');
    },
    timeout: const Timeout(Duration(minutes: 20)),
  );
}

/// A signs in (the guest's task kept separate), syncs, gets a delivered
/// reminder, then adds two tasks with the network cut and signs out.
/// Returns A's three task ids: synced, offline 1, offline 2.
Future<List<String>> _aSignsInAndGoesOffline(
  WidgetTester tester,
  Cr160Lab lab,
  LabAccount a,
  String run,
) async {
  await lab.signIn(a, choice: GuestChoice.keepSeparate);
  final t0 = await lab.addTask(
    a.id,
    'cr160 A synced $run',
    startIn: const Duration(seconds: 30),
  );
  await lab.until('t0 on server', () async {
    await lab.syncOk();
    return (await lab.serverIds(a.id)).contains(t0.id);
  });
  final t0Notes = {
    for (final e in (await lab.pendingNotifications()).entries)
      if (e.value == t0.id) e.key,
  };
  expect(t0Notes, isNotEmpty, reason: "A's reminder is scheduled");
  await lab.until(
    "A's reminder delivered",
    () async => (await lab.deliveredNotifications()).any(t0Notes.contains),
    timeout: const Duration(seconds: 120),
  );
  report('A reminder delivered ids=$t0Notes');
  await tester.pump(const Duration(seconds: 1));
  expect(await lab.todayIds(), contains(t0.id), reason: 'A sees its task');
  report('A title as text/semantics: ${await _onScreen(tester, 'cr160 A')}');

  await lab.network(online: false);
  final a1 = await lab.addTask(a.id, 'cr160 A offline 1 $run');
  final a2 = await lab.addTask(a.id, 'cr160 A offline 2 $run');
  // The runs the writes trigger fail at the gateway: the status says so.
  final cut = DateTime.now();
  await lab.until('sync offline', lab.syncShowsOffline);
  report('offline seen after ${DateTime.now().difference(cut).inSeconds}s');
  expect(await lab.outbox(a.id), greaterThanOrEqualTo(2));
  final pending = (await lab.pendingNotifications()).values.toSet();
  expect(pending, containsAll([a1.id, a2.id]));
  await lab.signOut();
  final afterOut = await activeOwnerId(lab.db);
  expect(afterOut, isNot(a.id));
  expect(await isAccount(lab.db, afterOut!), isFalse);
  expect(await lab.outbox(a.id), greaterThanOrEqualTo(2), reason: 'kept');
  await lab.network(online: true);
  final onServer = await lab.serverIds(a.id);
  expect(onServer, isNot(contains(a1.id)));
  expect(onServer, isNot(contains(a2.id)));
  report(
    'A offline tasks ${a1.id} ${a2.id} kept, outbox=${await lab.outbox(a.id)}',
  );
  return [t0.id, a1.id, a2.id];
}

/// B signs in on the same device, having asked to bring guest tasks in:
/// none of A's tasks, reminders or rows reach B, and the guest's task from
/// before A's session is not eligible.
Future<void> _bSignsIn(
  WidgetTester tester,
  Cr160Lab lab,
  LabAccount b,
  LabAccount a,
  List<String> aIds,
  ({String guest, String task}) old,
  String run,
) async {
  final gOld = old.task;
  final notesBefore = await lab.pendingNotifications();
  await lab.signIn(b, choice: GuestChoice.bringIn);
  expect(await activeOwnerId(lab.db), b.id);
  final local = await lab.localIds(b.id);
  expect(local.intersection({...aIds, gOld}), isEmpty);
  final b1 = await lab.addTask(b.id, 'cr160 B task $run');
  await lab.until('b1 on server', () async {
    await lab.syncOk();
    return (await lab.serverIds(b.id)).contains(b1.id);
  });
  final rls = await lab.rlsIds();
  report('B RLS ids=${rls.length} hasB1=${rls.contains(b1.id)}');
  expect(rls, contains(b1.id));
  expect(rls.toSet().intersection({...aIds, gOld}), isEmpty);
  expect(
    (await lab.serverIds(b.id)).toSet().intersection({...aIds, gOld}),
    isEmpty,
  );
  expect((await lab.serverIds(a.id)).toSet().intersection(aIds.toSet()), {
    aIds.first,
  }, reason: "A's offline work never went up while B was signed in");
  expect(await lab.localIds(old.guest), contains(gOld), reason: 'stays');

  final notes = await lab.pendingNotifications();
  expect(notes.values.toSet().intersection(aIds.toSet()), isEmpty);
  final aNotes = {
    for (final e in notesBefore.entries)
      if (aIds.contains(e.value)) e.key,
  };
  final shown = await lab.deliveredNotifications();
  expect(shown.intersection(aNotes), isEmpty, reason: "A's delivered gone");
  report('B pending=${notes.length} delivered=${shown.length} none of A');

  await tester.pump(const Duration(seconds: 1));
  final today = await lab.todayIds();
  expect(today.intersection({...aIds, gOld}), isEmpty, reason: 'Today: no A');
  expect(await _onScreen(tester, 'cr160 A '), isFalse, reason: 'no A shown');
  expect(await _onScreen(tester, 'cr160 guest'), isFalse, reason: 'no guest');
  await lab.signOut();
}

/// A signs in again: its two offline tasks reach its account once, and
/// none of B's or the guest's.
Future<void> _aReturns(
  Cr160Lab lab,
  LabAccount a,
  LabAccount b,
  List<String> aIds,
  String gOld,
  String run,
) async {
  await lab.signIn(a);
  await lab.until("A's outbox empty", () async {
    await lab.syncOk();
    return await lab.outbox(a.id) == 0;
  });
  final server = await lab.serverIds(a.id);
  for (final id in aIds) {
    expect(server.where((s) => s == id), hasLength(1), reason: 'once: $id');
  }
  final bIds = (await lab.serverIds(b.id)).toSet();
  expect(server.toSet().intersection({...bIds, gOld}), isEmpty);
  final rls = await lab.rlsIds();
  expect(rls.toSet(), containsAll(aIds));
  expect(rls.toSet().intersection({...bIds, gOld}), isEmpty);
  final titles = await lab.admin
      .from('occurrences')
      .select('id')
      .eq('user_id', a.id)
      .like('title', '%$run%');
  expect(titles, hasLength(3), reason: 'no duplicate of any A task');
  report('A returned: server=${server.length} rls=${rls.length} B-ids=0');
}

/// D signs in, syncs, has a backup, deletes the account: nothing of D is
/// left on this device or the server; A's copy is untouched.
Future<void> _deletedAccount(
  Cr160Lab lab,
  LabAccount a,
  LabAccount d,
  List<String> aIds,
  String run,
) async {
  await lab.signOut();
  await lab.signIn(d);
  final d1 = await lab.addTask(d.id, 'cr160 D task $run');
  await lab.until('d1 on server', () async {
    await lab.syncOk();
    return (await lab.serverIds(d.id)).contains(d1.id);
  });
  final backup = await lab.c
      .read(backupServiceProvider)
      .create(d.id, BackupReason.daily);
  expect(backup is Ok, isTrue);
  expect(await lab.backups(d.id), greaterThanOrEqualTo(1));
  final deleted = await lab.actions.deleteAccount();
  expect(deleted is Ok, isTrue, reason: 'functions serve');
  await lab.until('removal finished', () async {
    return (await pendingRemovals(lab.db)).isEmpty;
  });
  final left = await lab.leftovers(d.id);
  report('D deleted, left on device: $left');
  expect(left.values.every((n) => n == 0), isTrue, reason: '$left');
  expect(await lab.serverIds(d.id), isEmpty);
  expect(lab.app.auth.currentUser, isNull);
  expect(await lab.localIds(a.id), containsAll(aIds), reason: 'A untouched');
  expect(await isAccount(lab.db, (await activeOwnerId(lab.db))!), isFalse);
}

/// Whether [text] shows anywhere: a text widget or a semantics label (the
/// day thread paints its rows; screen readers get the titles).
Future<bool> _onScreen(WidgetTester tester, String text) async {
  final handle = tester.ensureSemantics();
  try {
    await tester.pump(const Duration(milliseconds: 500));
    final byText = find.textContaining(text, findRichText: true);
    final bySemantics = find.bySemanticsLabel(RegExp(RegExp.escape(text)));
    final hit = tester.any(byText) || tester.any(bySemantics);
    return hit;
  } finally {
    handle.dispose();
  }
}
