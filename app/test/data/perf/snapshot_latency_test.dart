@Tags(['perf'])
library;

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';
import '../writes/write_harness.dart';

// docs/09 M9.1: every surface shows the same dot within 1 s of a change, so
// the day snapshot must be written ≤ 1 s after a write commits (including
// the notification re-plan queued before it), on a busy day.

const _busy = 200;
const _runs = 20;
final _now = DateTime.utc(2026, 10, 21, 8);

void main() {
  test('the snapshot follows a write within 1 s (p95, busy day)', () async {
    final h = WriteHarness(_now);
    addTearDown(h.dispose);
    final base = occurrenceFixture();
    final rows = [
      for (var i = 0; i < _busy; i++)
        base.copyWith(
          id: '01928c3e-0000-7000-8000-${i.toString().padLeft(12, '0')}',
          startUtc: _now.add(Duration(minutes: 5 * i)),
          durationMin: 5,
        ),
    ];
    final seeded = await h.writes.apply(
      WriteBatch(userId: userId, profile: profileFixture(), occurrences: rows),
    );
    expect(seeded, isA<Ok<void, AppFailure>>());
    await h.effects.idle;

    final times = <int>[];
    for (var run = 0; run < _runs; run++) {
      final edited = rows[run].copyWith(title: 'Edited $run');
      final before = h.sink.written.length;
      final watch = Stopwatch()..start();
      await h.writes.apply(
        WriteBatch(userId: userId, occurrences: <Occurrence>[edited]),
      );
      await h.effects.idle;
      times.add(watch.elapsedMilliseconds);
      expect(h.sink.written.length, before + 1, reason: '${h.logs.records}');
      expect(
        h.sink.written.last.dots.where((d) => d.id == edited.id).single.title,
        'Edited $run',
      );
    }
    times.sort();
    final p95 = times[(times.length * 0.95).ceil() - 1];
    expect(p95, lessThanOrEqualTo(1000), reason: 'p95 ${p95}ms');
  });
}
