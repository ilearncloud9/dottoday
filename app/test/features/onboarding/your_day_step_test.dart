import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/features/onboarding/steps/day_dial_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/onboarding_harness.dart';

// Your day (M20.11 part 2, prototype `vDay`): the sun and the moon on the
// sky, saved as they move.

const _day = OnboardingProgress(step: OnboardingStep.day);

/// The prototype's 12-hour clock.
const _h12 = Settings(use24h: false);

Future<(int, int)> _stored(ProviderContainer c) async {
  final p = await c.read(settingsRepositoryProvider).findLocalProfile();
  final w = p!.settings.boundaryFor(Weekday.mon);
  return (windowMinutes(w.start), windowMinutes(w.end));
}

Finder get _sun => find.byType(DayDialHandle).first;
Finder get _moon => find.byType(DayDialHandle).last;

Future<void> _keys(
  WidgetTester tester,
  Finder handle,
  List<LogicalKeyboardKey> keys,
) async {
  Focus.of(
    tester.element(
      find.descendant(of: handle, matching: find.byType(Listener)).first,
    ),
  ).requestFocus();
  await tester.pump();
  for (final k in keys) {
    await tester.sendKeyEvent(k);
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('a new account starts at 7:00 and 23:00, 8 h of sleep', (
    tester,
  ) async {
    final c = await pumpOnboarding(tester, progress: _day, settings: _h12);
    expect(find.text('Your day runs from…'), findsOneWidget);
    expect(
      find.text(
        'Drag the sun and the moon. You can fine-tune each weekday later.',
      ),
      findsOneWidget,
    );
    expect(find.text('WAKE UP'), findsOneWidget);
    expect(find.text('WIND DOWN'), findsOneWidget);
    expect(find.text('7:00 AM'), findsOneWidget);
    expect(find.text('11:00 PM'), findsOneWidget);
    expect(find.text('16 h awake · 8 h of sleep'), findsOneWidget);
    for (final h in [
      '5 AM',
      '8 AM',
      '11 AM',
      '2 PM',
      '5 PM',
      '8 PM',
      '11 PM',
      '1 AM',
    ]) {
      expect(find.text(h), findsOneWidget, reason: h);
    }
    expect(await _stored(c), (420, 1380));
  });

  testWidgets('dragging the sun follows the finger in 15-minute steps', (
    tester,
  ) async {
    final c = await pumpOnboarding(tester, progress: _day, settings: _h12);
    await tester.drag(_sun, const Offset(0, 60));
    await tester.pumpAndSettle();
    final (wake, wind) = await _stored(c);
    expect(wake, greaterThan(420));
    expect(wake % 15, 0);
    expect(wind, 1380);
    // Up past the top stops at 4:00.
    await tester.drag(_sun, const Offset(0, -900));
    await tester.pumpAndSettle();
    expect((await _stored(c)).$1, 240);
  });

  testWidgets('keys: arrows move 15 minutes, Page Up and Down an hour', (
    tester,
  ) async {
    final c = await pumpOnboarding(tester, progress: _day, settings: _h12);
    await _keys(tester, _sun, [
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.pageDown,
    ]);
    expect((await _stored(c)).$1, 420 + 75);
    expect(find.text('8:15 AM'), findsOneWidget);
    await _keys(tester, _moon, [
      LogicalKeyboardKey.pageDown,
      LogicalKeyboardKey.pageDown,
      LogicalKeyboardKey.pageDown,
      LogicalKeyboardKey.pageDown,
    ]);
    // Wind Down stops at 2:00 the next morning.
    expect((await _stored(c)).$2, 1560);
    expect(find.text('2:00 AM'), findsOneWidget);
    expect(
      find.text('17 h 45 min awake · 6 h 15 min of sleep'),
      findsOneWidget,
    );
  });

  testWidgets('a selection tick when the time reaches an hour', (tester) async {
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
    await pumpOnboarding(tester, progress: _day, settings: _h12);
    await _keys(tester, _sun, [LogicalKeyboardKey.arrowDown]);
    expect(calls, isEmpty);
    await _keys(tester, _sun, [
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.arrowDown,
    ]);
    expect(calls, ['HapticFeedbackType.selectionClick']);
  });

  testWidgets('screen readers: sliders read "Wake Up, 7:00 AM" and step', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final c = await pumpOnboarding(tester, progress: _day, settings: _h12);
    expect(
      tester.getSemantics(_sun),
      isSemantics(
        isSlider: true,
        label: 'Wake Up',
        value: '7:00 AM',
        hasIncreaseAction: true,
        hasDecreaseAction: true,
      ),
    );
    tester.semantics.performAction(
      find.semantics.byLabel('Wake Up'),
      SemanticsAction.increase,
    );
    await tester.pumpAndSettle();
    expect((await _stored(c)).$1, 435);
    handle.dispose();
  });

  testWidgets('Continue moves on', (tester) async {
    final c = await pumpOnboarding(tester, progress: _day, settings: _h12);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();
    expect(stepOf(c), OnboardingStep.fills);
  });

  testWidgets('at 200 % text the step scrolls to Continue', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpOnboarding(tester, progress: _day, settings: _h12);
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, 'Continue'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.widgetWithText(FilledButton, 'Continue').hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('a 24-hour clock reads 07:00 and marks 05 … 01', (tester) async {
    await pumpOnboarding(tester, progress: _day);
    expect(find.text('07:00'), findsOneWidget);
    expect(find.text('23:00'), findsOneWidget);
    expect(find.text('05'), findsOneWidget);
    expect(find.text('01'), findsOneWidget);
  });

  testWidgets('meets a11y guidelines (R-12)', (tester) async {
    await pumpOnboarding(tester, progress: _day, settings: _h12);
    await expectA11yGuidelines(tester);
  });
}
