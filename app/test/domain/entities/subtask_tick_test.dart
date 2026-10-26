import 'package:dottoday/domain/entities/subtask.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

// ADR-0012: no CHECK ties done_at to done (field-level sync), so the code
// keeps the pair: written through tick(), read through tickedAt().
void main() {
  final t0 = DateTime.utc(2026, 10, 26, 9);

  test('tick and untick keep done_at non-null iff done', () {
    var step = subtaskFixture();
    for (var i = 0; i < 20; i++) {
      final done = i.isEven || i % 3 == 0;
      step = tick(
        step,
        done: done,
        nowUtc: t0.add(Duration(minutes: i)),
      );
      expect(step.doneAt != null, step.done, reason: 'write $i');
      if (done) expect(step.doneAt, t0.add(Duration(minutes: i)));
    }
  });

  test('tolerant read: done wins over a stray or missing time', () {
    final at = t0.add(const Duration(minutes: 5));
    // An older client unticked with `done` only: not done, time ignored.
    final strayTime = subtaskFixture().copyWith(done: false, doneAt: at);
    expect(tickedAt(strayTime), isNull);
    // Ticked before 0008: done, with no time.
    final legacy = subtaskFixture().copyWith(done: true);
    expect((legacy.done, tickedAt(legacy)), (true, null));
    final ticked = tick(subtaskFixture(), done: true, nowUtc: at);
    expect(tickedAt(ticked), at);
  });
}
