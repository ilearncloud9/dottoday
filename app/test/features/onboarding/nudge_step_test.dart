import 'package:dottoday/data/onboarding/onboarding_store.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/onboarding/day_fills.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:dottoday/features/onboarding/steps/fills/fills_draft.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/onboarding_harness.dart';

// A nudge, in context (M20.11 part 4, prototype `vNudge`; ED-489).

const _nudge = OnboardingProgress(step: OnboardingStep.nudge);
const _h12 = Settings(use24h: false);

final class _Answers implements NotificationPermission {
  _Answers(this.answer);

  final PermissionState answer;
  var asked = 0;

  @override
  Future<PermissionState> status() async => PermissionState.notAsked;

  @override
  Future<PermissionState> request() async {
    asked++;
    return answer;
  }

  @override
  Future<bool> openSettings() async => false;
}

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  List<FillPreset> picks = const [],
  PermissionState answer = PermissionState.granted,
  _Answers? permission,
}) async {
  final c = await pumpOnboarding(
    tester,
    progress: _nudge,
    settings: _h12,
    permission: permission ?? _Answers(answer),
  );
  final draft = c.read(fillsDraftProvider);
  for (final p in picks) {
    c.read(fillsDraftProvider.notifier).toggle(draft.presetIds[p]!);
  }
  await tester.pumpAndSettle();
  return c;
}

Future<Settings> _settings(ProviderContainer c) async =>
    (await c.read(settingsRepositoryProvider).findLocalProfile())!.settings;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('the next pick after now is the subject', (tester) async {
    // 11:00 in Berlin: the run (7:15) is past, Read (20:30) is next.
    await _pump(tester, picks: [FillPreset.morningRun, FillPreset.read]);
    expect(find.text('Want this before Read?'), findsOneWidget);
    expect(find.text('Read in 10 minutes'), findsOneWidget);
    expect(find.text('8:30 PM – 9:00 PM'), findsOneWidget);
    expect(find.text('8:20 PM'), findsOneWidget);
    expect(find.text('8:30 PM · 30 min'), findsOneWidget);
    expect(find.text('PREVIEW'), findsOneWidget);
    expect(
      find.text(
        'A quiet nudge 10 minutes before each task. Change it any time.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('nothing picked: Wind Down', (tester) async {
    await _pump(tester);
    expect(find.text('Want this before Wind Down?'), findsOneWidget);
    expect(find.text('Wind Down in 10 minutes'), findsOneWidget);
  });

  testWidgets('focus moves to Allow nudges', (tester) async {
    await _pump(tester);
    final allow = find.widgetWithText(FilledButton, 'Allow nudges');
    expect(
      Focus.of(tester.element(find.text('Allow nudges'))).hasFocus,
      isTrue,
    );
    expect(allow, findsOneWidget);
  });

  testWidgets('Not now: Today, with both off', (tester) async {
    final permission = _Answers(PermissionState.granted);
    final c = await _pump(tester, permission: permission);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(c.read(onboardingProvider).requireValue.finished, isTrue);
    expect(permission.asked, 0);
    final s = await _settings(c);
    expect(s.windDownReminder, isFalse);
    expect(s.wakeUpAlarm, isFalse);
  });

  testWidgets('a no to notifications: Today, with both off', (tester) async {
    final c = await _pump(tester, answer: PermissionState.denied);
    await tester.tap(find.text('Allow nudges'));
    await tester.pumpAndSettle();
    expect(c.read(onboardingProvider).requireValue.finished, isTrue);
    expect((await _settings(c)).windDownReminder, isFalse);
  });

  testWidgets('allowed: Two more, off unless turned on (ED-489)', (
    tester,
  ) async {
    final c = await _pump(tester);
    await tester.tap(find.text('Allow nudges'));
    await tester.pumpAndSettle();
    expect(find.text('Two more, if you like'), findsOneWidget);
    expect(find.text('Wind Down reminder'), findsOneWidget);
    expect(find.text('A nudge at 10:00 PM'), findsOneWidget);
    await tester.tap(find.text('Wind Down reminder'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(c.read(onboardingProvider).requireValue.finished, isTrue);
    final s = await _settings(c);
    expect(s.windDownReminder, isTrue);
    expect(s.wakeUpAlarm, isFalse);
  });

  testWidgets('meets a11y guidelines (R-12)', (tester) async {
    await _pump(tester, picks: [FillPreset.read]);
    await expectA11yGuidelines(tester);
  });
}
