// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';

/// Every variant at every size; colours and icons from `Main` / `A-ios-inbox`.
class _Specimen extends StatelessWidget {
  const _Specimen();

  static const _dots = [
    (TaskColor.coral, TaskIcon.run, DotState.done, 0.0),
    (TaskColor.indigo, TaskIcon.code, DotState.live, 0.4),
    (TaskColor.slate, TaskIcon.mail, DotState.upcoming, 0.0),
    (TaskColor.rose, TaskIcon.meal, DotState.upcoming, 0.0),
    (TaskColor.teal, TaskIcon.language, DotState.skipped, 0.0),
    (TaskColor.amber, TaskIcon.list, DotState.missed, 0.0),
    (TaskColor.mint, TaskIcon.circle, DotState.upcoming, 0.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DotSpace.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DotSpace.m,
        children: [
          for (final size in [
            DotSize.liveDot,
            DotSize.rowDot,
            DotSize.macRowDot,
            DotSize.pickerDot,
          ])
            Wrap(
              spacing: DotSpace.m,
              children: [
                for (final (color, icon, state, progress) in _dots)
                  TaskDot(
                    color: color,
                    icon: icon,
                    state: state,
                    progress: progress,
                    size: size,
                    label: state.name,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

void main() {
  setUpAll(loadAppFonts);
  goldenMatrix('task_dot', height: 300, build: (_) => const _Specimen());
}
