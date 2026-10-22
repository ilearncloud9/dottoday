import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/first_thread_rows.dart';
import '../../support/onboarding_harness.dart';
import '../../support/timeline_fakes.dart';

// O6 Done (docs/09 M4.6): the first thread, then Open today.

const _step = OnboardingProgress(step: OnboardingStep.done);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('tomorrow with the habits; Open today ends onboarding', (
    tester,
  ) async {
    await pumpOnboarding(
      tester,
      progress: _step,
      repo: FakeOccurrenceRepository(firstThreadRows()),
    );
    expect(find.text('Your first thread'), findsOneWidget);
    // The card builds the rows in view; Read is further down.
    for (final title in ['Morning run', 'Lunch']) {
      expect(find.text(title), findsOneWidget);
    }
    expect(find.textContaining('0 of 3'), findsOneWidget);
    await tester.ensureVisible(find.text('Open today'));
    await tester.tap(find.text('Open today'));
    await tester.pumpAndSettle();
    expect(find.text('the app'), findsOneWidget);
  });

  testWidgets('no habits: says the day is theirs', (tester) async {
    await pumpOnboarding(tester, progress: _step);
    expect(find.textContaining('is all yours'), findsOneWidget);
  });

  testWidgets('meets a11y guidelines (R-12)', (tester) async {
    await pumpOnboarding(
      tester,
      progress: _step,
      repo: FakeOccurrenceRepository(firstThreadRows()),
    );
    await expectA11yGuidelines(tester);
  });
}
