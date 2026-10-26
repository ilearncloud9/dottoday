import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/scheduling/learning.dart';
import 'package:dottoday/domain/scheduling/learning_thresholds.dart';
import 'package:dottoday/domain/scheduling/step_runs.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

// Learned step lengths (docs/13 §5, ADR-0012): from real ticks only.
var _n = 0;

/// "Clean" really started on Oct [d] at 9:00, with its steps ticked
/// [ticks] minutes after the start (null: not ticked).
({Occurrence task, List<Subtask> steps}) _clean(
  int d,
  List<int?> ticks, {
  String title = 'Clean',
  bool started = true,
}) {
  final start = DateTime.utc(2026, 10, d, 9);
  final task = occurrenceFixture().copyWith(
    id: 'task-${++_n}',
    title: title,
    startUtc: start,
    actualStartUtc: started ? start : null,
  );
  const names = ['Dishes', 'Floor', 'Bins'];
  return (
    task: task,
    steps: [
      for (final (i, m) in ticks.indexed)
        subtaskFixture().copyWith(
          id: 'step-${++_n}',
          occurrenceId: task.id,
          title: names[i],
          sortOrder: i.toDouble(),
          done: m != null,
          doneAt: m == null ? null : start.add(Duration(minutes: m)),
        ),
    ],
  );
}

LearningIndex _index(List<({Occurrence task, List<Subtask> steps})> runs) =>
    LearningIndex.from(
      [for (final r in runs) r.task],
      steps: [for (final r in runs) ...r.steps],
    );

void main() {
  test('each step from the tick before it, the first from the start', () {
    final r = _clean(1, [10, 25, 30]);
    final runs = stepRunsByKey([r.task], r.steps);
    expect(runs[stepKey('Clean', 'Dishes')]!.single.minutes, 10);
    expect(runs[stepKey('clean ', 'FLOOR')]!.single.minutes, 15);
    expect(runs[stepKey('Clean', 'Bins')]!.single.minutes, 5);
  });

  test('a skipped tick: the next step runs from the last real tick', () {
    final r = _clean(1, [10, null, 40]);
    final runs = stepRunsByKey([r.task], r.steps);
    expect(runs[stepKey('Clean', 'Floor')], isNull);
    expect(runs[stepKey('Clean', 'Bins')]!.single.minutes, 30);
  });

  test('no real start, no tick time, an untick or a stray time: nothing', () {
    final notStarted = _clean(1, [10], started: false);
    final legacy = _clean(2, [10]);
    final legacyStep = legacy.steps.single.copyWith(doneAt: null);
    final unticked = _clean(3, [10]);
    final untickedStep = unticked.steps.single.copyWith(done: false);
    final runs = stepRunsByKey(
      [notStarted.task, legacy.task, unticked.task],
      [...notStarted.steps, legacyStep, untickedStep],
    );
    expect(runs, isEmpty);
  });

  test('spans outside 1–1440 min are dropped', () {
    final r = _clean(1, [0, 1441 + 0]);
    expect(stepRunsByKey([r.task], r.steps), isEmpty);
  });

  test('stepMinSamples: silent at n − 1, the median at n', () {
    final min = LearningThresholds.standard.stepMinSamples;
    final runs = [
      for (var d = 1; d <= min; d++) _clean(d, [10 + d]),
    ];
    final under = _index(runs.skip(1).toList());
    final at = _index(runs);
    expect(
      under.forStep(taskTitle: 'Clean', stepTitle: 'Dishes').usualMinutes,
      isNull,
    );
    final l = at.forStep(taskTitle: 'Clean', stepTitle: 'Dishes');
    expect((l.samples, l.usualMinutes, l.startOffsetMinutes), (min, 10, null));
  });

  test('the same step name in another task learns apart', () {
    final index = _index([
      for (var d = 1; d <= 3; d++) _clean(d, [10]),
      for (var d = 4; d <= 6; d++) _clean(d, [40], title: 'Party'),
    ]);
    expect(
      index.forStep(taskTitle: 'Clean', stepTitle: 'Dishes').usualMinutes,
      10,
    );
    expect(
      index.forStep(taskTitle: 'Party', stepTitle: 'Dishes').usualMinutes,
      40,
    );
  });
}
