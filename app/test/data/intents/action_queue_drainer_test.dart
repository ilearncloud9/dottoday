import 'dart:convert';

import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/intents/action_queue_drainer.dart';
import 'package:dottoday/data/intents/action_queue_json.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_series_repository.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/intents/action_queue_store.dart';
import 'package:dottoday/domain/intents/dot_action.dart';
import 'package:dottoday/domain/intents/dot_intents.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';
import '../writes/write_harness.dart';

/// The queue as a shared store holds it: JSON text that "another process"
/// may append to while a drain runs ([onRead]).
final class _MemoryStore implements ActionQueueStore {
  String raw = '[]';
  void Function()? onRead;

  void append(Object? entry) =>
      raw = jsonEncode([...decodeQueueArray(raw), entry]);

  List<Object?> get entries => decodeQueueArray(raw);

  @override
  Future<List<Object?>> read() async {
    final entries = decodeQueueArray(raw);
    onRead?.call();
    return entries;
  }

  @override
  Future<void> remove(Set<String> ids, {bool unreadable = false}) async =>
      raw = withoutEntries(raw, ids, unreadable: unreadable);
}

final _now = DateTime.utc(2026, 10, 21, 14);
const _a1 = '01928c3e-0000-7000-8000-00000000a001';
const _a2 = '01928c3e-0000-7000-8000-00000000a002';
const _late = '01928c3e-0000-7000-8000-00000000a003';

void main() {
  late WriteHarness h;
  late _MemoryStore store;
  late ActionQueueDrainer drainer;
  late DriftOccurrenceRepository occurrences;
  final base = occurrenceFixture().copyWith(
    startUtc: _now.subtract(const Duration(minutes: 10)),
    durationMin: 30,
  );

  Map<String, Object?> entry(String id, DotAction action) => encodeQueuedAction(
    QueuedAction(id: id, createdAtUtc: _now, action: action),
  );

  setUp(() async {
    h = WriteHarness(_now);
    occurrences = DriftOccurrenceRepository(h.db);
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        profile: profileFixture(),
        occurrences: [base],
      ),
    );
    await h.effects.idle;
    store = _MemoryStore();
    drainer = ActionQueueDrainer(
      store: store,
      intents: DotIntents(
        clock: h.clock,
        writes: h.writes,
        occurrences: occurrences,
        series: DriftSeriesRepository(h.db),
        profile: () async => profileFixture(),
        snapshot: () => throw UnimplementedError(),
        untitled: (_) => 'Untitled',
      ),
      logger: h.logger,
    );
  });
  tearDown(() => h.dispose());

  test('applies in order and empties the queue', () async {
    // +15 first, then Done: in order the task ends 15 min later, done.
    store
      ..append(entry(_a1, AddFifteen(base.id, plannedEndUtc: base.endUtc!)))
      ..append(entry(_a2, MarkDone(base.id)));
    expect(await drainer.drain(), 2);
    final task = (await occurrences.findById(userId, base.id))!;
    expect(task.durationMin, 45);
    expect(task.status, OccurrenceStatus.done);
    expect(store.entries, isEmpty);
  });

  test('+15, the same +15 again, then Done (the activity\'s path)', () async {
    store
      ..append(entry(_a1, AddFifteen(base.id, plannedEndUtc: base.endUtc!)))
      ..append(entry(_a2, AddFifteen(base.id, plannedEndUtc: base.endUtc!)));
    await drainer.drain();
    store.append(entry(_late, MarkDone(base.id)));
    await drainer.drain();
    final task = (await occurrences.findById(userId, base.id))!;
    expect((task.durationMin, task.status), (45, OccurrenceStatus.done));
  });

  test('replaying the same entries changes nothing (idempotent)', () async {
    final plus = entry(_a1, AddFifteen(base.id, plannedEndUtc: base.endUtc!));
    store.append(plus);
    await drainer.drain();
    // The app died before the queue was emptied: the entry comes back.
    store.append(plus);
    expect(await drainer.drain(), 0);
    expect((await occurrences.findById(userId, base.id))!.durationMin, 45);
    expect(store.entries, isEmpty);
  });

  test('an action for a deleted task is dropped and logged by id', () async {
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        occurrences: [base.copyWith(deletedAt: _now)],
      ),
    );
    store.append(entry(_a1, MarkDone(base.id)));
    expect(await drainer.drain(), 0);
    expect(store.entries, isEmpty);
    final dropped = h.logs.records.singleWhere(
      (r) => r.event == 'intent.dropped',
    );
    expect(dropped.level, LogLevel.info);
    expect(dropped.fields, {
      'action': _a1,
      'reason': 'droppedMissing',
      'occurrence': base.id,
    });
  });

  test('a failed write stops the drain and keeps the rest queued', () async {
    // A row for an unknown profile fails the write path's FK check.
    store
      ..append(entry(_a1, const AddTask('ok')))
      ..append(entry(_a2, MarkDone(base.id)));
    final failing = ActionQueueDrainer(
      store: store,
      intents: DotIntents(
        clock: h.clock,
        writes: h.writes,
        occurrences: occurrences,
        series: DriftSeriesRepository(h.db),
        profile: () async => profileFixture().copyWith(id: 'nobody'),
        snapshot: () => throw UnimplementedError(),
        untitled: (_) => 'Untitled',
      ),
      logger: h.logger,
    );
    expect(await failing.drain(), 0);
    expect(store.entries.map((e) => (e! as Map)['id']), [_a1, _a2]);
    expect(h.logs.records.map((r) => r.event), contains('intent.apply_failed'));
  });

  test('unreadable entries are removed; ones added meanwhile stay', () async {
    store
      ..append('garbage')
      ..append(entry(_a1, MarkDone(base.id)))
      ..onRead = () {
        store
          ..onRead = null
          ..append(entry(_late, StartFocus(base.id)));
      };
    await drainer.drain();
    expect(store.entries.map((e) => (e! as Map)['id']), [_late]);
    expect(
      h.logs.records.map((r) => r.event),
      contains('intent.queue_unreadable'),
    );
  });

  test(
    'a fresh Start focus opens Focus; a stale or missing one does not',
    () async {
      final asked = <String>[];
      final focusing = ActionQueueDrainer(
        store: store,
        intents: DotIntents(
          clock: h.clock,
          writes: h.writes,
          occurrences: occurrences,
          series: DriftSeriesRepository(h.db),
          profile: () async => profileFixture(),
          snapshot: () => throw UnimplementedError(),
          untitled: (_) => 'Untitled',
        ),
        logger: h.logger,
        now: h.clock.nowUtc,
        onFocus: asked.add,
      );
      Map<String, Object?> at(String id, DotAction a, Duration ago) =>
          encodeQueuedAction(
            QueuedAction(id: id, createdAtUtc: _now.subtract(ago), action: a),
          );
      store
        ..append(at(_a1, StartFocus(base.id), const Duration(seconds: 5)))
        ..append(at(_a2, StartFocus(base.id), const Duration(hours: 2)))
        ..append(
          at(
            _late,
            const StartFocus('01928c3e-0000-7000-8000-0000000000ff'),
            Duration.zero,
          ),
        );
      await focusing.drain();
      expect(asked, [base.id]);
      expect(
        (await occurrences.findById(userId, base.id))!.actualStartUtc,
        isNotNull,
      );
    },
  );
}
