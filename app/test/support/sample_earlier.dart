import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread.dart';

/// The day of board E-Earlier at 10:42, unfolded: three done tasks, the
/// live one, a concurrent call, now, and the afternoon. Test-only sample
/// data, literals are fine here.
ThreadTask _t(
  String id,
  String title,
  TaskColor color,
  TaskIcon icon,
  DotState state,
  String range, {
  bool recurring = false,
}) => ThreadTask(
  id: id,
  title: title,
  color: color,
  icon: icon,
  state: state,
  timeRange: range,
  recurring: recurring,
);

final earlierDay =
    <ThreadEntry>[
      const ThreadCap.wake('7:00'),
      ThreadTaskEntry(
        _t(
          'run',
          'Morning run',
          TaskColor.coral,
          TaskIcon.run,
          DotState.done,
          '6:45 – 7:30',
        ),
      ),
      ThreadTaskEntry(
        _t(
          'coffee',
          'Coffee & plan the day',
          TaskColor.amber,
          TaskIcon.book,
          DotState.done,
          '7:30 – 7:45',
        ),
      ),
      ThreadTaskEntry(
        _t(
          'standup',
          'Team standup',
          TaskColor.sky,
          TaskIcon.call,
          DotState.done,
          '8:00 – 8:15',
          recurring: true,
        ),
      ),
      const ThreadGap(minutes: 45, startLabel: '8:15'),
      ThreadTaskEntry(
        _t(
          'deep',
          'Deep work: roadmap',
          TaskColor.indigo,
          TaskIcon.code,
          DotState.live,
          '9:00 – 11:00',
        ),
      ),
      const ThreadNow('10:42'),
      const ThreadGap(minutes: 90, startLabel: '11:00', addable: true),
      ThreadTaskEntry(
        _t(
          'lunch',
          'Lunch',
          TaskColor.rose,
          TaskIcon.meal,
          DotState.upcoming,
          '12:30 – 1:15',
        ),
      ),
      ThreadTaskEntry(
        _t(
          'gym',
          'Gym',
          TaskColor.violet,
          TaskIcon.run,
          DotState.upcoming,
          '6:00 – 7:00',
        ),
      ),
      const ThreadCap.bed('23:00'),
    ];
