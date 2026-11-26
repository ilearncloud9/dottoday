import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:dottoday/features/onboarding/steps/fills/fills_draft.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/onboarding_harness.dart';
import '../../support/timeline_fakes.dart';

// What fills your days? (M20.11 part 3, prototype `vRhythm`): picks land
// on the thread and become tasks that repeat every day on That's my day.

const _fills = OnboardingProgress(step: OnboardingStep.fills);
const _h12 = Settings(use24h: false);

Future<ProviderContainer> _pump(WidgetTester tester) =>
    pumpOnboarding(tester, progress: _fills, settings: _h12);

FakeUndoService _writes(ProviderContainer c) =>
    c.read(undoServiceProvider) as FakeUndoService;

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).last);
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('the empty day: Wake Up, Wind Down, NOW, four chips', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.text('What fills your days?'), findsOneWidget);
    expect(
      find.text('Tap any. They land on the thread at a time that fits.'),
      findsOneWidget,
    );
    expect(find.text('Wake Up'), findsOneWidget);
    expect(find.text('Start of your day'), findsOneWidget);
    expect(find.text('Wind Down'), findsOneWidget);
    expect(find.text('Time to slow down'), findsOneWidget);
    expect(find.text('NOW'), findsOneWidget);
    for (final c in ['Morning run', 'Deep work', 'Gym', 'Read']) {
      expect(find.text(c), findsOneWidget, reason: c);
    }
    expect(find.text('0 of 5'), findsOneWidget);
    expect(find.text('Skip for now'), findsOneWidget);
  });

  testWidgets('a pick lands at a time that fits, "Most days"', (tester) async {
    final calls = <String?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          calls.add(call.arguments as String?);
        }
        return null;
      },
    );
    await _pump(tester);
    await _tap(tester, 'Morning run');
    await _tap(tester, 'Read');
    // The default day is 7:00 to 22:00 (Settings' default).
    expect(find.text('7:15 AM'), findsOneWidget);
    expect(find.text('8:30 PM'), findsOneWidget);
    expect(find.text('Most days'), findsNWidgets(2));
    expect(find.text('2 of 5'), findsOneWidget);
    expect(find.text('That’s my day'), findsOneWidget);
    expect(calls, hasLength(2));
  });

  testWidgets("That's my day saves daily tasks, once", (tester) async {
    final c = await _pump(tester);
    await _tap(tester, 'Gym');
    await _tap(tester, 'That’s my day');
    expect(stepOf(c), OnboardingStep.nudge);
    final batch = _writes(c).applied.single;
    final gym = batch.series.single;
    expect(gym.title, 'Gym');
    expect(gym.rrule, 'FREQ=DAILY');
    expect(gym.durationMin, 60);
    expect(gym.dtstartLocal, endsWith('T18:00'));
    expect(gym.iconKey, 'gym');
    expect(gym.colorKey, 'violet');
    // Saving again (Back, then That's my day) writes the same task.
    final again = c.read(fillsDraftProvider).presetIds.values.toSet();
    expect(again, contains(gym.id));
  });

  testWidgets('Add your own: its words, its time, its icon', (tester) async {
    final c = await _pump(tester);
    await tester.enterText(find.byType(TextField), 'walk the dog 7pm');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Walk the dog'), findsNWidgets(2));
    expect(find.text('7:00 PM'), findsOneWidget);
    expect(find.text('1 of 5'), findsOneWidget);
    await _tap(tester, 'That’s my day');
    final s = _writes(c).applied.single.series.single;
    expect(s.dtstartLocal, endsWith('T19:00'));
    expect(s.iconKey, isNot('circle'));
  });

  testWidgets('five is plenty: the rest are off and the field says so', (
    tester,
  ) async {
    await _pump(tester);
    for (final c in ['Morning run', 'Deep work', 'Gym', 'Read']) {
      await _tap(tester, c);
    }
    await tester.enterText(find.byType(TextField), 'piano');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('5 of 5'), findsOneWidget);
    expect(find.text('Five is plenty to start with.'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
  });

  testWidgets('Skip for now writes nothing', (tester) async {
    final c = await _pump(tester);
    await _tap(tester, 'Skip for now');
    expect(stepOf(c), OnboardingStep.nudge);
    expect(_writes(c).applied, isEmpty);
  });

  testWidgets('meets a11y guidelines (R-12)', (tester) async {
    await _pump(tester);
    await expectA11yGuidelines(tester);
  });
}
