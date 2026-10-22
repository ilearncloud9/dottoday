@Tags(['perf'])
library;

import 'dart:io';
import 'dart:math';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/connection/cipher_setup.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_search_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/data/repositories/drift_subtask_repository.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/features/search/state/search_state.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';

// R-15 / docs/09 M2.7: with 10 000 occurrences, a day query must stay under
// one frame (16 ms) and search under 50 ms (p95). Measured on an encrypted
// file database behind a background isolate, as the app opens it.

const _total = 10000;
const _busyDayBlocks = 200;
const _runs = 50;
final _start = DateTime.utc(2026);
final _busyDay = DateTime.utc(2026, 6, 15);
const _words = ['dentist', 'gym', 'report', 'call', 'groceries', 'review'];

void main() {
  late Directory dir;
  late AppDatabase db;

  setUpAll(() async {
    dir = Directory.systemTemp.createTempSync('perf');
    db = AppDatabase(
      NativeDatabase.createInBackground(
        File('${dir.path}/perf.db'),
        setup: (raw) => configureCipherConnection(raw, 'ab' * 32),
      ),
    );
    await _seed(db);
  });
  tearDownAll(() async {
    await db.close();
    dir.deleteSync(recursive: true);
  });

  test('day query p95 < 16 ms (normal and 200-block day)', () async {
    final repo = DriftOccurrenceRepository(db);
    Future<int> day(DateTime d) async =>
        (await repo.watchRange(userId, d, d.add(const Duration(days: 1))).first)
            .length;

    expect(await day(_busyDay), greaterThanOrEqualTo(_busyDayBlocks));
    final normal = await _p95(() => day(DateTime.utc(2026, 3, 10)));
    final busy = await _p95(() => day(_busyDay));
    // Printed so CI logs show the trend, not just pass/fail.
    // ignore: avoid_print
    print('day p95: normal ${normal}ms, busy ${busy}ms');
    expect(normal, lessThan(16));
    expect(busy, lessThan(16));
  });

  test('search p95 < 50 ms', () async {
    final repo = DriftSearchRepository(db);
    expect(await repo.search(userId, 'dent'), isNotEmpty);
    final one = await _p95(() => repo.search(userId, 'groc'));
    final two = await _p95(() => repo.search(userId, 'call rev'));
    // ignore: avoid_print
    print('search p95: one term ${one}ms, two terms ${two}ms');
    expect(one, lessThan(50));
    expect(two, lessThan(50));
  });

  test('search through the provider p95 < 50 ms (M3d.1)', () async {
    final container = ProviderContainer(
      overrides: [
        searchRepositoryProvider.overrideWithValue(DriftSearchRepository(db)),
        settingsRepositoryProvider.overrideWithValue(
          DriftSettingsRepository(db),
        ),
        localProfileProvider.overrideWith((ref) async => profileFixture()),
      ],
    );
    addTearDown(container.dispose);
    // What the Search screen does on each keystroke: a fresh query read
    // through the live provider (FTS + row mapping + stream setup).
    var n = 0;
    Future<int> run() async {
      final query = (n++).isEven ? 'groc' : 'call rev';
      final sub = container.listen(searchHitsProvider(query), (_, _) {});
      try {
        return (await container.read(searchHitsProvider(query).future)).length;
      } finally {
        sub.close();
        container.invalidate(searchHitsProvider(query));
      }
    }

    expect(await run(), greaterThan(0));
    final p95 = await _p95(run);
    // ignore: avoid_print
    print('search via provider p95: ${p95}ms');
    expect(p95, lessThan(50));
  });

  test('inbox query p95 < 16 ms', () async {
    final repo = DriftOccurrenceRepository(db);
    final inbox = await _p95(() => repo.watchInbox(userId).first);
    expect(inbox, lessThan(16));
  });
}

/// p95 wall time in ms of [run] after warm-up.
Future<double> _p95(Future<Object?> Function() run) async {
  for (var i = 0; i < 5; i++) {
    await run();
  }
  final times = <double>[];
  for (var i = 0; i < _runs; i++) {
    final sw = Stopwatch()..start();
    await run();
    times.add(sw.elapsedMicroseconds / 1000);
  }
  times.sort();
  return times[(times.length * 0.95).ceil() - 1];
}

Future<void> _seed(AppDatabase db) async {
  final rnd = Random(42);
  await DriftSettingsRepository(db).upsert(profileFixture());
  final occurrences = <Occurrence>[];
  final subtasks = <Subtask>[];
  for (var i = 0; i < _total; i++) {
    final busy = i < _busyDayBlocks;
    final start = busy
        ? _busyDay.add(Duration(minutes: i * 5))
        : _start.add(Duration(minutes: rnd.nextInt(365 * 24 * 60)));
    final id = 'o${i.toString().padLeft(5, '0')}';
    occurrences.add(
      occurrenceFixture().copyWith(
        id: id,
        title: '${_words[i % _words.length]} $i',
        notes: i.isEven ? 'notes for ${_words[(i + 1) % _words.length]}' : null,
        // Every 20th lives in the inbox.
        startUtc: i % 20 == 19 ? null : start,
        durationMin: 15 + rnd.nextInt(60),
        sortOrder: i.toDouble(),
      ),
    );
    if (i % 4 == 0) {
      subtasks.add(
        subtaskFixture().copyWith(
          id: 's$i',
          occurrenceId: id,
          title: 'step $i',
        ),
      );
    }
  }
  await db.transaction(() async {
    await DriftOccurrenceRepository(db).upsertAll(occurrences);
    await DriftSubtaskRepository(db).upsertAll(subtasks);
  });
}
