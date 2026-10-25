// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';
import '../../support/sample_day.dart';

/// The `Main` card's thread on a raised card, capped at the card width the
/// phone renders use so wide cells don't stretch the rows.
class _Card extends StatelessWidget {
  const _Card(this.entries);

  final List<ThreadEntry> entries;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          margin: const EdgeInsets.all(DotSpace.page),
          padding: const EdgeInsets.all(DotSpace.s),
          decoration: BoxDecoration(
            color: c.raised,
            borderRadius: BorderRadius.circular(DotRadii.cardLarge),
            border: Border.all(color: c.outline),
          ),
          child: Thread(entries: entries, actions: _actions),
        ),
      ),
    );
  }
}

void _noop(Object? _) {}

void _noAnswer(String _, String _) {}

const _actions = ThreadActions(
  onToggleDone: _noop,
  onOpen: _noop,
  onFocus: _noop,
  onUnstick: _noAnswer,
  onExtend: _noop,
  onShiftRest: _noop,
  onAddHere: _noop,
);

const _empty = <ThreadEntry>[
  ThreadCap.wake('7:00'),
  ThreadGap(minutes: 900, startLabel: '7:00', addable: true),
  ThreadCap.bed('22:00'),
];

final _thirty = <ThreadEntry>[
  for (var i = 0; i < 30; i++)
    ThreadTaskEntry(
      ThreadTask(
        id: '$i',
        title: 'Task $i',
        color: TaskColor.values[i % TaskColor.values.length],
        icon: TaskIcon.picker[i % TaskIcon.picker.length],
        state: i < 10 ? DotState.done : DotState.upcoming,
        timeRange: '${7 + i ~/ 2}:${i.isEven ? '00' : '30'}',
      ),
    ),
];

/// A row with travel time before it (derived, docs/09 M7.5, R-17).
const _travel = <ThreadEntry>[
  ThreadCap.wake('7:00'),
  ThreadGap(minutes: 300, startLabel: '7:00', addable: true),
  ThreadTaskEntry(
    ThreadTask(
      id: 'dentist',
      title: 'Dentist',
      color: TaskColor.teal,
      icon: TaskIcon.meds,
      state: DotState.upcoming,
      timeRange: '12:30 – 13:15',
      travel: '30 min',
    ),
  ),
  ThreadCap.bed('22:00'),
];

/// Smallest step (docs/09 M10.6, derived from 11 §B2): the live dot,
/// unstarted 10 min in, asks for its first step only.
const _smallest = <ThreadEntry>[
  ThreadCap.wake('7:00'),
  ThreadTaskEntry(
    ThreadTask(
      id: 'taxes',
      title: 'Do taxes',
      color: TaskColor.amber,
      icon: TaskIcon.list,
      state: DotState.live,
      timeRange: '16:00 – 17:40',
      duration: '1 h 40',
      progress: 0.12,
      minutesLeft: 88,
      subtasksTotal: 5,
      smallestStep: 'Just Gather documents · 10 min?',
    ),
  ),
  ThreadCap.bed('22:00'),
];

/// Unstick (docs/09 M10.7, derived from 11 §B3): a task moved three times
/// with no steps asks, quietly, for its very first one.
const _unstick = <ThreadEntry>[
  ThreadCap.wake('7:00'),
  ThreadTaskEntry(
    ThreadTask(
      id: 'taxes',
      title: 'Do taxes',
      color: TaskColor.amber,
      icon: TaskIcon.list,
      state: DotState.upcoming,
      timeRange: '16:00 – 17:30',
      unstick: true,
    ),
  ),
  ThreadCap.bed('22:00'),
];

ThreadTask _night(String id, String title, String range) => ThreadTask(
  id: id,
  title: title,
  color: TaskColor.indigo,
  icon: TaskIcon.travel,
  state: DotState.upcoming,
  timeRange: range,
);

/// Outside hours (derived, docs/02 F1.15): a folded zone above the sun
/// cap, an unfolded one below the moon cap.
final _outside = <ThreadEntry>[
  ThreadOutside(
    tasks: [_night('flight', 'Early flight', '5:00 – 6:30')],
    bedtime: false,
  ),
  const ThreadCap.wake('7:00'),
  const ThreadGap(minutes: 900, startLabel: '7:00', addable: true),
  const ThreadCap.bed('22:00'),
  ThreadOutside(
    tasks: [_night('train', 'Night train', '23:30 – 0:45')],
    bedtime: true,
    open: true,
  ),
];

void main() {
  setUpAll(loadAppFonts);
  goldenMatrix(
    'thread_travel',
    height: 420,
    build: (_) => const _Card(_travel),
  );
  goldenMatrix(
    'thread_main',
    height: 1100,
    build: (_) => const _Card(mainThread),
  );
  goldenMatrix('thread_empty', height: 260, build: (_) => const _Card(_empty));
  goldenMatrix(
    'thread_unstick',
    height: 420,
    build: (_) => const _Card(_unstick),
  );
  goldenMatrix(
    'thread_smallest_step',
    height: 420,
    build: (_) => const _Card(_smallest),
  );
  goldenMatrix(
    'thread_one',
    height: 400,
    build: (_) => _Card([mainThread.first, mainThread[3], mainThread.last]),
  );
  goldenMatrix('thread_outside', height: 420, build: (_) => _Card(_outside));
  goldenMatrix('thread_thirty', height: 2400, build: (_) => _Card(_thirty));
}
