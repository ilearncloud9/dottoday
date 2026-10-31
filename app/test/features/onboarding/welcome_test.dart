import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:dottoday/shared/dot/day_dot.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/onboarding_harness.dart';

// O1 Welcome and the onboarding frame (docs/09 M4.1).

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('first run: the welcome, not the app', (tester) async {
    await pumpOnboarding(tester);
    expect(find.text('Your day, as a thread.'), findsOneWidget);
    // The age gate is copy on the welcome (docs/06 §6, M8.6).
    expect(
      find.text('Dottoday is for people aged 13 and over.'),
      findsOneWidget,
    );
    expect(find.byType(DayDot), findsOneWidget);
    expect(find.text('the app'), findsNothing);
    // Still mounted, hidden: its router takes links that arrive during
    // onboarding, such as the sign-in link from the mail (M6.1).
    expect(find.text('the app', skipOffstage: false), findsOneWidget);
  });

  testWidgets('finished: the app', (tester) async {
    await pumpOnboarding(
      tester,
      progress: const OnboardingProgress(
        step: OnboardingStep.done,
        finished: true,
      ),
    );
    expect(find.text('the app'), findsOneWidget);
  });

  testWidgets('Get started, step 0, Back; Sign in goes to the account step', (
    tester,
  ) async {
    final c = await pumpOnboarding(tester);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    // Step 0 (docs/14 §4, the owner's render): minimal preselected, no top
    // bar, its own dots under Continue — the first of minimal's four.
    expect(stepOf(c), OnboardingStep.layout);
    expect(find.bySemanticsLabel('Step 1 of 4'), findsOneWidget);
    expect(find.byTooltip('Back'), findsNothing);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(stepOf(c), OnboardingStep.dayShape);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(stepOf(c), OnboardingStep.layout);

    final again = await pumpOnboarding(tester);
    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();
    expect(stepOf(again), OnboardingStep.account);
  });

  testWidgets('a killed flow resumes where it was', (tester) async {
    final c = await pumpOnboarding(
      tester,
      progress: const OnboardingProgress(step: OnboardingStep.reminders),
    );
    expect(stepOf(c), OnboardingStep.reminders);
    expect(find.text('Your day, as a thread.'), findsNothing);
  });

  testWidgets('welcome meets a11y guidelines (R-12)', (tester) async {
    await pumpOnboarding(tester);
    await expectA11yGuidelines(tester);
  });
}
