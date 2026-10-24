import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/calendar_fakes.dart';
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

  testWidgets('allowed: the test alarm is offered, Continue goes on', (
    tester,
  ) async {
    final os = _Answers(PermissionState.granted);
    final c = await pumpOnboarding(tester, progress: _step, permission: os);
    await tester.ensureVisible(find.text('Allow notifications'));
    await tester.tap(find.text('Allow notifications'));
    await tester.pumpAndSettle();
    expect(os.asked, 1);
    // M6.5.9: stays to offer the test alarm (skippable).
    expect(stepOf(c), OnboardingStep.reminders);
    expect(find.text('Send me a test alarm'), findsOneWidget);
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Continue'));
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();
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

  testWidgets('Connect a calendar: allowed → connected, choose in Settings', (
    tester,
  ) async {
    final os = FakeDeviceCalendarGateway(list: sampleCalendars);
    final c = await pumpOnboarding(
      tester,
      progress: _step,
      calendarGateway: os,
    );
    await tester.ensureVisible(find.text('Connect a calendar'));
    await tester.tap(find.text('Connect a calendar'));
    await tester.pumpAndSettle();
    expect(os.asked, 1);
    expect(find.text('Connected · choose calendars in Settings'), findsOne);
    await expectA11yGuidelines(tester);
    // Optional: the step stays until Continue.
    expect(stepOf(c), OnboardingStep.reminders);
  });

  testWidgets('Connect a calendar: denied → the calendar notice', (
    tester,
  ) async {
    final os = FakeDeviceCalendarGateway(answer: PermissionState.denied);
    await pumpOnboarding(tester, progress: _step, calendarGateway: os);
    await tester.ensureVisible(find.text('Connect a calendar'));
    await tester.tap(find.text('Connect a calendar'));
    await tester.pumpAndSettle();
    expect(find.text('Calendar access is off'), findsOneWidget);
    await expectA11yGuidelines(tester);
  });

  testWidgets('no device calendars here: the row is off', (tester) async {
    await pumpOnboarding(tester, progress: _step);
    expect(
      find.text('Connect Google or Microsoft in Settings › Calendars.'),
      findsOne,
    );
  });

  testWidgets('meets a11y guidelines (R-12)', (tester) async {
    await pumpOnboarding(tester, progress: _step);
    await expectA11yGuidelines(tester);
  });
}
