// CR-160 criterion 10 (web end-to-end) in a real browser against the LOCAL
// Supabase stack only. One build; the page's `?phase=` picks the step and
// `&s=` carries what an earlier step made (accounts, ids), so a reload,
// a second browser profile ("another device") or a second tab is a real
// page load driven from outside (a Playwright script on the host). Flow 3
// (sign-out → other account) is `cr160_shared_device_test.dart` on the web.
// Prints `CR160 …` lines with ids and counts, never task text.
import 'dart:convert';

import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/cr160_lab.dart';
import 'support/cr160_start.dart';

final _q = Uri.base.queryParameters;
final _phase = _q['phase'] ?? '';
final Map<String, dynamic> _s = _q['s'] == null
    ? {}
    : jsonDecode(utf8.decode(base64Url.decode(_q['s']!)))
          as Map<String, dynamic>;

void _state(Map<String, Object?> s) =>
    report('STATE ${base64Url.encode(utf8.encode(jsonEncode(s)))}');

LabAccount _a() => (id: _s['id'] as String, email: _s['email'] as String);
List<String> _ids() => [for (final i in _s['ids'] as List) i as String];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CR-160 web flow: $_phase', (tester) async {
    final lab = await startLab(tester, fresh: !_phase.endsWith('after'));
    final run = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    switch (_phase) {
      case 'flow1':
        await _guestToNew(lab, run);
      case 'flow1after' || 'flow4after':
        await _afterReload(lab);
      case 'flow2seed':
        await _seedExisting(lab, run);
      case 'flow2':
        await _guestToExisting(lab, run);
      case 'flow4':
        await _interrupted(lab, run);
      case 'flow5':
        await _secondTab(lab, run);
      default:
        fail('unknown phase "$_phase"');
    }
    report('PHASE $_phase PASS');
  }, timeout: const Timeout(Duration(minutes: 10)));
}

Future<List<String>> _guestTasks(Cr160Lab lab, String run, int n) async {
  final guest = (await activeOwnerId(lab.db))!;
  expect(await isAccount(lab.db, guest), isFalse);
  return [
    for (var i = 0; i < n; i++)
      (await lab.addTask(guest, 'cr160 web guest $i $run')).id,
  ];
}

/// Flow 1: a guest's tasks go into a new account on "Bring them in".
Future<void> _guestToNew(Cr160Lab lab, String run) async {
  final ids = await _guestTasks(lab, run, 3);
  final a = await lab.newAccount('w1');
  await lab.signIn(a, choice: GuestChoice.bringIn);
  expect(await lab.localIds(a.id), containsAll(ids));
  await _onceEach(lab, a.id, ids);
  _state({'id': a.id, 'email': a.email, 'ids': ids});
}

/// After a reload (or leaving mid-migration): the same account is shown,
/// its tasks are its own and the server holds each once.
Future<void> _afterReload(Cr160Lab lab) async {
  final a = _a();
  await lab.until('shown after reload', () async {
    return await activeOwnerId(lab.db) == a.id;
  });
  if (_phase == 'flow4after') {
    // Still offline: the interrupted first sync shows as failed (the
    // status that offers Try again), and nothing is duplicated yet.
    await lab.until('error shown', lab.syncShowsOffline);
    report(
      'after reload offline: status failed, A rows '
      '${(await lab.localIds(a.id)).length}, outbox ${await lab.outbox(a.id)}',
    );
  }
  await lab.network(online: true);
  await lab.until('synced after reload', () async {
    return await lab.syncOk() && await lab.outbox(a.id) == 0;
  });
  expect(await lab.localIds(a.id), containsAll(_ids()));
  await _onceEach(lab, a.id, _ids());
}

Future<void> _onceEach(Cr160Lab lab, String uid, List<String> ids) async {
  final server = await lab.serverIds(uid);
  for (final id in ids) {
    expect(server.where((s) => s == id), hasLength(1), reason: 'once: $id');
  }
  report(
    'server $uid holds ${ids.length} ids once each (total ${server.length})',
  );
}

/// Flow 2, first profile ("another device"): A with Berlin and 2 tasks.
Future<void> _seedExisting(Cr160Lab lab, String run) async {
  final a = await lab.newAccount('w2');
  await lab.signIn(a);
  await _zone(lab, a.id, 'Europe/Berlin');
  final ids = [
    for (var i = 0; i < 2; i++)
      (await lab.addTask(a.id, 'cr160 web seed $i $run')).id,
  ];
  await lab.until('seed synced', () async {
    return await lab.syncOk() && await lab.outbox(a.id) == 0;
  });
  _state({'id': a.id, 'email': a.email, 'ids': ids});
}

Future<void> _zone(Cr160Lab lab, String owner, String tz) async {
  final p = await lab.c.read(localProfileProvider.future);
  await lab.c
      .read(writeUseCaseProvider)
      .apply(
        WriteBatch(
          userId: owner,
          profile: p.copyWith(tzId: tz),
        ),
      );
}

/// Flow 2, a fresh profile: a Tokyo guest with 2 tasks signs in as A.
Future<void> _guestToExisting(Cr160Lab lab, String run) async {
  final a = _a();
  final guest = (await activeOwnerId(lab.db))!;
  await _zone(lab, guest, 'Asia/Tokyo');
  final mine = await _guestTasks(lab, run, 2);
  await lab.signIn(a, choice: GuestChoice.bringIn);
  await lab.until('pulled', () async {
    await lab.syncOk();
    return (await lab.localIds(a.id)).containsAll(_ids());
  });
  expect(await lab.localIds(a.id), containsAll(mine));
  await _onceEach(lab, a.id, [..._ids(), ...mine]);
  final server = await lab.admin
      .from('profiles')
      .select('tz_id')
      .eq('id', a.id)
      .single();
  expect(server['tz_id'], 'Europe/Berlin', reason: 'no silent replace');
  // The stored profile (what Settings and Today read), not the cached
  // launch snapshot.
  final local = await lab.c
      .read(settingsRepositoryProvider)
      .watchProfile(a.id)
      .first;
  expect(local?.tzId, 'Europe/Berlin', reason: 'device shows Berlin');
  report('flow2 settings kept Europe/Berlin; tasks 2+2 once each');
}

/// Flow 4: the sign-in starts, the network is cut at once and the page is
/// left (the host script navigates to `flow4after` on RELOAD-NOW).
Future<void> _interrupted(Cr160Lab lab, String run) async {
  final ids = await _guestTasks(lab, run, 3);
  final a = await lab.newAccount('w4');
  await recordGuestChoice(lab.db, a.id, GuestChoice.bringIn);
  await lab.verifyOnly(a);
  await lab.network(online: false);
  report(
    'before reload: A rows ${(await lab.localIds(a.id)).length}, '
    'shown A ${await activeOwnerId(lab.db) == a.id}',
  );
  _state({'id': a.id, 'email': a.email, 'ids': ids});
  report('RELOAD-NOW');
  await Future<void>.delayed(const Duration(minutes: 5));
}

/// Flow 5: A shown in this tab while the host opens the real app in a
/// second tab; then B replaces A here and the host looks again.
Future<void> _secondTab(Cr160Lab lab, String run) async {
  final a = await lab.newAccount('w5a');
  await lab.signIn(a);
  await lab.addTask(a.id, 'cr160 web tab A $run');
  report('TAB2-NOW');
  await Future<void>.delayed(const Duration(seconds: 25));
  await lab.signOut();
  final b = await lab.newAccount('w5b');
  await lab.signIn(b);
  report('TAB2-AGAIN');
  await Future<void>.delayed(const Duration(seconds: 25));
  await lab.signOut();
}
