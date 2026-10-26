import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_series_repository.dart';
import 'package:dottoday/data/snapshot/day_snapshot_writer.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/intents/dot_action.dart';
import 'package:dottoday/domain/intents/dot_intents.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/writes/write_harness.dart';
import '../fixtures.dart';

// The five B6 intents (docs/09 M9.2), one use-case each, against the real
// write path: every change lands in the database and is safe to replay.

final _now = DateTime.utc(2026, 10, 21, 14); // 10:00 in New York
const _other = '01928c3e-0000-7000-8000-0000000000ff';

void main() {
  late WriteHarness h;
  late DotIntents intents;
  late DriftOccurrenceRepository occurrences;
  final live = occurrenceFixture().copyWith(
    startUtc: _now.subtract(const Duration(minutes: 10)),
    durationMin: 30,
  );

  Future<Occurrence> stored(String id) async =>
      (await occurrences.findById(userId, id))!;

  QueuedAction queued(
    DotAction action, {
    String id = '01928c3e-0000-7000-8000-00000000a000',
  }) => QueuedAction(id: id, createdAtUtc: _now, action: action);

  setUp(() async {
    h = WriteHarness(_now);
    occurrences = DriftOccurrenceRepository(h.db);
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        profile: profileFixture(),
        occurrences: [live],
      ),
    );
    await h.effects.idle;
    intents = DotIntents(
      clock: h.clock,
      writes: h.writes,
      occurrences: occurrences,
      series: DriftSeriesRepository(h.db),
      profile: () async => profileFixture(),
      snapshot: () => DaySnapshotWriter(
        clock: h.clock,
        occurrences: occurrences,
        profile: () async => profileFixture(),
        sink: h.sink,
      ).write(userId),
      untitled: (_) => 'Untitled',
    );
  });
  tearDown(() => h.dispose());

  group('MarkDone', () {
    test('ticks the task with its actual end; again changes nothing', () async {
      final action = queued(MarkDone(live.id));
      expect(await intents.apply(action), ActionOutcome.applied);
      final done = await stored(live.id);
      expect(done.status, OccurrenceStatus.done);
      expect(done.actualEndUtc, _now);
      expect(await intents.apply(action), ActionOutcome.alreadyApplied);
    });

    test('a deleted task or another account\'s id is dropped', () async {
      await h.writes.apply(
        WriteBatch(
          userId: userId,
          occurrences: [live.copyWith(deletedAt: _now)],
        ),
      );
      expect(
        await intents.apply(queued(MarkDone(live.id))),
        ActionOutcome.droppedMissing,
      );
      expect(
        await intents.apply(queued(const MarkDone(_other))),
        ActionOutcome.droppedMissing,
      );
    });
  });

  group('AddFifteen', () {
    test('adds 15 minutes once, even when replayed', () async {
      final action = queued(AddFifteen(live.id, plannedEndUtc: live.endUtc!));
      expect(await intents.apply(action), ActionOutcome.applied);
      expect((await stored(live.id)).durationMin, 45);
      expect(await intents.apply(action), ActionOutcome.alreadyApplied);
      expect((await stored(live.id)).durationMin, 45);
    });

    test(
      'an end with microseconds still matches its stored millisecond',
      () async {
        final action = queued(
          AddFifteen(
            live.id,
            plannedEndUtc: live.endUtc!.add(const Duration(microseconds: 600)),
          ),
        );
        expect(await intents.apply(action), ActionOutcome.applied);
      },
    );

    test('an end the task no longer has is stale', () async {
      final action = queued(
        AddFifteen(
          live.id,
          plannedEndUtc: live.endUtc!.add(const Duration(hours: 1)),
        ),
      );
      expect(await intents.apply(action), ActionOutcome.droppedStale);
      expect((await stored(live.id)).durationMin, 30);
    });
  });

  test('StartFocus records the first start only', () async {
    expect(
      await intents.apply(queued(StartFocus(live.id))),
      ActionOutcome.applied,
    );
    expect((await stored(live.id)).actualStartUtc, _now);
    h.clock.advance(const Duration(minutes: 5));
    expect(
      await intents.apply(queued(StartFocus(live.id))),
      ActionOutcome.alreadyApplied,
    );
    expect((await stored(live.id)).actualStartUtc, _now);
  });

  group('AddTask', () {
    test('parses the text; the action id becomes the task id', () async {
      const id = '01928c3e-0000-7000-8000-0000000000a1';
      final action = queued(const AddTask('Call mum 3pm 20m'), id: id);
      expect(await intents.apply(action), ActionOutcome.applied);
      final task = await stored(id);
      expect(task.title, 'Call mum');
      expect(task.durationMin, 20);
      expect(task.startUtc, DateTime.utc(2026, 10, 21, 19)); // 15:00 EDT
      expect(await intents.apply(action), ActionOutcome.alreadyApplied);
      expect(
        (await h.db.select(h.db.occurrences).get()).where((r) => r.id == id),
        hasLength(1),
      );
    });

    test('without a time it goes to the Inbox', () async {
      const id = '01928c3e-0000-7000-8000-0000000000a2';
      await intents.apply(queued(const AddTask('Buy stamps'), id: id));
      expect((await stored(id)).startUtc, isNull);
    });

    test('a share waits in the Inbox with its source as the note', () async {
      const id = '01928c3e-0000-7000-8000-0000000000a4';
      final shared = decodeQueuedAction({
        'id': id,
        'at_ms': _now.millisecondsSinceEpoch,
        'kind': 'add_task',
        'shared': true,
        'text': 'Dentist tomorrow 3pm 20m https://dentist.example/booking',
      })!;
      expect(await intents.apply(shared), ActionOutcome.applied);
      final task = await stored(id);
      expect(task.title, 'Dentist');
      expect(task.startUtc, isNull, reason: 'shares wait in the Inbox');
      expect(task.durationMin, 20);
      expect(
        task.notes,
        'Dentist tomorrow 3pm 20m https://dentist.example/booking',
      );
      expect(await intents.apply(shared), ActionOutcome.alreadyApplied);
    });

    test('a repeating line becomes a series under the action id', () async {
      const id = '01928c3e-0000-7000-8000-0000000000a3';
      final action = queued(const AddTask('Stretch 7am every day'), id: id);
      expect(await intents.apply(action), ActionOutcome.applied);
      expect(await DriftSeriesRepository(h.db).findById(userId, id), isNotNull);
      expect(await intents.apply(action), ActionOutcome.alreadyApplied);
    });
  });

  test('WhatsNext rewrites the snapshot and names the live dot', () async {
    final before = h.sink.written.length;
    final snapshot = await intents.whatsNext();
    expect(h.sink.written.length, before + 1);
    expect(snapshot.current?.id, live.id);
  });

  test('run() applies an action as a fresh entry', () async {
    expect(await intents.run(MarkDone(live.id)), ActionOutcome.applied);
  });
}
