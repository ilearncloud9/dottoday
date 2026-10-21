import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/test_app.dart';

Widget _dot({
  DotState state = DotState.upcoming,
  VoidCallback? onTap,
  double size = DotSize.rowDot,
  double progress = 0.4,
  ThemeMode mode = ThemeMode.light,
}) => testApp(
  Scaffold(
    body: Center(
      child: Builder(
        builder: (context) => TaskDot(
          color: TaskColor.indigo,
          icon: TaskIcon.code,
          state: state,
          progress: progress,
          size: size,
          label: taskDotLabel(
            context.l10n,
            title: 'Deep work',
            state: state,
            minutesLeft: state == DotState.live ? 38 : null,
          ),
          onTap: onTap,
          tapHint: context.l10n.dotMarkDoneHint,
        ),
      ),
    ),
  ),
  themeMode: mode,
);

void main() {
  const labels = {
    DotState.upcoming: 'Deep work, upcoming',
    DotState.live: 'Deep work, live, 38 minutes left',
    DotState.done: 'Deep work, done',
    DotState.skipped: 'Deep work, skipped',
    DotState.missed: 'Deep work, missed',
  };
  for (final MapEntry(key: state, value: label) in labels.entries) {
    testWidgets('${state.name}: label carries the state (§5.4)', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_dot(state: state, onTap: () {}));
      expect(
        tester.getSemantics(find.byType(TaskDot)),
        isSemantics(
          label: label,
          isButton: true,
          hasTapAction: true,
          hasCheckedState: true,
          isChecked: state == DotState.done,
          onTapHint: 'Mark done',
        ),
      );
      handle.dispose();
    });
  }

  testWidgets('one minute left is singular', (tester) async {
    await tester.pumpWidget(testApp(const SizedBox()));
    final l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)));
    expect(
      taskDotLabel(l10n, title: 'Run', state: DotState.live, minutesLeft: 1),
      'Run, live, 1 minute left',
    );
    expect(taskDotLabel(l10n, title: 'Run', state: DotState.live), 'Run, live');
  });

  testWidgets('a tap marks done, on a 48 dp target even for small dots', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(_dot(onTap: () => taps++, size: DotSize.pickerDot));
    expect(tester.getSize(find.byType(InkResponse)), const Size(48, 48));
    await tester.tap(find.byType(TaskDot));
    expect(taps, 1);
  });

  testWidgets('without onTap it is a plain labelled image, not a button', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_dot());
    final node = tester.getSemantics(find.byType(TaskDot));
    expect(node.label, 'Deep work, upcoming');
    expect(node.flagsCollection.isButton, isFalse);
    handle.dispose();
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('meets a11y guidelines (${mode.name})', (tester) async {
      await tester.pumpWidget(_dot(onTap: () {}, mode: mode));
      await expectA11yGuidelines(tester);
    });
  }

  testWidgets('live sweep animates, and jumps under reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(_dot(state: DotState.live));
    await tester.pumpWidget(_dot(state: DotState.live, progress: 0.8));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpAndSettle();

    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(_dot(state: DotState.live, progress: 0.9));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_dot(state: DotState.live, progress: 0.5));
    expect(tester.hasRunningAnimations, isFalse);
  });
}
