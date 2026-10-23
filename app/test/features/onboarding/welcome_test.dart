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

  testWidgets('Get started, Back; Sign in goes to the account step', (
    tester,
  ) async {
    final c = await pumpOnboarding(tester);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(stepOf(c), OnboardingStep.dayShape);
    expect(find.bySemanticsLabel('Step 2 of 6'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(stepOf(c), OnboardingStep.welcome);
    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();
    expect(stepOf(c), OnboardingStep.account);
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
