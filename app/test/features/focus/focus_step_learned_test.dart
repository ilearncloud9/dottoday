import 'package:dottoday/domain/focus/focus_state.dart';
import 'package:dottoday/domain/scheduling/learning.dart';
import 'package:dottoday/features/focus/focus_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';
import '../../support/test_app.dart';

// Focus's step card on a learned length (docs/13 §5–§6): "usually 15 min",
// explained on tap, with the reset for this task.
void main() {
  testWidgets('the usual length explains itself and resets', (tester) async {
    var resets = 0;
    final step = subtaskFixture().copyWith(title: 'Dishes', durationMin: null);
    await tester.pumpWidget(
      testApp(
        Scaffold(
          body: FocusStepCard(
            state: FocusState(
              progress: 0.2,
              minutesLeft: 40,
              steps: [step],
              stepIndex: 0,
              stepLeft: const Duration(minutes: 15),
              stepProgress: 0,
              stepLearned: const Learned(samples: 3, usualMinutes: 15),
            ),
            taskTitle: 'Clean the kitchen',
            onResetLearning: () async {
              resets++;
              return () async {};
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('usually 15 min'));
    await tester.pumpAndSettle();
    expect(find.text('based on your last 3 times · median'), findsOneWidget);
    await tester.tap(find.text('Reset for this task on this device'));
    await tester.pumpAndSettle();
    expect(resets, 1);
    expect(
      find.text('Learning for Clean the kitchen reset on this device'),
      findsOneWidget,
    );
  });
}
