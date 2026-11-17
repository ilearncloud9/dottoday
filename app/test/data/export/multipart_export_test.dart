import 'dart:io';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/user_data_snapshot.dart';
import 'package:dottoday/data/export/multipart_export.dart';
import 'package:dottoday/data/export/prepared_file.dart';
import 'package:dottoday/data/export/prepared_file_store_io.dart';
import 'package:dottoday/domain/export/export_handoff.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/export_set_world.dart';
import '../../support/guest_backup_world.dart';
import '../../support/owner_app.dart';
import '../../support/staged_import_world.dart';

// CR-160 Stage B6 (docs/cr-160-multipart-export.md §4, §10): a multipart
// export read from the database a part at a time, every file prepared
// (written, read back, hash matched); possession confirmed only for
// exactly that set.

/// A store whose [failAt]th file doesn't read back.
final class _Flaky implements PreparedFileStore {
  _Flaky(this.failAt);
  final int failAt;
  final _inner = MemoryPreparedFileStore();
  var _n = 0;
  var discarded = false;

  @override
  Future<PreparedFile> put(String name, List<int> bytes, String hash) {
    if (++_n == failAt) throw PreparedMismatch(name);
    return _inner.put(name, bytes, hash);
  }

  @override
  Future<void> discard() async => discarded = true;
}

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  late GuestBackupWorld w;
  setUp(() async => w = await exportWorld());
  tearDown(() => w.dispose());

  test('a set of several parts, each prepared and named by the set; it '
      'imports to exactly the account', () async {
    final set = setOf(await prepareSet(w, MemoryPreparedFileStore()));
    expect(set.parts.length, greaterThan(3));
    expect(set.manifest.purpose, ExportPurpose.export);
    expect(
      set.files.first.name,
      'dottoday-backup-2026-11-11-000000f1-manifest.json',
    );
    for (final (i, p) in set.parts.indexed) {
      final entry = set.manifest.parts[i];
      expect(
        (p.name, p.sha256, p.size),
        (entry.name, entry.sha256, entry.bytes),
      );
      expect(sha256Hex(preparedText(p)), entry.sha256);
      expect(entry.bytes, lessThanOrEqualTo(8000));
    }
    final want = await w.db.transaction(
      () => readUserData(w.db, stagedOwner, ownerAppNow),
    );
    expect(set.manifest.totals['occurrences'], want!.occurrences.length);
    expect(set.manifest.totals['calendarSeries'], 0, reason: 'not D1');

    // Restored into another account's world: the same tasks.
    final other = await stagedWorld();
    addTearDown(other.dispose);
    expect(
      await stagedImporter(other).importMultipart(
        stagedOwner,
        preparedText(set.manifestFile),
        parts: [for (final p in set.parts) () async => preparedText(p)],
        safety: () async => const Ok(null),
      ),
      isA<Ok<void, AppFailure>>(),
    );
    expect(await other.titlesOf(stagedOwner), {
      for (final o in want.occurrences)
        if (o.deletedAt == null) o.title,
    });
  });

  test('an account that fits one part is today\'s single file', () async {
    expect(
      await prepareSet(w, MemoryPreparedFileStore(), targetBytes: 20000000),
      isA<Ok<PreparedExport, AppFailure>>().having(
        (o) => o.value,
        'value',
        isA<FitsOneFile>(),
      ),
    );
  });

  test(
    'a row larger than any part fails the export, nothing left out',
    () async {
      final store = _Flaky(0);
      expect(
        await prepareSet(w, store, targetBytes: 1500),
        isA<Err<PreparedExport, AppFailure>>().having(
          (e) => e.failure,
          'failure',
          isA<ExportTooLargeFailure>(),
        ),
      );
    },
  );

  test('a file that does not read back fails it and removes what was '
      'prepared', () async {
    final store = _Flaky(3);
    expect(await prepareSet(w, store), isA<Err<PreparedExport, AppFailure>>());
    expect(store.discarded, isTrue);
  });

  test('an incomplete set (the check fails) is never prepared', () async {
    final store = _Flaky(0);
    expect(
      await prepareSet(w, store, complete: (_) async => false),
      isA<Err<PreparedExport, AppFailure>>(),
    );
    expect(store._n, 0, reason: 'checked before any file');
  });

  test('native: files in a temporary folder, read back, then '
      'removed', () async {
    final store = TempPreparedFileStore();
    final set = setOf(await prepareSet(w, store));
    for (final f in set.files) {
      expect(File(f.path!).existsSync(), isTrue);
      expect(sha256Hex(await File(f.path!).readAsString()), f.sha256);
    }
    final dir = File(set.parts.first.path!).parent;
    await store.discard();
    expect(dir.existsSync(), isFalse);
    expect(
      () => TempPreparedFileStore().put('x.json', [1, 2], 'f' * 64),
      throwsA(isA<PreparedMismatch>()),
    );
  });

  group('possession', () {
    late PreparedSet set;
    late String manifest;
    late List<String> parts;
    setUp(() async {
      set = setOf(await prepareSet(w, MemoryPreparedFileStore()));
      manifest = preparedText(set.manifestFile);
      parts = [for (final p in set.parts) preparedText(p)];
    });
    PossessionCheck check(String m, Iterable<String> ps) =>
        checkPossession(set.manifest, m, ps);
    Matcher not(PossessionProblem p) =>
        isA<PossessionNotConfirmed>().having((n) => n.problem, 'problem', p);

    test('exactly the set, in any order: confirmed', () {
      expect(check(manifest, parts.reversed), isA<PossessionConfirmed>());
    });

    test('a part missing, changed or twice; another export: not', () async {
      expect(
        check(manifest, parts.skip(1)),
        not(PossessionProblem.partMissing),
      );
      expect(
        check(manifest, [...parts.skip(1), '${parts.first} ']),
        not(PossessionProblem.partRefused),
      );
      expect(
        check(manifest, [...parts, parts.first]),
        not(PossessionProblem.duplicate),
      );
      final again = setOf(
        await prepareSet(w, MemoryPreparedFileStore(), targetBytes: 9000),
      );
      expect(
        check(preparedText(again.manifestFile), parts),
        not(PossessionProblem.notThisExport),
      );
      expect(
        check(manifest, [for (final p in again.parts) preparedText(p)]),
        isNot(isA<PossessionConfirmed>()),
      );
    });
  });
}
