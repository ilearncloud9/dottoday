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

const _actions = ThreadActions(
  onToggleDone: _noop,
  onOpen: _noop,
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

void main() {
  setUpAll(loadAppFonts);
  goldenMatrix(
    'thread_main',
    height: 1100,
    build: (_) => const _Card(mainThread),
  );
  goldenMatrix('thread_empty', height: 260, build: (_) => const _Card(_empty));
  goldenMatrix(
    'thread_one',
    height: 400,
    build: (_) => _Card([mainThread.first, mainThread[3], mainThread.last]),
  );
  goldenMatrix('thread_thirty', height: 2400, build: (_) => _Card(_thirty));
}
