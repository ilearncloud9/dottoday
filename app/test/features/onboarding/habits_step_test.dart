import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/onboarding_harness.dart';
import '../../support/timeline_fakes.dart';

// O3 Habits (docs/09 M4.3): picks land on tomorrow, not today.

const _step = OnboardingProgress(step: OnboardingStep.habits);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('three picked land on tomorrow, not today', (tester) async {
    final repo = FakeOccurrenceRepository();
    final c = await pumpOnboarding(tester, progress: _step, repo: repo);
    for (final title in ['Morning run', 'Lunch', 'Read']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    await tester.ensureVisible(find.text('Add 3 to tomorrow'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add 3 to tomorrow'));
    await tester.pumpAndSettle();
    expect(stepOf(c), OnboardingStep.reminders);
    expect(repo.rows, hasLength(3));
    // Wed 21 Oct in Berlin (the harness's clock) → Thu 22.
    for (final o in repo.rows) {
      final local = o.startUtc!.add(const Duration(hours: 2));
      expect(local.day, 22, reason: o.title);
    }
  });

  testWidgets('five is the most; nothing picked just continues', (
    tester,
  ) async {
    final repo = FakeOccurrenceRepository();
    final c = await pumpOnboarding(tester, progress: _step, repo: repo);
    for (final title in ['Morning run', 'Deep work', 'Lunch', 'Walk', 'Gym']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(find.text('Five is plenty to start with.'), findsOneWidget);
    final read = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'Read'),
    );
    expect(read.onChanged, isNull);
    for (final title in ['Morning run', 'Deep work', 'Lunch', 'Walk', 'Gym']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Continue'));
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();
    expect(stepOf(c), OnboardingStep.reminders);
    expect(repo.rows, isEmpty);
  });

  testWidgets('meets a11y guidelines (R-12)', (tester) async {
    await pumpOnboarding(tester, progress: _step);
    await expectA11yGuidelines(tester);
  });
}
