import 'dart:async';

import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/snapshot/bedtime_snapshot.dart';
import 'package:dottoday/data/snapshot/day_snapshot_writer.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';
import '../writes/write_harness.dart';

final class _FakeTimer implements Timer {
  _FakeTimer(this.wait, this.fire);

  final Duration wait;
  final void Function() fire;
  var cancelled = false;

  @override
  void cancel() => cancelled = true;

  @override
  bool get isActive => !cancelled;

  @override
  int get tick => 0;
}

void main() {
  // 06:00Z = 02:00 in New York (the fixture profile); Bedtime 22:00 EDT is
  // 02:00Z the next day.
  final now = DateTime.utc(2026, 10, 21, 6);
  late WriteHarness h;
  late BedtimeSnapshot bedtime;
  late List<_FakeTimer> timers;

  setUp(() async {
    h = WriteHarness(now);
    await h.writes.apply(WriteBatch(userId: userId, profile: profileFixture()));
    await h.effects.idle;
    timers = [];
    bedtime = BedtimeSnapshot(
      clock: h.clock,
      writer: DaySnapshotWriter(
        clock: h.clock,
        occurrences: DriftOccurrenceRepository(h.db),
        profile: () async => profileFixture(),
        sink: h.sink,
      ),
      logger: h.logger,
      timer: (wait, fire) {
        final timer = _FakeTimer(wait, fire);
        timers.add(timer);
        return timer;
      },
    );
  });
  tearDown(() => h.dispose());

  test('arms one write at Bedtime and writes the snapshot then', () async {
    await bedtime.arm(userId);
    expect(timers.single.wait, const Duration(hours: 20));
    final before = h.sink.written.length;
    h.clock.advance(const Duration(hours: 20));
    timers.single.fire();
    await pumpEventQueue();
    expect(h.sink.written.length, before + 1);
    expect(h.sink.written.last.dayProgress, 1);
  });

  test('re-arming replaces the armed write', () async {
    await bedtime.arm(userId);
    await bedtime.arm(userId);
    expect(timers.first.cancelled, isTrue);
    expect(timers.last.cancelled, isFalse);
  });

  test('after Bedtime nothing is armed', () async {
    h.clock.now = DateTime.utc(2026, 10, 22, 3);
    await bedtime.arm(userId);
    expect(timers, isEmpty);
  });
}
