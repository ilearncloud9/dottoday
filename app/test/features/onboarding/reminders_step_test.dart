import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/onboarding_harness.dart';

// O4 Reminders (docs/09 M4.4): both answers to the system prompt.

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

const _step = OnboardingProgress(step: OnboardingStep.reminders);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('allowed: on to the account step', (tester) async {
    final os = _Answers(PermissionState.granted);
    final c = await pumpOnboarding(tester, progress: _step, permission: os);
    await tester.ensureVisible(find.text('Allow notifications'));
    await tester.tap(find.text('Allow notifications'));
    await tester.pumpAndSettle();
    expect(os.asked, 1);
    expect(stepOf(c), OnboardingStep.account);
  });

  testWidgets('denied: the notice, then Continue', (tester) async {
    final os = _Answers(PermissionState.denied);
    final c = await pumpOnboarding(tester, progress: _step, permission: os);
    await tester.ensureVisible(find.text('Allow notifications'));
    await tester.tap(find.text('Allow notifications'));
    await tester.pumpAndSettle();
    expect(stepOf(c), OnboardingStep.reminders);
    expect(find.text('Notifications are off'), findsOneWidget);
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Continue'));
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();
    expect(stepOf(c), OnboardingStep.account);
  });

  testWidgets('Not now asks nothing; the Bedtime switch saves', (tester) async {
    final os = _Answers(PermissionState.granted);
    final c = await pumpOnboarding(tester, progress: _step, permission: os);
    await tester.tap(find.text('At Bedtime'));
    await tester.pumpAndSettle();
    final stored = await c.read(settingsRepositoryProvider).findLocalProfile();
    // On by default; the switch turns it off.
    expect(stored!.settings.bedtimeReminder, isFalse);
    await tester.ensureVisible(find.text('Not now'));
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(os.asked, 0);
    expect(stepOf(c), OnboardingStep.account);
  });

  testWidgets('meets a11y guidelines (R-12)', (tester) async {
    await pumpOnboarding(tester, progress: _step);
    await expectA11yGuidelines(tester);
  });
}
