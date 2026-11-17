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
import '../../support/sample_earlier.dart';

/// The thread on the page ground, as on E-Earlier's phone sheet, capped at
/// a phone's width.
class _Page extends StatelessWidget {
  const _Page(this.entries);

  final List<ThreadEntry> entries;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: DotTheme.of(context).colors.ground,
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: Padding(
          padding: const EdgeInsets.all(DotSpace.page),
          child: Thread(entries: entries),
        ),
      ),
    ),
  );
}

ThreadTask _night(String id, String title, TaskColor color) => ThreadTask(
  id: id,
  title: title,
  color: color,
  icon: TaskIcon.travel,
  state: DotState.upcoming,
  timeRange: '23:30 – 0:45',
);

/// E-R2-39 Minimal: "Before Wake Up" folded, "After Wind Down" shown.
final _plain = <ThreadEntry>[
  ThreadOutside(
    tasks: [_night('flight', 'Early run', TaskColor.violet)],
    windDown: false,
    counted: false,
  ),
  const ThreadCap.wake('7:00'),
  const ThreadGap(minutes: 900, startLabel: '7:00', addable: true),
  const ThreadCap.bed('22:00'),
  ThreadOutside(
    tasks: [_night('bag', 'Pack the bag', TaskColor.amber)],
    windDown: true,
    counted: false,
    open: true,
  ),
];

void main() {
  setUpAll(loadAppFonts);
  goldenMatrix(
    'thread_earlier',
    height: 620,
    build: (_) => _Page(foldEarlier(earlierDay, open: false)),
  );
  goldenMatrix(
    'thread_earlier_open',
    height: 760,
    build: (_) => _Page(foldEarlier(earlierDay, open: true)),
  );
  goldenMatrix(
    'thread_outside_plain',
    height: 460,
    build: (_) => _Page(_plain),
  );
}
