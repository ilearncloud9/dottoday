import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:dottoday/features/onboarding/flow/onb_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/onboarding_harness.dart';

// The flow rules of the approved onboarding (ED-305, ED-350; M20.11,
// ED-485; PRD F10).

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('five steps, no Layout step; two ask for input', () {
    expect(OnboardingStep.values, [
      OnboardingStep.hello,
      OnboardingStep.day,
      OnboardingStep.fills,
      OnboardingStep.nudge,
      OnboardingStep.today,
    ]);
    expect(OnboardingStep.values.where((s) => s.asksForInput), [
      OnboardingStep.day,
      OnboardingStep.fills,
    ]);
  });

  test('the dots count the three middle steps', () {
    expect(
      [for (final s in OnboardingStep.values) s.dot],
      [null, 1, 2, 3, null],
    );
  });

  test('a step of the replaced flow starts over; a finished one stays', () {
    expect(
      OnboardingProgress.fromJson({'step': 'layout'}).step,
      OnboardingStep.hello,
    );
    expect(
      OnboardingProgress.fromJson({'step': 'done', 'finished': true}).finished,
      isTrue,
    );
  });

  testWidgets('three required taps from Hello to Today', (tester) async {
    final c = await pumpOnboarding(tester);
    Future<void> tap(String text) async {
      await tester.ensureVisible(find.text(text).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(text).first);
      await tester.pumpAndSettle();
    }

    await tap('Get started');
    expect(stepOf(c), OnboardingStep.day);
    expect(find.bySemanticsLabel('Step 1 of 3'), findsWidgets);
    await tap('Continue');
    expect(stepOf(c), OnboardingStep.fills);
    expect(find.bySemanticsLabel('Step 2 of 3'), findsWidgets);
    await tap('Skip for now');
    expect(stepOf(c), OnboardingStep.nudge);
    // The layout stays Full: no Layout step (ED-350, ED-485).
    expect(c.read(uiLayoutProvider), UiLayout.full);
  });

  testWidgets('Back and Esc go back; Hello has no Back', (tester) async {
    final c = await pumpOnboarding(
      tester,
      progress: const OnboardingProgress(step: OnboardingStep.fills),
    );
    await tester.tap(find.byKey(OnbKeys.back));
    await tester.pumpAndSettle();
    expect(stepOf(c), OnboardingStep.day);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(stepOf(c), OnboardingStep.hello);
    expect(find.byKey(OnbKeys.back), findsNothing);
    // Esc on Hello stays.
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(stepOf(c), OnboardingStep.hello);
  });

  testWidgets('Return continues', (tester) async {
    final c = await pumpOnboarding(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(stepOf(c), OnboardingStep.day);
  });

  testWidgets('I have an account opens sign-in; Back returns to Hello', (
    tester,
  ) async {
    final c = await pumpOnboarding(tester);
    await tester.tap(find.text('I have an account'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    await tester.tap(find.byKey(OnbKeys.back));
    await tester.pumpAndSettle();
    expect(stepOf(c), OnboardingStep.hello);
    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets('Hello: the age note under the buttons (ED-351)', (tester) async {
    await pumpOnboarding(tester);
    final note = tester.getTopLeft(
      find.text('Dottoday is for people aged 13+.'),
    );
    expect(
      note.dy,
      greaterThan(tester.getBottomLeft(find.text('I have an account')).dy),
    );
  });

  testWidgets('tablets, Mac and web: a card over the app', (tester) async {
    await pumpOnboarding(tester, size: const Size(1280, 830));
    expect(find.byKey(OnbKeys.card), findsOneWidget);
    // The app is there behind it, out of reach.
    expect(find.text('the app', skipOffstage: false), findsOneWidget);
  });

  testWidgets("You're in on a wide window: the card leaves, the app stays", (
    tester,
  ) async {
    final c = await pumpOnboarding(
      tester,
      size: const Size(1280, 830),
      progress: const OnboardingProgress(step: OnboardingStep.nudge),
    );
    final app = tester.state(find.byType(MaterialApp));
    await tester.tap(find.text('Not now'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // Mid-exit: the card is still there, on its way out.
    expect(find.byKey(OnbKeys.card), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byKey(OnbKeys.card), findsNothing);
    expect(find.text('the app'), findsOneWidget);
    expect(stepOf(c), OnboardingStep.today);
    // The same app, not a new one (its state was kept).
    expect(tester.state(find.byType(MaterialApp)), same(app));
  });
}
