import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/db/owned_local_meta.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:dottoday/data/scheduling/learning_meta.dart';
import 'package:dottoday/data/sync/server_columns.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/scheduling/learning.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/export/export_fixtures.dart';
import '../../domain/fixtures.dart';
import '../../support/shown_owner.dart';

// docs/13 §6, §8: this device's learning memory — per-title resets and
// the reality reveal — in local_meta, never synced or exported.
void main() {
  late AppDatabase db;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await addProfile(db, ownerA);
  });
  tearDown(() => db.close());

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(c.dispose);
    return c;
  }

  final t0 = DateTime.utc(2026, 10, 26, 9);

  test('reset and Undo persist across a new start', () async {
    final c = container();
    final meta = c.read(learningMetaProvider.notifier);
    expect(await meta.reset('Deep  WORK', t0), isNull);
    final later = t0.add(const Duration(days: 1));
    expect(await meta.reset('deep work', later), t0);
    expect((await container().read(learningMetaProvider.future)).resets, {
      'deep work': later,
    });
    await meta.restoreReset('Deep work', t0);
    expect((await container().read(learningMetaProvider.future)).resets, {
      'deep work': t0,
    });
    await meta.restoreReset('Deep work', null);
    expect(
      (await container().read(learningMetaProvider.future)).resets,
      isEmpty,
    );
  });

  test('caption day, reveal and highlight are remembered', () async {
    final meta = container().read(learningMetaProvider.notifier);
    await meta.putCaptionAway(DateTime(2026, 10, 26, 18));
    await meta.markRealityRevealed(DateTime(2026, 10, 26));
    await meta.markRealityHighlighted();
    final again = await container().read(learningMetaProvider.future);
    expect(again.captionDay, DateTime(2026, 10, 26));
    expect((again.realityRevealed, again.realityHighlighted), (true, true));
  });

  test('an unreadable resets row counts as none', () async {
    await writeOwned(db, LearningMeta.resetsKey, ownerA, '{not json');
    expect(
      (await container().read(learningMetaProvider.future)).resets,
      isEmpty,
    );
  });

  group('per owner (CR-160)', () {
    setUp(() async {
      await addProfile(db, ownerB);
      await showOwner(db, ownerA);
    });

    Future<LearningMetaState> read(ProviderContainer c) =>
        c.read(learningMetaProvider.future);

    test('a switch shows nothing of A; A→B→A and a restart', () async {
      final c = container();
      await read(c);
      await c.read(learningMetaProvider.notifier).reset('A secret', t0);
      await c
          .read(learningMetaProvider.notifier)
          .markRealityRevealed(DateTime(2026, 10, 26));
      await showOwner(db, ownerB);
      c.read(ownerEpochProvider.notifier).next();
      final b = await read(c);
      expect(b.resets, isEmpty);
      expect(b.realityRevealed, isFalse);
      await c.read(learningMetaProvider.notifier).markRealityHighlighted();
      final restarted = await read(container());
      expect(restarted.resets, isEmpty, reason: 'after a restart, as B');
      expect(restarted.realityHighlighted, isTrue);
      await showOwner(db, ownerA);
      c.read(ownerEpochProvider.notifier).next();
      final a = await read(c);
      expect(a.resets.keys, ['a secret']);
      expect((a.realityRevealed, a.realityHighlighted), (true, false));
    });

    test('a legacy global value is kept and shown to nobody', () async {
      await db
          .into(db.localMeta)
          .insert(
            LocalMetaCompanion.insert(
              key: LearningMeta.resetsKey,
              value: '{"whose": 1}',
            ),
          );
      expect((await read(container())).resets, isEmpty);
      await showOwner(db, ownerB);
      expect((await read(container())).resets, isEmpty);
      final kept = await (db.select(
        db.localMeta,
      )..where((m) => m.key.equals(LearningMeta.resetsKey))).getSingle();
      expect(kept.value, '{"whose": 1}');
    });
  });

  test('a legacy value moves to the only profile', () async {
    await db
        .into(db.localMeta)
        .insert(
          LocalMetaCompanion.insert(
            key: LearningMeta.revealedKey,
            value: '2026-10-26',
          ),
        );
    expect(
      (await container().read(learningMetaProvider.future)).realityRevealed,
      isTrue,
    );
  });

  group('LearningIndex resets', () {
    Occurrence run(int d, {String title = 'Deep work', String? series}) {
      final at = t0.subtract(Duration(days: d));
      return occurrenceFixture().copyWith(
        id: 'r-$title-$d',
        title: title,
        seriesId: series,
        startUtc: at,
        actualStartUtc: at,
        actualEndUtc: at.add(const Duration(minutes: 60)),
        status: OccurrenceStatus.done,
      );
    }

    test('runs before the reset are gone, the series ones too', () {
      final history = [
        for (var d = 10; d <= 13; d++) run(d, series: 's'),
        for (var d = 2; d <= 3; d++) run(d, title: 'Old name', series: 's'),
      ];
      final reset = {'deep work': t0.subtract(const Duration(days: 5))};
      final before = LearningIndex.from(history);
      final after = LearningIndex.from(history, resets: reset);
      expect(before.forTask(title: 'Deep work', seriesId: 's').samples, 6);
      expect(after.forTask(title: 'Deep work', seriesId: 's').samples, 2);
      expect(after.forTask(title: 'Deep work').usualMinutes, isNull);
      expect((before.tasksReady, after.tasksReady), (1, 0));
    });

    test('the app-wide reality count ignores resets', () {
      final history = [for (var d = 1; d <= 4; d++) run(d)];
      expect(realityRuns(history), 4);
      expect(
        realityRuns([run(1).copyWith(status: OccurrenceStatus.planned)]),
        0,
      );
    });
  });

  test('the keys never sync and never reach an export', () {
    expect(syncedEntities, isNot(contains('local_meta')));
    final json = encodeExportJson(hostileBundle());
    for (final key in [
      LearningMeta.resetsKey,
      LearningMeta.captionKey,
      LearningMeta.revealedKey,
      LearningMeta.highlightedKey,
    ]) {
      expect(json, isNot(contains(key)));
    }
  });
}
