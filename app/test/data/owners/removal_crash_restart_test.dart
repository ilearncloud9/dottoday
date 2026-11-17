import 'dart:io';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/owner_meta.dart';
import 'package:dottoday/data/intents/intent_providers.dart';
import 'package:dottoday/data/owners/account_actions.dart';
import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/data/owners/removal_runner.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/sync/pull_guard.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/intents/dot_action.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../policy/source_scan.dart';
import '../../support/fake_notification_platform.dart';
import '../../support/owner_app.dart';
import '../../support/removal_world.dart';
import '../../support/shared_action_queue.dart';
import '../../support/timeline_fakes.dart';
import '../writes/write_harness.dart';

// CR-160 open item B (owner 2026-11-15, fail closed): a crash while A's
// account is being deleted leaves A's removal pending. Launch clears the
// deletion seal, but nothing may save to A until the removal finishes,
// and finishing it (again and again) touches no one else.

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  late Directory dir;
  late File file;
  late String guest;
  late AppDatabase db;
  late OwnerApp app;
  late SharedActionQueue queue;
  late Map<String, Object?> before;

  /// The app's next launch on the same file; [web] picks the browser.
  Future<void> relaunch({bool web = false}) async {
    queue = SharedActionQueue();
    db = AppDatabase(NativeDatabase(file));
    app = OwnerApp(
      db,
      FakeNotificationPlatform(),
      FakeSink(),
      FakeAlarmGateway(),
      queue,
      extra: [inBrowserProvider.overrideWithValue(web)],
    );
    await clearDeletionSeals(db); // what launch does
  }

  setUp(() async {
    ownerAppLogs.records.clear();
    dir = await Directory.systemTemp.createTemp('dottoday-removal');
    file = File('${dir.path}/db.sqlite');
    guest = await crashMidDeletion(file);
    await relaunch();
    before = await othersOf(db);
  });
  tearDown(() async {
    app.container.dispose();
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<Result<void, AppFailure>> write(String owner, String n) => app
      .container
      .read(writeUseCaseProvider)
      .apply(WriteBatch(userId: owner, occurrences: [task(owner, n)]));

  test('the pending mark survives the restart; A stays hidden, '
      'nothing half-removed', () async {
    expect(await pendingRemovals(db), [removedA]);
    expect(await app.shown(), guest);
    expect(await titlesOf(db, removedA), hasLength(2));
    expect(await wakeUpOwners(db), contains(removedA));
  });

  test(
    'with the seal cleared, nothing saves to A, even were A shown '
    '(a bug elsewhere): direct write, queued action, pull, calendar',
    () async {
      expect(await write(removedA, '12'), isA<Err<void, AppFailure>>());

      // Force A shown, so only the new guard stands in the way.
      await db.customStatement(
        'UPDATE local_meta SET value = ? WHERE key = ?',
        [removedA, activeOwnerKey],
      );
      expect(await write(removedA, '13'), isA<Err<void, AppFailure>>());
      final batch = WriteBatch(
        userId: removedA,
        occurrences: [task(removedA, '14')],
      ).whileShown();
      expect(
        await app.container.read(writeUseCaseProvider).apply(batch),
        isA<Err<void, AppFailure>>(),
      );

      queue.appendRaw(stampedFor(removedA, 'queued', const AddTask('Queued')));
      await app.container.read(actionQueueDrainerProvider).drain();
      expect(await titlesOf(db, removedA), hasLength(2));
      expect(queue.ids, contains('queued'), reason: 'kept, never applied');

      // Sync pulls, calendar import and write-back all commit through
      // checkPull inside their transaction: refused for the removal.
      final pull = (userId: removedA, generation: await ownerGeneration(db));
      await expectLater(
        db.transaction(() => checkPull(db, pull)),
        throwsA(
          isA<PullRefusedException>().having(
            (e) => e.reason,
            'reason',
            PullRefusal.removalPending,
          ),
        ),
      );
      expect(await ownerSessionOrNull(db, removedA), isNull);
      final lib = readLibSources('lib');
      for (final path in [
        'data/calendar/calendar_importer.dart',
        'data/calendar/calendar_write_back.dart',
      ]) {
        expect(
          lib[path],
          matches(
            RegExp(r'_db\.transaction\(\(\) async \{[\s\S]*?checkPull\('),
          ),
          reason: path,
        );
      }
    },
  );

  test('the shown guest and the other account still save', () async {
    expect(await write(guest, '20'), isA<Ok<void, AppFailure>>());
    expect(await write(otherB, '21'), isA<Ok<void, AppFailure>>());
  });

  test('iPhone, Android, Mac: launch finishes the removal by itself, '
      'despite the write guard', () async {
    await app.container.read(pendingRemovalRunnerProvider.future);
    await expectGone(db, removedA);
    expect(await othersOf(db), before);
  });

  test('web: launch leaves it pending and refused; Finish removing '
      'finishes it', () async {
    app.container.dispose();
    await db.close();
    await relaunch(web: true);
    await app.container.read(pendingRemovalRunnerProvider.future);
    expect(await pendingRemovals(db), [removedA]);
    expect(await write(removedA, '30'), isA<Err<void, AppFailure>>());

    final finished = await app.container
        .read(accountActionsProvider)
        .finishRemovals();
    expect(finished, isA<Ok<void, AppFailure>>());
    await expectGone(db, removedA);
    expect(await othersOf(db), before);
  });

  test('an interrupted cleanup changes nothing and resumes', () async {
    await expectLater(
      finishAccountRemoval(
        db,
        removedA,
        alsoRemove: () async => throw StateError('backup store busy'),
      ),
      throwsA(isA<StateError>()),
    );
    expect(await pendingRemovals(db), [removedA]);
    expect(await titlesOf(db, removedA), hasLength(2));
    expect(await othersOf(db), before);

    await app.container.read(pendingRemovalRunnerProvider.future);
    await expectGone(db, removedA);
    expect(await othersOf(db), before);
  });

  test('cleanup repeated after it finished: no change to anyone', () async {
    await app.container.read(pendingRemovalRunnerProvider.future);
    await expectGone(db, removedA);
    await finishAccountRemoval(db, removedA);
    await app.owners.finishRemoval(removedA);
    expect(
      await app.container.read(accountActionsProvider).finishRemovals(),
      isA<Ok<void, AppFailure>>(),
    );
    expect(await othersOf(db), before);
    expect(await localKeys(db), containsAll(lookAlikeKeys()));
  });
}
