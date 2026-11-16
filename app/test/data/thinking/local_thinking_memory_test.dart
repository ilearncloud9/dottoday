import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/db/owned_local_meta.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:dottoday/data/thinking/local_thinking_memory.dart';
import 'package:dottoday/data/thinking/thinking_providers.dart';
import 'package:dottoday/domain/thinking/thinking_memory.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';
import '../../support/shown_owner.dart';

// Saved breakdowns, past lengths and the prompt log stay in local_meta on
// this device only (docs/09 M10.1, ADR-0009 §4), each owner's apart
// (CR-160 I4).

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await addProfile(db, ownerA);
  });
  tearDown(() => db.close());

  LocalThinkingMemory memory() => LocalThinkingMemory(db);

  BrainDump dump(String text) => BrainDump(text: text, atUtc: t0);

  ThinkingExchange exchange(String prompt) => ThinkingExchange(
    kind: 'break_down',
    prompt: prompt,
    output: null,
    atUtc: t0,
  );

  test('a saved breakdown comes back for the same title, any case', () async {
    await memory().saveBreakdown('Clean the Kitchen', const [
      ProposedStep(title: 'Dishes', durationMin: 10),
      ProposedStep(title: '  '),
      ProposedStep(title: 'Floor'),
    ]);
    final steps = await memory().savedBreakdown('  clean   the kitchen');
    expect(steps, const [
      ProposedStep(title: 'Dishes', durationMin: 10),
      ProposedStep(title: 'Floor'),
    ]);
    expect(await memory().savedBreakdown('Laundry'), isNull);
  });

  test('keeps the 100 most recent titles', () async {
    final m = memory();
    for (var i = 0; i < 101; i++) {
      await m.saveBreakdown('task $i', const [ProposedStep(title: 'a')]);
    }
    await m.saveBreakdown('task 1', const [ProposedStep(title: 'b')]);
    expect(await m.savedBreakdown('task 0'), isNull);
    expect(await m.savedBreakdown('task 1'), const [ProposedStep(title: 'b')]);
    expect(await m.savedBreakdown('task 100'), isNotNull);
  });

  test('the log keeps the last 50 exchanges and clear forgets all', () async {
    final m = memory();
    for (var i = 0; i < 55; i++) {
      await m.record(exchange('p$i'));
    }
    expect(await m.logLength(), 50);
    await m.saveBreakdown('x', const [ProposedStep(title: 'a')]);
    await m.clear();
    expect(await m.logLength(), 0);
    expect(await m.savedBreakdown('x'), isNull);
  });

  test('a corrupt value reads as empty', () async {
    await writeOwned(db, LocalThinkingMemory.savedKey, ownerA, '{nope');
    expect(await memory().savedBreakdown('x'), isNull);
  });

  group('per owner (CR-160 I4)', () {
    setUp(() => addProfile(db, ownerB));

    Future<void> fillAs(String owner, String text) async {
      await showOwner(db, owner);
      final m = memory();
      await m.rememberDump(dump('$text dump'));
      await m.record(exchange('$text prompt'));
      await m.saveBreakdown('$text title', const [ProposedStep(title: 's')]);
    }

    test('each owner reads only its own dumps, log and breakdowns', () async {
      await fillAs(ownerA, 'A');
      await fillAs(ownerB, 'B');
      await showOwner(db, ownerA);
      final a = memory();
      expect([for (final d in await a.dumps()) d.text], ['A dump']);
      expect(await a.logLength(), 1);
      expect(await a.savedBreakdown('B title'), isNull);
      expect(await a.savedBreakdown('A title'), isNotNull);
      await showOwner(db, ownerB);
      expect([for (final d in await memory().dumps()) d.text], ['B dump']);
    });

    test('clear forgets the shown owner only', () async {
      await fillAs(ownerA, 'A');
      await fillAs(ownerB, 'B');
      await memory().clear();
      expect(await memory().dumps(), isEmpty);
      await showOwner(db, ownerA);
      expect(await memory().dumps(), hasLength(1));
    });

    test('a flow started before a switch writes into its own owner', () async {
      await showOwner(db, ownerA);
      final started = memory();
      await started.dumps();
      await showOwner(db, ownerB);
      await started.rememberDump(dump('late A'));
      expect(await memory().dumps(), isEmpty);
      await showOwner(db, ownerA);
      expect([for (final d in await memory().dumps()) d.text], ['late A']);
    });

    test('an instance retired before its first use stores nothing', () async {
      await showOwner(db, ownerA);
      final stale = memory()..retire();
      await showOwner(db, ownerB);
      await stale.rememberDump(dump('whose?'));
      expect(await memory().dumps(), isEmpty);
      await showOwner(db, ownerA);
      expect(await memory().dumps(), isEmpty);
    });

    test('a legacy global value is never shown with two profiles', () async {
      await db
          .into(db.localMeta)
          .insert(
            LocalMetaCompanion.insert(
              key: LocalThinkingMemory.dumpsKey,
              value: '[{"text":"whose?","at":0}]',
            ),
          );
      await showOwner(db, ownerB);
      expect(await memory().dumps(), isEmpty);
      await showOwner(db, ownerA);
      expect(await memory().dumps(), isEmpty);
      // Kept, untouched: it may be someone's draft.
      final kept = await (db.select(
        db.localMeta,
      )..where((m) => m.key.equals(LocalThinkingMemory.dumpsKey))).getSingle();
      expect(kept.value, '[{"text":"whose?","at":0}]');
      // B removed later: A is the only profile, but still can't be shown it.
      await (db.delete(db.profiles)..where((p) => p.id.equals(ownerB))).go();
      expect(await memory().dumps(), isEmpty);
    });
  });

  test('a legacy value moves to the device\'s only profile, once', () async {
    await db
        .into(db.localMeta)
        .insert(
          LocalMetaCompanion.insert(
            key: LocalThinkingMemory.dumpsKey,
            value: '[{"text":"mine","at":0}]',
          ),
        );
    expect([for (final d in await memory().dumps()) d.text], ['mine']);
    final keys = [for (final r in await db.select(db.localMeta).get()) r.key];
    expect(keys, contains(ownedKey(LocalThinkingMemory.dumpsKey, ownerA)));
    expect(keys, isNot(contains(LocalThinkingMemory.dumpsKey)));
    // A second owner arriving later never sees it.
    await addProfile(db, ownerB);
    await showOwner(db, ownerB);
    expect(await memory().dumps(), isEmpty);
  });

  test('the provider follows the shown owner: A→B→A, and a restart', () async {
    await addProfile(db, ownerB);
    ProviderContainer open() {
      final c = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(c.dispose);
      return c;
    }

    Future<List<String>> texts(ProviderContainer c) async => [
      for (final d in await c.read(thinkingMemoryProvider).dumps()) d.text,
    ];

    final c = open();
    await showOwner(db, ownerA);
    await c.read(thinkingMemoryProvider).rememberDump(dump('A text'));
    await showOwner(db, ownerB);
    c.read(ownerEpochProvider.notifier).next();
    expect(await texts(c), isEmpty);
    await c.read(thinkingMemoryProvider).rememberDump(dump('B text'));
    expect(await texts(open()), ['B text'], reason: 'after a restart');
    await showOwner(db, ownerA);
    c.read(ownerEpochProvider.notifier).next();
    expect(await texts(c), ['A text']);
  });
}
