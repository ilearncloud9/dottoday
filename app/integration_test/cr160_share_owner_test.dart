// CR-160 I7 on a real Android device: shares arrive through the real
// ACTION_SEND path (MainActivity → ShareIntake → the `home_widget` prefs
// queue, stamped by Kotlin under its lock) and are drained through the real
// `dottoday/intents` channel, encrypted database and OwnerSwitch. Driven by
// tool/cr160/share_owner_check.sh across three launches of this binary:
//
//   1. fresh: A signs in (local only, no server).
//   2. cold start by a share while A was shown: it is A's, and applied to A.
//      A signs out, B signs in; a share while B is shown is B's. Then the
//      share is queued while the published owner still names A (the moment
//      a change of owner can lag behind): B never gets it; it waits.
//   3. after a force-stop: it still waits, unread by B; A signs back in and
//      gets it once. A share queued mid-switch names nobody and is kept.
//
// Prints `CR160S <step>` lines the script waits for; never task text.
import 'dart:convert';
import 'dart:io';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/intents/intent_providers.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/intents/action_queue_store.dart';
import 'package:dottoday/domain/profile/local_profile_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart' as tz_data;

const _a = '01928c3e-0000-7000-8000-0000000c160a';
const _b = '01928c3e-0000-7000-8000-0000000c160b';
const _channel = MethodChannel('dottoday/intents');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  testWidgets('CR-160 I7: shares keep the owner they were queued under', (
    tester,
  ) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final db = c.read(appDatabaseProvider);
    await c.read(localProfileProvider.future);
    final stage = await _stage();
    debugPrint('CR160S stage $stage');
    switch (stage) {
      case 0:
        await _signIn(c, _a);
        await _setStage(1);
        debugPrint('CR160S STAGE1 DONE');
      case 1:
        await _stage2(c, db);
      case 2:
        await _stage3(c, db);
    }
  }, timeout: const Timeout(Duration(minutes: 5)));
}

Future<void> _stage2(ProviderContainer c, AppDatabase db) async {
  // The cold start's share, read before anything drained it.
  final cold = _single(await _queue());
  expect(cold['owner'], _a, reason: 'stamped with the owner shown');
  await _drain(c);
  expect(await _owners(db, _id(cold)), {_a});
  await c.read(ownerSwitchProvider).signOut();
  await recordGuestChoice(db, _b, GuestChoice.keepSeparate);
  await _signIn(c, _b);

  final forB = await _awaitShare('SEND B');
  expect(forB['owner'], _b);
  await _drain(c);
  expect(await _owners(db, _id(forB)), {_b});

  // The published owner lags: it still names A while B is shown.
  await _publish(const QueueOwner(_a));
  final stale = await _awaitShare('SEND STALE');
  await c.read(ownerSwitchProvider).publishShownOwner();
  expect(stale['owner'], _a);
  await _drain(c);
  expect(await _owners(db, _id(stale)), isEmpty, reason: 'never B');
  expect((await _queue()).map(_id), contains(_id(stale)));
  await _setStage(2);
  debugPrint('CR160S STAGE2 DONE ${_id(stale)}');
}

Future<void> _stage3(ProviderContainer c, AppDatabase db) async {
  final waiting = _single(await _queue());
  expect(waiting['owner'], _a, reason: 'kept across a force-stop');
  await c.read(ownerSwitchProvider).publishShownOwner();
  await _drain(c);
  expect(await _owners(db, _id(waiting)), isEmpty, reason: 'B still shown');
  await c.read(ownerSwitchProvider).signOut();
  await _signIn(c, _a);
  expect(await _owners(db, _id(waiting)), {_a});
  expect(await _queue(), isEmpty);
  await _drain(c);
  expect(await _owners(db, _id(waiting)), {_a}, reason: 'once');

  // Mid-switch: the published owner names nobody.
  await _publish(const QueueSwitching());
  final nobody = await _awaitShare('SEND SWITCHING');
  await c.read(ownerSwitchProvider).publishShownOwner();
  expect(nobody.containsKey('owner'), isFalse);
  await _drain(c);
  expect(await _owners(db, _id(nobody)), isEmpty);
  expect((await _queue()).map(_id), [_id(nobody)]);
  // While an account is being deleted: the real share intent queues
  // nothing (ShareIntake refuses and shows its toast).
  await _publish(const QueueRefusing());
  final before = (await _queue()).map(_id).toList();
  debugPrint('CR160S SEND REFUSED');
  await Future<void>.delayed(const Duration(seconds: 12));
  expect((await _queue()).map(_id).toList(), before, reason: 'refused');
  await c.read(ownerSwitchProvider).publishShownOwner();
  await _setStage(3);
  debugPrint('CR160S RESULT PASS');
}

Future<void> _signIn(ProviderContainer c, String account) async {
  final db = c.read(appDatabaseProvider);
  await c
      .read(ownerSwitchProvider)
      .signIn(
        () => signInOwner(
          db,
          account,
          c.read(sharedHlcProvider),
          freshProfile: (id) =>
              freshAccountProfile(id, 'UTC', 'en', DateTime.now().toUtc()),
        ),
      );
}

Future<void> _drain(ProviderContainer c) =>
    c.read(actionQueueDrainerProvider).drain();

Future<void> _publish(QueueMarker marker) => _channel.invokeMethod<void>(
  'publishOwner',
  {'owner': encodeQueueMarker(marker)},
);

/// The native queue as the channel reads it.
Future<List<Map<String, Object?>>> _queue() async {
  final raw = await _channel.invokeMethod<String>('readQueue');
  final list = raw == null
      ? const <Object?>[]
      : jsonDecode(raw) as List<Object?>;
  return [for (final e in list) (e! as Map).cast<String, Object?>()];
}

/// Asks the script to share now, then waits for the new entry.
Future<Map<String, Object?>> _awaitShare(String step) async {
  final before = {for (final e in await _queue()) _id(e)};
  debugPrint('CR160S $step');
  for (var i = 0; i < 120; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    for (final e in await _queue()) {
      if (!before.contains(_id(e))) return e;
    }
  }
  fail('no share arrived for $step');
}

Map<String, Object?> _single(List<Map<String, Object?>> q) {
  expect(q, hasLength(1));
  return q.single;
}

String _id(Map<String, Object?> e) => e['id']! as String;

Future<Set<String>> _owners(AppDatabase db, String id) async => {
  for (final r in await (db.select(
    db.occurrences,
  )..where((o) => o.id.equals(id))).get())
    r.userId,
};

Future<File> _stageFile() async =>
    File('${(await getApplicationSupportDirectory()).path}/cr160_share_stage');

Future<int> _stage() async {
  final f = await _stageFile();
  return f.existsSync() ? int.parse(f.readAsStringSync()) : 0;
}

Future<void> _setStage(int n) async =>
    (await _stageFile()).writeAsStringSync('$n');
