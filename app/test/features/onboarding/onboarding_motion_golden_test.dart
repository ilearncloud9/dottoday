// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/data/onboarding/onboarding_store.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';

import 'package:dottoday/features/onboarding/onboarding_gate.dart';
import 'package:dottoday/features/onboarding/steps/day_dial_parts.dart';
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
// M20.11 parts 1 and 2): Hello's day dot drawing itself, a step change,
// the sun held and dragged onto an hour, and a pick flying onto the
// thread.

Future<void> _shot(WidgetTester tester, String name) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(GoldenFrame.boundaryKey),
  );
  final image = await tester.runAsync(() => boundary.toImage(pixelRatio: 2));
  await expectLater(image, matchesGoldenFile('goldens/$name.png'));
}

Future<void> _pump(
  WidgetTester tester,
  OnboardingStep step, {
  Settings? settings,
}) async {
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
          profile: testProfile(settings: settings),
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

  testWidgets('Your day: the sun held, then its label pops at 8:00', (
    tester,
  ) async {
    try {
      await _pump(
        tester,
        OnboardingStep.day,
        settings: const Settings(use24h: false),
      );
      await tester.pumpAndSettle();
      final sun = tester.getCenter(find.byType(DayDialHandle).first);
      final finger = await tester.startGesture(sun);
      await tester.pump(const Duration(milliseconds: 75));
      await _shot(tester, 'onboarding_motion_day_held_75ms');
      await tester.pump(const Duration(milliseconds: 75));
      await _shot(tester, 'onboarding_motion_day_held_150ms');
      // Down to 8:00: past the slop, then onto the hour.
      final step =
          (tester.getCenter(find.byType(DayDialHandle).last).dy - sun.dy) /
          (1380 - 420);
      await finger.moveBy(const Offset(0, 20));
      await finger.moveTo(Offset(sun.dx, sun.dy + 60 * step));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 110));
      await _shot(tester, 'onboarding_motion_day_pop_110ms');
      await tester.pump(const Duration(milliseconds: 110));
      await _shot(tester, 'onboarding_motion_day_pop_220ms');
      await finger.up();
      await tester.pumpAndSettle();
      await _shot(tester, 'onboarding_motion_day_let_go');
    } finally {
      debugDisableShadows = true;
    }
  });

  testWidgets('What fills your days: Read flies onto the thread', (
    tester,
  ) async {
    try {
      await _pump(
        tester,
        OnboardingStep.fills,
        settings: Settings(
          use24h: false,
          dayBoundaries: {
            for (final d in Weekday.values)
              d: const TimeWindow(start: '07:00', end: '23:00'),
          },
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Read'));
      await tester.pump();
      var at = Duration.zero;
      for (final ms in [1, 140, 280, 420, 560, 640, 720, 880]) {
        await tester.pump(Duration(milliseconds: ms) - at);
        at = Duration(milliseconds: ms);
        await _shot(tester, 'onboarding_motion_fills_${ms}ms');
      }
      await tester.pumpAndSettle();
    } finally {
      debugDisableShadows = true;
    }
  });
}
