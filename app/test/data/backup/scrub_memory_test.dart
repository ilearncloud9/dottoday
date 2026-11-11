import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/guest_backup_cutoff.dart';
import 'package:dottoday/data/backup/guest_backup_scrub.dart';
import 'package:dottoday/data/backup/legacy_guest_quarantine.dart';
import 'package:dottoday/data/backup/user_data_snapshot.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/guest_backup_world.dart';
import '../../support/owner_app.dart';

// CR-160 I1 scrub memory: the privacy scrubs list backups without their
// text and read one backup's text at a time, so never more than one
// backup (up to 25 MB) is held at once. Everything else is as before: a
// backup is recorded as scrubbed only after its rewrite, a failure on a
// later backup keeps the earlier work and the removal pending, and
// unreadable, oversized or ownerless backups stay hidden and untouched.

const _a = '01928c3e-0000-7000-8000-00000000000a';
const _secret = '01928c3e-0000-7000-8000-000000000da1';
const _kept = '01928c3e-0000-7000-8000-000000000db1';

/// Counts the backups' texts each query returns, and runs [beforeUpdate]
/// before every rewrite.
final class _PayloadReads extends QueryInterceptor {
  int most = 0;
  int total = 0;
  Future<void> Function(List<Object?> args)? beforeUpdate;

  /// Runs once, right after the ids are listed: "another change meanwhile".
  Future<void> Function(QueryExecutor executor)? afterListing;

  /// The backup whose text read fails.
  int? failRead;

  @override
  Future<List<Map<String, Object?>>> runSelect(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) async {
    if (statement.startsWith('SELECT owner, json') && args.first == failRead) {
      throw StateError('injected read failure');
    }
    final rows = await executor.runSelect(statement, args);
    if (statement.startsWith('SELECT id, owner') && afterListing != null) {
      final change = afterListing!;
      afterListing = null;
      await change(executor);
    }
    final texts = rows.where((r) => r['json'] != null).length;
    if (texts > most) most = texts;
    total += texts;
    return rows;
  }

  @override
  Future<int> runUpdate(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) async {
    await beforeUpdate?.call(args);
    return executor.runUpdate(statement, args);
  }
}

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  late GuestBackupWorld w;
  late String guest;
  setUp(() async {
    w = GuestBackupWorld();
    guest = await w.app.shown();
  });
  tearDown(() => w.dispose());

  Future<int> put(String json, {String? owner, int schema = 20}) => w.store
      .into(w.store.backups)
      .insert(
        BackupsCompanion.insert(
          createdAt: ownerAppNow.millisecondsSinceEpoch,
          reason: 'daily',
          appSchemaVersion: schema,
          json: json,
          owner: Value(owner),
        ),
      );

  Future<String> guestJson() async => encodeExportJson(
    (await w.db.transaction(() => readUserData(w.db, guest, ownerAppNow)))!,
  );

  /// Two legacy backups, three under the promotion's cutoff, one oversized,
  /// one not a backup and one with no owner; the moved work is then [_a]'s.
  Future<({List<int> legacy, List<int> p1, List<int> junk})> world() async {
    await w.write(guest, [w.task(guest, _kept, 'Kept')]);
    await w.app.owners.signOut();
    await w.write(guest, [w.task(guest, _secret, 'Secret plan')]);
    final legacy = [
      for (var i = 0; i < 2; i++) await put(await guestJson(), owner: guest),
    ];
    final p1 = [for (var i = 0; i < 3; i++) await w.backup(guest)];
    final junk = [
      await put('{"pad":"${'a' * (maxImportBytes + 1)}"}', owner: guest),
      await put('{"not":"a backup"}', owner: guest),
      await put(await guestJson()), // no owner
    ];
    await w.promote(_a);
    await w.app.owners.signOut();
    return (legacy: legacy, p1: p1, junk: junk);
  }

  /// A copy of the stored backups, same ids and owners, read through
  /// [reads].
  Future<BackupDatabase> tracked(_PayloadReads reads) async {
    final copy = BackupDatabase(NativeDatabase.memory().interceptWith(reads));
    for (final r in await w.store.select(w.store.backups).get()) {
      await copy.into(copy.backups).insert(r);
    }
    reads
      ..most = 0
      ..total = 0;
    return copy;
  }

  Future<String> jsonIn(BackupDatabase s, int id) async => (await (s.select(
    s.backups,
  )..where((b) => b.id.equals(id))).getSingle()).json;

  test('P2 and P3 read one backup\'s text at a time; each is recorded only '
      'after its rewrite', () async {
    final ids = await world();
    for (final run in ['P2', 'P3']) {
      final reads = _PayloadReads();
      final store = await tracked(reads);
      final rewritten = <int>[];
      reads.beforeUpdate = (args) async {
        final id = args.whereType<int>().single;
        final p = (await guestPromotions(w.db, guest)).single;
        expect(p.scrubbed, isNot(contains(id)), reason: 'marked first');
        rewritten.add(id);
      };
      final left = run == 'P2'
          ? await scrubForDeletedAccount(w.db, store, _a)
          : await scrubExpiredGuestBackups(
              w.db,
              store,
              nowUtc: ownerAppNow.add(const Duration(days: 31)),
            );
      expect(reads.most, 1, reason: '$run: one text per query');
      // The legacy ones hold the moved rows too: scrubbed, still
      // quarantined (legacy_guest_quarantine.dart).
      expect(rewritten, [...ids.legacy, ...ids.p1], reason: run);
      expect(left, 2, reason: '$run: oversized and malformed left');
      for (final id in [...ids.legacy, ...ids.p1]) {
        expect(await jsonIn(store, id), isNot(contains(_secret)));
      }
      for (final id in ids.junk) {
        expect(await jsonIn(store, id), await w.json(id), reason: 'untouched');
      }
      // Reset the markers this run recorded for the next one.
      await saveGuestPromotions(w.db, guest, [
        (await guestPromotions(w.db, guest)).single.copyWith(scrubbed: {}),
      ]);
      await store.close();
    }
  });

  test('the legacy scrub reads one backup\'s text at a time and leaves the '
      'others as they were', () async {
    final ids = await world();
    await w.db.customStatement(
      "DELETE FROM local_meta WHERE key LIKE 'guest_backup_promotions:%'",
    );
    final reads = _PayloadReads();
    final store = await tracked(reads);
    final result = await scrubLegacyByEvidence(w.db, store);
    expect(reads.most, 1);
    expect(result.scrubbed, 2);
    for (final id in ids.legacy) {
      expect(await jsonIn(store, id), isNot(contains(_secret)));
      expect(await jsonIn(store, id), contains(_kept));
    }
    for (final id in [...ids.p1, ...ids.junk]) {
      expect(await jsonIn(store, id), await w.json(id));
    }
    await store.close();
  });

  test(
    'a failure on the second backup: the first stays scrubbed, the rest '
    'hidden and unchanged, the removal pending; the rerun finishes',
    () async {
      final ids = await world();
      final second = ids.p1[1];
      await w.store.customStatement(
        'CREATE TRIGGER fail_second BEFORE UPDATE ON backups '
        "WHEN OLD.id = $second BEGIN SELECT RAISE(ABORT, 'injected'); END",
      );
      final before = {for (final id in ids.p1.skip(1)) id: await w.json(id)};
      await expectLater(w.app.owners.accountDeleted(_a), throwsA(anything));
      expect(await isRemovalPending(w.db, _a), isTrue);
      final v = await guestBackupVisibility(w.db, guest);
      expect(await w.json(ids.p1[0]), isNot(contains(_secret)));
      expect(v.hides(ids.p1[0]), isFalse, reason: 'scrubbed and recorded');
      for (final id in ids.p1.skip(1)) {
        expect(await w.json(id), before[id]);
        expect(v.hides(id), isTrue);
      }
      for (final id in [...ids.legacy, ...ids.junk]) {
        expect(await w.listed(), isNot(contains(id)));
      }
      await w.store.customStatement('DROP TRIGGER fail_second');
      await w.app.owners.finishRemoval(_a);
      expect(await isRemovalPending(w.db, _a), isFalse);
      final listed = await w.listed();
      expect(listed, containsAll(ids.p1));
      for (final id in [...ids.legacy, ...ids.junk]) {
        expect(listed, isNot(contains(id)), reason: '$id stays hidden');
      }
      for (final id in ids.p1) {
        expect(await w.json(id), isNot(contains(_secret)));
      }
    },
  );

  test('repeated maintenance changes nothing after the first run', () async {
    final ids = await world();
    w.clock.advance(const Duration(days: 31));
    Future<String> state() async => [
      for (final r in await w.store.select(w.store.backups).get())
        '${r.id}|${r.owner}|${r.json.hashCode}',
      await guestPromotions(w.db, guest).then((p) => '${p.single.scrubbed}'),
    ].join(';');
    await w.backups.runDailyIfDue(guest);
    final first = await state();
    for (var i = 0; i < 2; i++) {
      await w.backups.runDailyIfDue(guest);
      expect(await state(), first);
    }
    for (final id in ids.junk) {
      expect(await w.listed(), isNot(contains(id)));
      expect(await w.backups.restore(guest, id), isA<Err<void, AppFailure>>());
    }
  });

  test(
    'between listing and reading: a removed backup is skipped, one whose '
    'owner changed is left untouched and unrecorded, the rest scrubbed',
    () async {
      final ids = await world();
      final reads = _PayloadReads();
      final store = await tracked(reads);
      final changed = await jsonIn(store, ids.p1[1]);
      reads.afterListing = (e) async {
        await e.runDelete('DELETE FROM backups WHERE id = ?', [ids.p1[0]]);
        await e.runUpdate('UPDATE backups SET owner = ? WHERE id = ?', [
          '01928c3e-0000-7000-8000-00000000000b',
          ids.p1[1],
        ]);
      };
      final left = await scrubForDeletedAccount(w.db, store, _a);
      expect(left, 3, reason: 'owner changed, oversized, malformed');
      final scrubbed = (await guestPromotions(w.db, guest)).single.scrubbed;
      expect(scrubbed, isNot(contains(ids.p1[0])));
      expect(scrubbed, isNot(contains(ids.p1[1])));
      expect(scrubbed, contains(ids.p1[2]));
      expect(await jsonIn(store, ids.p1[1]), changed, reason: 'untouched');
      expect(await jsonIn(store, ids.p1[2]), isNot(contains(_secret)));
      await store.close();
    },
  );

  test('the legacy scrub: removed after listing skipped; owner changed '
      'counted unreadable, untouched', () async {
    final ids = await world();
    await w.db.customStatement(
      "DELETE FROM local_meta WHERE key LIKE 'guest_backup_promotions:%'",
    );
    final reads = _PayloadReads();
    final store = await tracked(reads);
    final changed = await jsonIn(store, ids.legacy[1]);
    reads.afterListing = (e) async {
      await e.runDelete('DELETE FROM backups WHERE id = ?', [ids.legacy[0]]);
      await e.runUpdate('UPDATE backups SET owner = ? WHERE id = ?', [
        '01928c3e-0000-7000-8000-00000000000b',
        ids.legacy[1],
      ]);
    };
    final result = await scrubLegacyByEvidence(w.db, store);
    expect(result, (scrubbed: 0, unreadable: 1));
    expect(await jsonIn(store, ids.legacy[1]), changed);
    await store.close();
  });

  test('a failed read is never skipped: the scrub stops, nothing after it is '
      'recorded, the failed one stays hidden', () async {
    final ids = await world();
    final reads = _PayloadReads()..failRead = ids.p1[1];
    final store = await tracked(reads);
    await expectLater(
      scrubForDeletedAccount(w.db, store, _a),
      throwsA(isA<StateError>()),
    );
    final scrubbed = (await guestPromotions(w.db, guest)).single.scrubbed;
    expect(scrubbed, isNot(contains(ids.p1[1])));
    expect(scrubbed, isNot(contains(ids.p1[2])));
    final v = await guestBackupVisibility(w.db, guest);
    expect(v.hides(ids.p1[1]), isTrue);
    expect(v.hides(ids.p1[2]), isTrue);
    await store.close();
  });
}
