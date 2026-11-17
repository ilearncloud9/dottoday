import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/sample_earlier.dart';

String _name(ThreadEntry e) => switch (e) {
  ThreadCap(:final windDown) => windDown ? 'bed' : 'wake',
  ThreadTaskEntry(:final task) => task.id,
  ThreadGap(:final addable) => addable ? 'free' : 'past',
  ThreadNow() => 'now',
  ThreadOverlap() => 'knot',
  ThreadOutside() => 'outside',
  ThreadEarlier(:final open) => open ? 'earlier+' : 'earlier',
};

ThreadTaskEntry _task(String id, DotState state) => ThreadTaskEntry(
  ThreadTask(
    id: id,
    title: id,
    color: TaskColor.mint,
    icon: TaskIcon.run,
    state: state,
    timeRange: '',
  ),
);

void main() {
  group('foldEarlier (ED-164)', () {
    test('folds done tasks behind now into one row, without the Wake Up cap '
        'or past free time', () {
      final out = foldEarlier(earlierDay, open: false);
      expect(out.map(_name), [
        'earlier',
        'deep',
        'now',
        'free',
        'lunch',
        'gym',
        'bed',
      ]);
      final row = out.first as ThreadEarlier;
      expect(row.dots, [TaskColor.coral, TaskColor.amber, TaskColor.sky]);
      expect(row.last, TaskColor.sky);
    });

    test('open keeps the done tasks in their rows under it', () {
      final out = foldEarlier(earlierDay, open: true);
      expect(out.map(_name).take(5), [
        'earlier+',
        'run',
        'coffee',
        'standup',
        'deep',
      ]);
    });

    test('a reopened task keeps its time; only done tasks fold', () {
      final day = [
        const ThreadCap.wake('7:00'),
        _task('a', DotState.done),
        _task('b', DotState.missed),
        _task('c', DotState.done),
        const ThreadNow('10:42'),
        _task('d', DotState.upcoming),
        const ThreadCap.bed('23:00'),
      ];
      expect(foldEarlier(day, open: false).map(_name), [
        'earlier',
        'b',
        'now',
        'd',
        'bed',
      ]);
    });

    test('a task done early, ahead of now, does not fold', () {
      final day = [
        const ThreadCap.wake('7:00'),
        const ThreadNow('7:10'),
        _task('a', DotState.done),
        const ThreadCap.bed('23:00'),
      ];
      expect(foldEarlier(day, open: false).map(_name), ['now', 'a', 'bed']);
    });

    test('nothing done yet: no row, and the view still starts without the '
        'Wake Up cap', () {
      final day = [
        const ThreadCap.wake('7:00'),
        _task('a', DotState.live),
        const ThreadNow('7:10'),
        const ThreadCap.bed('23:00'),
      ];
      expect(foldEarlier(day, open: false).map(_name), ['a', 'now', 'bed']);
    });

    test('folded, a knot between two done tasks goes with them', () {
      final day = [
        const ThreadCap.wake('7:00'),
        _task('a', DotState.done),
        const ThreadOverlap(
          above: TaskColor.mint,
          below: TaskColor.mint,
          aboveTitle: 'a',
          belowTitle: 'b',
          minutes: 15,
          range: '',
        ),
        _task('b', DotState.done),
        const ThreadNow('10:42'),
        const ThreadCap.bed('23:00'),
      ];
      expect(foldEarlier(day, open: false).map(_name), [
        'earlier',
        'now',
        'bed',
      ]);
      expect(foldEarlier(day, open: true).map(_name), [
        'earlier+',
        'a',
        'knot',
        'b',
        'now',
        'bed',
      ]);
    });

    test('the thread leaves the folded row in the last done colour', () {
      final out = foldEarlier(earlierDay, open: false);
      final solid = threadSolid(out);
      expect(solid[0], TaskColor.sky);
      expect(solid[1], TaskColor.sky);
    });
  });
}
