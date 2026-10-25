import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/learning.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

// Learning (docs/09 M11.3, 11 C3): per task, the median actual length and
// start offset over its last ten runs, from actual timestamps only.

var _n = 0;

/// A run of [title] on day [d] (Oct 2026), planned 9:00, really starting
/// [late] min after and taking [took] min.
Occurrence _run(
  String title,
  int d, {
  int took = 60,
  int late = 0,
  String? series,
  bool deleted = false,
}) {
  final plan = DateTime.utc(2026, 10, d, 9);
  final start = plan.add(Duration(minutes: late));
  return occurrenceFixture().copyWith(
    id: 'run-${++_n}',
    title: title,
    seriesId: series,
    startUtc: plan,
    durationMin: 60,
    actualStartUtc: start,
    actualEndUtc: start.add(Duration(minutes: took)),
    deletedAt: deleted ? plan : null,
  );
}

void main() {
  test('median length and start offset of the runs', () {
    final index = LearningIndex.from([
      _run('Deep work', 1, took: 130, late: 10),
      _run('Deep work', 2, took: 140, late: 15),
      _run('deep  WORK ', 3, took: 145, late: 20),
    ]);
    final l = index.forTask(title: 'Deep work');
    expect(l.samples, 3);
    expect(l.usualMinutes, 140);
    expect(l.startOffsetMinutes, 15);
  });

  test('fewer than three runs say nothing', () {
    final index = LearningIndex.from([
      _run('Gym', 1),
      _run('Gym', 2),
      // Planned only, no actuals: never counted.
      occurrenceFixture().copyWith(id: 'plan', title: 'Gym'),
    ]);
    final l = index.forTask(title: 'Gym');
    expect(l.samples, 2);
    expect(l.usualMinutes, isNull);
    expect(l.startOffsetMinutes, isNull);
    expect(LearningIndex.empty.forTask(title: 'Gym').samples, 0);
  });

  test('an outlier does not move the median', () {
    final index = LearningIndex.from([
      for (var d = 1; d <= 9; d++) _run('Read', d, took: 30),
      _run('Read', 10, took: 600, late: 300),
    ]);
    final l = index.forTask(title: 'Read');
    expect(l.usualMinutes, 30);
    expect(l.startOffsetMinutes, 0);
  });

  test('only the last ten runs count', () {
    final index = LearningIndex.from([
      for (var d = 1; d <= 10; d++) _run('Write', d, took: 90),
      for (var d = 11; d <= 20; d++) _run('Write', d, took: 30),
    ]);
    expect(index.forTask(title: 'Write').usualMinutes, 30);
    expect(index.forTask(title: 'Write').samples, 10);
  });

  test('renamed: a repeat keeps its history under the new title', () {
    final index = LearningIndex.from([
      _run('Standup', 1, took: 20, series: 's1'),
      _run('Standup', 2, took: 20, series: 's1'),
      _run('Daily sync', 3, took: 25, series: 's1'),
    ]);
    expect(index.forTask(title: 'Daily sync', seriesId: 's1').samples, 3);
    expect(index.forTask(title: 'Daily sync', seriesId: 's1').usualMinutes, 20);
    // A one-off renamed is a new task: its old title no longer counts.
    expect(index.forTask(title: 'Daily sync').samples, 1);
  });

  test('deleted runs and broken spans are skipped', () {
    final broken = _run('Gym', 4).copyWith(actualEndUtc: null);
    final backwards = _run(
      'Gym',
      5,
    ).copyWith(actualEndUtc: DateTime.utc(2026, 10, 5, 8));
    final index = LearningIndex.from([
      _run('Gym', 1),
      _run('Gym', 2),
      _run('Gym', 3, deleted: true),
      broken,
      backwards,
    ]);
    expect(index.forTask(title: 'Gym').samples, 2);
  });

  test('starting before the plan is a negative offset', () {
    final index = LearningIndex.from([
      for (var d = 1; d <= 3; d++) _run('Run', d, late: -10),
    ]);
    expect(index.forTask(title: 'Run').startOffsetMinutes, -10);
  });

  test('Running late amount: the smallest choice covering the usual extra', () {
    const usually75 = Learned(samples: 3, usualMinutes: 75);
    expect(lateAmountFor(60, usually75, const [5, 15, 30]), 15);
    const usually2h = Learned(samples: 3, usualMinutes: 120);
    expect(lateAmountFor(60, usually2h, const [5, 15, 30]), 30);
    const usually50 = Learned(samples: 3, usualMinutes: 50);
    expect(lateAmountFor(60, usually50, const [5, 15, 30]), isNull);
    expect(lateAmountFor(60, Learned.none, const [5, 15, 30]), isNull);
  });
}
