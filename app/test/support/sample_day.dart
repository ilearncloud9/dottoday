import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:dottoday/shared/dot/week_strip.dart';

/// The day of the `Main` reference render (docs/design-references), as
/// thread entries: test-only sample data, literals are fine here.
const mainThread = <ThreadEntry>[
  ThreadCap.wake('7:00'),
  ThreadTaskEntry(
    ThreadTask(
      id: 'run',
      title: 'Morning run',
      color: TaskColor.coral,
      icon: TaskIcon.run,
      state: DotState.done,
      timeRange: '7:30 – 8:00',
    ),
  ),
  ThreadGap(minutes: 60, startLabel: '8:00'),
  ThreadTaskEntry(
    ThreadTask(
      id: 'deep',
      title: 'Deep work: roadmap',
      color: TaskColor.indigo,
      icon: TaskIcon.code,
      state: DotState.live,
      timeRange: '9:00 – 11:00',
      duration: '2 h',
      progress: 0.4,
      minutesLeft: 38,
      subtasksDone: 1,
      subtasksTotal: 3,
      // Runs 15 min into the next task, so "Shift the rest" is on.
      overrunMinutes: 15,
    ),
  ),
  ThreadTaskEntry(
    ThreadTask(
      id: 'mail',
      title: 'Reply to email',
      color: TaskColor.slate,
      icon: TaskIcon.mail,
      state: DotState.upcoming,
      timeRange: '11:00 – 11:30',
    ),
  ),
  ThreadGap(minutes: 60, startLabel: '11:30', addable: true),
  ThreadTaskEntry(
    ThreadTask(
      id: 'lunch',
      title: 'Lunch with Sam',
      color: TaskColor.rose,
      icon: TaskIcon.meal,
      state: DotState.upcoming,
      timeRange: '12:30 – 1:15',
      pinned: true,
    ),
  ),
  ThreadTaskEntry(
    ThreadTask(
      id: 'spanish',
      title: 'Spanish lesson',
      color: TaskColor.teal,
      icon: TaskIcon.language,
      state: DotState.upcoming,
      timeRange: '2:00 – 3:00',
      recurring: true,
    ),
  ),
  ThreadTaskEntry(
    ThreadTask(
      id: 'dentist',
      title: 'Call the dentist',
      color: TaskColor.amber,
      icon: TaskIcon.call,
      state: DotState.missed,
      timeRange: '4:00 – 4:15',
    ),
  ),
  ThreadTaskEntry(
    ThreadTask(
      id: 'review',
      title: 'Spanish review',
      color: TaskColor.teal,
      icon: TaskIcon.book,
      state: DotState.skipped,
      timeRange: '7:30 – 8:00',
    ),
  ),
  ThreadCap.bed('22:00'),
];

/// The week strip of `Main`: Sun 18 – Sat 24, today Wednesday.
const mainWeek = <StripDay>[
  StripDay(
    weekday: 'Sun',
    weekdayNarrow: 'S',
    date: '18',
    label: 'Sunday 18',
    completion: Completion.of(1),
  ),
  StripDay(
    weekday: 'Mon',
    weekdayNarrow: 'M',
    date: '19',
    label: 'Monday 19',
    completion: Completion.of(0.75),
  ),
  StripDay(
    weekday: 'Tue',
    weekdayNarrow: 'T',
    date: '20',
    label: 'Tuesday 20',
    completion: Completion.of(1),
  ),
  StripDay(
    weekday: 'Wed',
    weekdayNarrow: 'W',
    date: '21',
    label: 'Wednesday 21, today',
    completion: Completion.of(0.3),
    isToday: true,
  ),
  StripDay(
    weekday: 'Thu',
    weekdayNarrow: 'T',
    date: '22',
    label: 'Thursday 22',
    completion: Completion.none(),
  ),
  StripDay(
    weekday: 'Fri',
    weekdayNarrow: 'F',
    date: '23',
    label: 'Friday 23',
    completion: Completion.none(),
  ),
  StripDay(
    weekday: 'Sat',
    weekdayNarrow: 'S',
    date: '24',
    label: 'Saturday 24',
    completion: Completion.none(),
  ),
];
