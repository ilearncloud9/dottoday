import 'dart:io';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/deletion_world.dart';
import '../../support/owner_app.dart';
import '../writes/write_harness.dart';

// CR-160 policy §4, reminder actions: the race invariant (owner
// 2026-11-09). A save committed before the deletion is sealed is detected
// by the final check; a save after the seal is refused before it commits;
// nothing in between. Failed or empty saves never move the revision.

const _a = '01928c3e-0000-7000-8000-00000000000a';
const _b = '01928c3e-0000-7000-8000-00000000000b';

String _account(int i) =>
    '01928c3e-0000-7000-8000-${(0xa00 + i).toRadixString(16).padLeft(12, '0')}';

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });
  setUp(ownerAppLogs.records.clear);

  test('a save racing the final check is detected or refused, at every '
      'interleaving (one connection, as the app)', () async {
    final outcomes = <String>{};
    for (var turns = 0; turns < 80; turns += 2) {
      final w = await DeletionWorld.boot(_account(turns));
      final account = w.account;
      await w.actions.summary(account);
      final writes = w.app.container.read(writeUseCaseProvider);
      final deleting = w.actions.deleteAccount();
      await _yield(turns);
      final saving = writes.apply(
        WriteBatch(
          userId: account,
          occurrences: [w.task0.copyWith(durationMin: 31 + turns)],
        ),
      );
      final (deleted, saved) = await (deleting, saving).wait;
      if (saved is Ok) {
        // Committed before the seal: the deletion stopped and it is kept.
        expect(
          deleted,
          const Err<void, AppFailure>(ReviewChangedFailure()),
          reason: 'turn $turns',
        );
        expect((await w.row())!.durationMin, 31 + turns);
        outcomes.add('detected');
      } else {
        expect(deleted, isA<Ok<void, AppFailure>>(), reason: 'turn $turns');
        expect(await w.anyRows(), isEmpty);
        outcomes.add('refused');
      }
      await w.dispose();
    }
    // Both sides of the race were exercised, not only one.
    expect(outcomes, {'detected', 'refused'});
  });

  test(
    'a reminder Done racing the confirmation: kept and detected, or not '
    'saved; a refusal is only ever reported within its own session',
    () async {
      final outcomes = <String>{};
      // Negative: the tap starts that many microtasks before the confirmation.
      for (var turns = -30; turns < 80; turns += 2) {
        final w = await DeletionWorld.boot(_account(0x100 + turns + 30));
        await w.actions.summary(w.account);
        Future<void>? tapped;
        if (turns < 0) {
          tapped = w.responder.handle(w.tap('done'));
          await _yield(-turns);
        }
        final deleting = w.actions.deleteAccount();
        await _yield(turns);
        tapped ??= w.responder.handle(w.tap('done'));
        final (deleted, _) = await (deleting, tapped).wait;
        final why = 'turn $turns';
        expect(
          w.opened.where((o) => o != AppRoutes.today),
          isEmpty,
          reason: '$why: never the task of a deleted account',
        );
        // Never into another session (owner 2026-11-09).
        for (final r in w.refusedIn) {
          expect(r.tagged, r.shown, reason: '$why: reported in its session');
        }
        if (deleted is Err) {
          // Saved before the seal: kept, and the deletion stopped.
          expect(deleted, const Err<void, AppFailure>(ReviewChangedFailure()));
          expect((await w.row())!.status, OccurrenceStatus.done.name);
          expect(w.refused, isEmpty, reason: why);
          outcomes.add('detected');
        } else {
          // Not saved for anyone; said if its session was still shown.
          expect(w.refused, anyOf(isEmpty, [const StorageFailure()]));
          outcomes.add(w.refused.isEmpty ? 'unsaid' : 'refused');
        }
        expect(await w.anyRows(), deleted is Err ? hasLength(1) : isEmpty);
        await w.dispose();
      }
      expect(outcomes, containsAll(['detected', 'refused', 'unsaid']));
    },
  );

  test('two connections to one file (the background refresh opens its '
      'own): every save is counted by the seal or refused', () async {
    final dir = await Directory.systemTemp.createTemp('cr160_seal');
    final path = '${dir.path}/app.db';
    AppDatabase open() => AppDatabase(
      NativeDatabase.createInBackground(
        File(path),
        setup: (db) => db
          ..execute('PRAGMA journal_mode = WAL')
          ..execute('PRAGMA busy_timeout = 5000'),
      ),
    );
    final app = open();
    final background = WriteHarness(ownerAppNow, db: open());
    final owner = profileFixture().id;
    await background.writes.apply(
      WriteBatch(userId: owner, profile: profileFixture()),
    );
    final outcomes = <bool>[];
    for (var i = 0; i < 60; i++) {
      final before = await writeRevision(app, owner);
      final saving = background.writes.apply(
        WriteBatch(
          userId: owner,
          occurrences: [occurrenceFixture().copyWith(durationMin: 10 + i)],
        ),
      );
      if (i.isOdd) await Future<void>.delayed(Duration(microseconds: i * 50));
      int? sealed;
      try {
        sealed = await sealForDeletion(app, owner);
      } on Exception {
        sealed = null; // The deletion stops with a failure: safe.
      }
      final saved = await saving;
      if (sealed != null) {
        expect(
          sealed,
          saved is Ok ? before + 1 : before,
          reason: 'iteration $i: a committed save is what the seal read',
        );
      }
      // Sealed now: a save from the other connection is refused.
      if (sealed != null) {
        final late = await background.writes.apply(
          WriteBatch(
            userId: owner,
            occurrences: [occurrenceFixture().copyWith(durationMin: 200)],
          ),
        );
        expect(late, isA<Err<void, AppFailure>>());
        expect(await writeRevision(app, owner), sealed);
      }
      outcomes.add(saved is Ok);
      await unsealDeletion(app, owner);
    }
    await background.dispose();
    await app.close();
    await dir.delete(recursive: true);
    expect(outcomes, contains(true));
  });

  test('a change of owner between the lookup and the save: neither account '
      'changes and nothing is attributed to the new one', () async {
    late DeletionWorld w;
    w = await DeletionWorld.boot(
      _a,
      occurrences: (repo) => HookedOccurrences(repo, () => w.app.signIn(_b)),
    );
    final revision = await writeRevision(w.db, _a);
    await w.responder.handle(w.tap('done'));
    // Another session is shown now: nothing said in it (owner 2026-11-09).
    expect(w.refused, isEmpty);
    expect(w.opened, [AppRoutes.today]);
    expect((await w.row())!.status, OccurrenceStatus.planned.name);
    expect(await w.row(owner: _b), isNull);
    expect(await w.anyRows(), hasLength(1));
    expect(await writeRevision(w.db, _a), revision);
    expect(await writeRevision(w.db, _b), 0);
    await w.dispose();
  });

  group('the revision moves only for a committed change', () {
    late WriteHarness h;
    final owner = profileFixture().id;
    setUp(() async {
      h = WriteHarness(ownerAppNow);
      await h.writes.apply(
        WriteBatch(userId: owner, profile: profileFixture()),
      );
    });
    tearDown(() => h.dispose());

    test('a saved change: +1; the same rows again: unchanged', () async {
      final before = await writeRevision(h.db, owner);
      final batch = WriteBatch(
        userId: owner,
        occurrences: [occurrenceFixture()],
      );
      expect(await h.writes.apply(batch), isA<Ok<void, AppFailure>>());
      expect(await writeRevision(h.db, owner), before + 1);
      expect(await h.writes.apply(batch), isA<Ok<void, AppFailure>>());
      expect(await writeRevision(h.db, owner), before + 1);
    });

    test('a save that fails in its transaction: unchanged', () async {
      final before = await writeRevision(h.db, owner);
      // A task of a series that doesn't exist: the foreign key refuses it.
      final broken = occurrenceFixture().copyWith(
        seriesId: '01928c3e-0000-7000-8000-0000000009ff',
      );
      final result = await h.writes.apply(
        WriteBatch(userId: owner, occurrences: [broken]),
      );
      expect(result, isA<Err<void, AppFailure>>());
      expect(await writeRevision(h.db, owner), before);
    });

    test('a bump in a transaction that rolls back: unchanged', () async {
      final before = await writeRevision(h.db, owner);
      await expectLater(
        h.db.transaction(() async {
          await bumpWriteRevision(h.db, owner);
          throw StateError('rolled back');
        }),
        throwsStateError,
      );
      expect(await writeRevision(h.db, owner), before);
    });

    test('a save refused by the seal: unchanged, nothing written; other '
        'owners still save; unsealed, it saves', () async {
      final before = await writeRevision(h.db, owner);
      await sealForDeletion(h.db, owner);
      final batch = WriteBatch(
        userId: owner,
        occurrences: [occurrenceFixture()],
      );
      expect(
        await h.writes.apply(batch),
        const Err<void, AppFailure>(StorageFailure()),
      );
      expect(await h.db.select(h.db.occurrences).get(), isEmpty);
      expect(await writeRevision(h.db, owner), before);
      final other = profileFixture().copyWith(id: _b);
      expect(
        await h.writes.apply(WriteBatch(userId: _b, profile: other)),
        isA<Ok<void, AppFailure>>(),
      );
      await unsealDeletion(h.db, owner);
      expect(await h.writes.apply(batch), isA<Ok<void, AppFailure>>());
    });

    test("the app's launch clears a seal a crash left", () async {
      await sealForDeletion(h.db, owner);
      await clearDeletionSeals(h.db);
      expect(
        await h.writes.apply(
          WriteBatch(userId: owner, occurrences: [occurrenceFixture()]),
        ),
        isA<Ok<void, AppFailure>>(),
      );
    });
  });
}

/// Lets [turns] microtasks run: the in-memory database answers within
/// microtasks, so this reaches every step of the deletion.
Future<void> _yield(int turns) async {
  for (var i = 0; i < turns; i++) {
    await Future<void>.microtask(() {});
  }
}
