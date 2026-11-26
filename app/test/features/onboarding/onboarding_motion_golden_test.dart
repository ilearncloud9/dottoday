// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/data/onboarding/onboarding_store.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:dottoday/features/onboarding/onboarding_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/onboarding_fakes.dart';
import '../../support/timeline_fakes.dart';

// The onboarding's motion, frame by frame (prototype motion table;
// M20.11 part 1): Hello's day dot drawing itself, and a step change.

Future<void> _shot(WidgetTester tester, String name) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(GoldenFrame.boundaryKey),
  );
  final image = await tester.runAsync(() => boundary.toImage(pixelRatio: 2));
  await expectLater(image, matchesGoldenFile('goldens/$name.png'));
}

Future<void> _pump(WidgetTester tester, OnboardingStep step) async {
  tester.view
    ..physicalSize = const Size(390, 844) * 2
    ..devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  debugDisableShadows = false;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...timelineOverrides(
          now: DateTime.utc(2026, 10, 21, 9),
          profile: testProfile(),
        ),
        onboardingProvider.overrideWith(
          () => FakeOnboarding(OnboardingProgress(step: step)),
        ),
      ],
      child: goldenApp(const OnboardingGate(child: SizedBox.shrink())),
    ),
  );
}

void main() {
  tz_data.initializeTimeZones();
  setUpAll(loadAppFonts);

  testWidgets('Hello draws itself', (tester) async {
    try {
      await _pump(tester, OnboardingStep.hello);
      // Let the progress load; the drawing starts with Hello's first frame.
      await tester.pump();
      var at = Duration.zero;
      for (final ms in [250, 600, 1000, 1450, 1750, 2400]) {
        await tester.pump(Duration(milliseconds: ms) - at);
        at = Duration(milliseconds: ms);
        await _shot(tester, 'onboarding_motion_hello_${ms}ms');
      }
    } finally {
      debugDisableShadows = true;
    }
  });

  testWidgets('Get started: Your day rises in', (tester) async {
    try {
      await _pump(tester, OnboardingStep.hello);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get started'));
      await tester.pump();
      var at = Duration.zero;
      for (final ms in [80, 160, 300]) {
        await tester.pump(Duration(milliseconds: ms) - at);
        at = Duration(milliseconds: ms);
        await _shot(tester, 'onboarding_motion_step_${ms}ms');
      }
      await tester.pumpAndSettle();
    } finally {
      debugDisableShadows = true;
    }
  });
}
