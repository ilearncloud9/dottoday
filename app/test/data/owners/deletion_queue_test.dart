import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/export/export_providers.dart';
import 'package:dottoday/data/intents/intent_providers.dart';
import 'package:dottoday/data/owners/account_actions.dart';
import 'package:dottoday/data/owners/account_export.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/intents/action_queue_store.dart';
import 'package:dottoday/domain/intents/dot_action.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/export_fakes.dart';
import '../../support/fake_notification_platform.dart';
import '../../support/owner_app.dart';
import '../../support/shared_action_queue.dart';
import '../../support/timeline_fakes.dart';
import '../writes/write_harness.dart';

// CR-160 policy §4 with I7 (owner 2026-11-09): what widgets and the share
// extension queued for an account is in its export; anything queued after
// the review stops the deletion until the person exports or confirms again;
// while the deletion runs, surfaces refuse new work; after it, nothing of
// the account is queued, shown, or the guest's.

const _a = '01928c3e-0000-7000-8000-00000000000a';
const _s1 = '01928c3e-0000-7000-8000-0000000004a1';
const _s2 = '01928c3e-0000-7000-8000-0000000004a2';
const _s3 = '01928c3e-0000-7000-8000-0000000004a3';

/// The server's `delete-account`, with hooks for what happens meanwhile.
final class _Server implements AccountService {
  late OwnerSwitch owners;
  void Function()? during;
  void Function()? after;
  var fails = false;
  var deletes = 0;

  @override
  Future<Result<void, AppFailure>> deleteAccount() async {
    deletes++;
    during?.call();
    if (fails) return const Err(NetworkFailure(NetworkFailureKind.server));
    await owners.accountDeleted(_a);
    after?.call();
    return const Ok(null);
  }

  @override
  bool get available => true;
  @override
  Stream<Account> watch() => const Stream.empty();
  @override
  Future<Result<void, AppFailure>> signIn(SignInMethod method) async =>
      const Ok(null);
  @override
  Future<Result<void, AppFailure>> sendMagicLink(String email) async =>
      const Ok(null);
  @override
  Stream<RestoreProgress?> watchRestore() => const Stream.empty();
  @override
  Future<Result<void, AppFailure>> signOut({bool everywhere = false}) async =>
      const Ok(null);
}

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  late AppDatabase db;
  late SharedActionQueue queue;
  late _Server server;
  late FakeFileGateway files;
  late OwnerApp app;
  late AccountActions actions;

  Future<Set<String>> rowsOf(String owner) async => {
    for (final r in await (db.select(
      db.occurrences,
    )..where((o) => o.userId.equals(owner))).get())
      r.id,
  };

  Future<Set<String>> ownersOf(String id) async => {
    for (final r in await (db.select(
      db.occurrences,
    )..where((o) => o.id.equals(id))).get())
      r.userId,
  };

  String exported() => files.delivered.last.single.content;

  setUp(() async {
    ownerAppLogs.records.clear();
    db = AppDatabase(NativeDatabase.memory());
    queue = SharedActionQueue();
    server = _Server();
    files = FakeFileGateway();
    app = OwnerApp(
      db,
      FakeNotificationPlatform(),
      FakeSink(),
      FakeAlarmGateway(),
      queue,
      extra: [
        accountServiceProvider.overrideWithValue(server),
        fileGatewayProvider.overrideWithValue(files),
      ],
    );
    server.owners = app.owners;
    actions = app.container.read(accountActionsProvider);
    await app.shown();
    await app.signIn(_a);
    await app.write([
      occurrenceFixture().copyWith(
        id: '01928c3e-0000-7000-8000-0000000001a1',
        userId: _a,
        tzId: 'UTC',
      ),
    ]);
  });
  tearDown(() async {
    app.container.dispose();
    await db.close();
  });

  test('the review applies what was queued: the summary counts it and the '
      'export holds it', () async {
    queue.append(_s1, const AddTask('Dentist', inbox: true));
    final summary = await actions.summary(_a);
    expect(summary.tasks, 2);
    expect(await actions.exportFirst(_a), OwnerExportOutcome.done);
    expect(exported(), contains(_s1));
  });

  test('a share during the export stops the deletion; exporting again '
      'keeps it, then deleting removes everything', () async {
    await actions.summary(_a);
    files.whileOpen = () =>
        queue.append(_s1, const AddTask('Dentist', inbox: true));
    expect(await actions.exportFirst(_a), OwnerExportOutcome.done);
    expect(exported(), isNot(contains(_s1)));
    expect(
      await actions.deleteAccount(),
      const Err<void, AppFailure>(ReviewChangedFailure()),
    );
    expect(server.deletes, 0, reason: 'nothing deleted');
    expect(queue.marker, contains(_a), reason: 'released again');
    expect(await actions.exportFirst(_a), OwnerExportOutcome.done);
    expect(exported(), contains(_s1));
    expect(await actions.deleteAccount(), isA<Ok<void, AppFailure>>());
    expect(await rowsOf(_a), isEmpty);
    expect(queue.ids, isEmpty);
  });

  test('a share between the export and the confirmation waits unapplied, '
      'stops the deletion, and goes only on a renewed confirmation', () async {
    await actions.summary(_a);
    expect(await actions.exportFirst(_a), OwnerExportOutcome.done);
    queue.append(_s1, const AddTask('Dentist', inbox: true));
    // A resume or queueChanged drain meanwhile: held for the review.
    await app.container.read(actionQueueDrainerProvider).drain();
    expect(await ownersOf(_s1), isEmpty);
    expect(await actions.deleteAccount(), isA<Err<void, AppFailure>>());
    expect(server.deletes, 0);
    // Told, the person confirms again without exporting: it goes too.
    expect(await actions.deleteAccount(), isA<Ok<void, AppFailure>>());
    final guest = await app.shown();
    expect(await ownersOf(_s1), isEmpty);
    expect(await rowsOf(guest), isEmpty);
    expect(queue.ids, isEmpty);
  });

  test('during the server deletion surfaces are refused, never queued for '
      'anyone', () async {
    await actions.summary(_a);
    bool? queuedDuring;
    server.during = () =>
        queuedDuring = queue.append(_s1, const AddTask('Dentist'));
    expect(await actions.deleteAccount(), isA<Ok<void, AppFailure>>());
    expect(queuedDuring, isFalse);
    expect(queue.ids, isEmpty);
    expect(await ownersOf(_s1), isEmpty);
  });

  test("after the account's removal is recorded: refused until the "
      "deletion ends, then the guest's, never the deleted account's", () async {
    await actions.summary(_a);
    bool? queuedAfter;
    server.after = () =>
        queuedAfter = queue.append(_s1, const AddTask('Right after'));
    await actions.deleteAccount();
    expect(queuedAfter, isFalse);
    expect(queue.append(_s2, const AddTask('Later')), isTrue);
    final guest = await app.shown();
    await app.container.read(actionQueueDrainerProvider).drain();
    expect(await ownersOf(_s2), {guest});
    expect(queue.marker, isNot(contains(_a)));
  });

  test('a failed server deletion releases: what came meanwhile was refused, '
      'what was held applies once D1 closes', () async {
    queue.append(_s1, const AddTask('Before'));
    await actions.summary(_a);
    queue.append(_s2, const AddTask('Held'));
    server.fails = true;
    bool? during;
    server.during = () => during = queue.append(_s3, const AddTask('No'));
    // The held share stops it first; then the server refuses.
    expect(await actions.deleteAccount(), isA<Err<void, AppFailure>>());
    expect(await actions.deleteAccount(), isA<Err<void, AppFailure>>());
    expect(during, isFalse);
    expect(queue.marker, contains(_a));
    actions.endDeletion(_a);
    await app.container.read(actionQueueDrainerProvider).drain();
    expect(await ownersOf(_s1), {_a});
    expect(await ownersOf(_s2), {_a});
    expect(await ownersOf(_s3), isEmpty);
  });

  test(
    "an export can't claim done while queued work couldn't be applied",
    () async {
      // An Add task whose id the guest already holds: kept, never applied.
      final guest = await _guestOf(app);
      await app.write([
        occurrenceFixture().copyWith(id: _s3, userId: guest, tzId: 'UTC'),
      ]);
      queue.appendRaw({
        'id': _s3,
        'at_ms': ownerAppNow.millisecondsSinceEpoch,
        'kind': 'add_task',
        'text': 'Collides',
        'owner': _a,
      });
      expect(await actions.exportFirst(_a), OwnerExportOutcome.failed);
      expect(files.delivered, isEmpty);
    },
  );

  test('declining the export: the summary counted it, the confirmed '
      'deletion takes it, nothing becomes the guest\'s', () async {
    queue.append(_s1, const AddTask('Counted'));
    final summary = await actions.summary(_a);
    expect(summary.tasks, 2);
    expect(await actions.deleteAccount(), isA<Ok<void, AppFailure>>());
    final guest = await app.shown();
    expect(await ownersOf(_s1), isEmpty);
    expect(await rowsOf(guest), isEmpty);
    expect(
      queue.published.whereType<QueueOwner>().map((o) => o.id).last,
      guest,
    );
  });
}

/// The guest profile's id (the oldest non-account profile).
Future<String> _guestOf(OwnerApp app) async {
  final rows = await app.db.select(app.db.profiles).get();
  return rows.firstWhere((p) => p.id != _a).id;
}
