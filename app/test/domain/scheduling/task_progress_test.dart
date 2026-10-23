import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/scheduling/task_progress.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

// Actual timestamps follow explicit actions only (docs/09 M6.5.2, 11 B1).
void main() {
  final start = DateTime.utc(2026, 10, 21, 9, 10);
  final end = DateTime.utc(2026, 10, 21, 10, 40);
  final task = occurrenceFixture();

  test('Done records completion and the actual end, not a start', () {
    final done = markDone(task, end);
    expect(done.status, OccurrenceStatus.done);
    expect(done.completedAtUtc, end);
    expect(done.actualEndUtc, end);
    expect(done.actualStartUtc, isNull, reason: 'never inferred');
  });

  test('the first start counts; later starts and done tasks keep it', () {
    final started = markStarted(task, start);
    expect(started.actualStartUtc, start);
    expect(markStarted(started, end).actualStartUtc, start);
    expect(markStarted(markDone(task, end), start).actualStartUtc, isNull);
    final skipped = task.copyWith(status: OccurrenceStatus.skipped);
    expect(markStarted(skipped, start).actualStartUtc, isNull);
  });

  test('un-ticking drops the end and keeps the real start', () {
    final undone = toggleDone(toggleDone(markStarted(task, start), end), end);
    expect(undone.status, OccurrenceStatus.planned);
    expect(undone.completedAtUtc, isNull);
    expect(undone.actualEndUtc, isNull);
    expect(undone.actualStartUtc, start);
  });

  test('a copy starts with no progress', () {
    final copy = withoutProgress(markDone(markStarted(task, start), end));
    expect(copy.status, OccurrenceStatus.planned);
    expect([
      copy.completedAtUtc,
      copy.actualStartUtc,
      copy.actualEndUtc,
    ], everyElement(isNull));
  });
}
