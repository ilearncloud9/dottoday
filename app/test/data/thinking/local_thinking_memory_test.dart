import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/thinking/local_thinking_memory.dart';
import 'package:dottoday/domain/thinking/thinking_memory.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';

// Saved breakdowns, past lengths and the prompt log stay in local_meta on
// this device only (docs/09 M10.1, ADR-0009 §4).

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() => db.close());

  LocalThinkingMemory memory() => LocalThinkingMemory(db);

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
      await m.record(
        ThinkingExchange(
          kind: 'break_down',
          prompt: 'p$i',
          output: null,
          atUtc: t0,
        ),
      );
    }
    expect(await m.logLength(), 50);
    await m.saveBreakdown('x', const [ProposedStep(title: 'a')]);
    await m.clear();
    expect(await m.logLength(), 0);
    expect(await m.savedBreakdown('x'), isNull);
  });

  test('a corrupt value reads as empty', () async {
    await db
        .into(db.localMeta)
        .insert(
          LocalMetaCompanion.insert(
            key: LocalThinkingMemory.savedKey,
            value: '{nope',
          ),
        );
    expect(await memory().savedBreakdown('x'), isNull);
  });
}
