// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/domain/focus/focus_state.dart';
import 'package:dottoday/domain/scheduling/learning.dart';
import 'package:dottoday/features/focus/focus_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../domain/fixtures.dart';
import '../../support/dot_golden.dart';

// Focus's step card on a learned length, its explanation open (docs/13
// §5–§6, §11). Light/dark, compact/expanded, 1×/2×, largest text, RTL.
void main() {
  setUpAll(loadAppFonts);

  goldenMatrix(
    'focus_step_learned_explained',
    height: 560,
    widths: const {'compact', 'expanded'},
    a11yVariants: true,
    act: (t) => t.tap(find.text('usually 15 min')),
    build: (_) => Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.topCenter,
          child: FocusStepCard(
            state: FocusState(
              progress: 0.2,
              minutesLeft: 40,
              steps: [subtaskFixture().copyWith(title: 'Dishes')],
              stepIndex: 0,
              stepLeft: const Duration(minutes: 9, seconds: 30),
              stepProgress: 0.37,
              stepLearned: const Learned(samples: 3, usualMinutes: 15),
            ),
            taskTitle: 'Clean the kitchen',
            onResetLearning: () async => () async {},
          ),
        ),
      ),
    ),
  );
}
