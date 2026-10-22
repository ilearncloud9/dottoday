import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/shared/dot/day_shape_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/onboarding_harness.dart';

// O2 Day shape (docs/09 M4.2): the slider writes the profile at once.

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('moving Wake Up saves it; Continue moves on', (tester) async {
    final c = await pumpOnboarding(
      tester,
      progress: const OnboardingProgress(step: OnboardingStep.dayShape),
    );
    expect(find.text('When does your day start and end?'), findsOneWidget);
    final slider = tester.widget<DayShapeSlider>(find.byType(DayShapeSlider));
    slider.onChanged(6 * 60 + 30, slider.bedMinute);
    await tester.pumpAndSettle();
    final stored = await c.read(settingsRepositoryProvider).findLocalProfile();
    final mon = stored!.settings.boundaryFor(Weekday.mon);
    expect(windowMinutes(mon.start), 6 * 60 + 30);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();
    expect(stepOf(c), OnboardingStep.habits);
  });

  testWidgets('Skip keeps the defaults and moves on', (tester) async {
    final c = await pumpOnboarding(
      tester,
      progress: const OnboardingProgress(step: OnboardingStep.dayShape),
    );
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(stepOf(c), OnboardingStep.habits);
  });

  testWidgets('meets a11y guidelines (R-12)', (tester) async {
    await pumpOnboarding(
      tester,
      progress: const OnboardingProgress(step: OnboardingStep.dayShape),
    );
    await expectA11yGuidelines(tester);
  });
}
