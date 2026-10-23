import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/account_fakes.dart';
import '../../support/onboarding_harness.dart';

// O5 Account and its states (docs/09 M4.5, M4.7).

const _step = OnboardingProgress(step: OnboardingStep.account);

Future<FakeAccountService> _pump(
  WidgetTester tester, {
  Result<void, AppFailure> result = const Ok(null),
  OnboardingProgress progress = _step,
}) async {
  final accounts = FakeAccountService(result: result);
  addTearDown(accounts.restore.close);
  addTearDown(accounts.accounts.close);
  await pumpOnboarding(
    tester,
    progress: progress,
    extra: [accountServiceProvider.overrideWithValue(accounts)],
  );
  return accounts;
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('without an account: on, sign-in shown off for now', (
    tester,
  ) async {
    final c = await pumpOnboarding(tester, progress: _step);
    final apple = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Continue with Apple'),
    );
    expect(apple.onPressed, isNull);
    expect(find.textContaining('arrives with sync'), findsOneWidget);
    await tester.ensureVisible(find.text('Continue without an account'));
    await tester.tap(find.text('Continue without an account'));
    await tester.pumpAndSettle();
    expect(stepOf(c), OnboardingStep.done);
  });

  testWidgets('returning: "Welcome back"', (tester) async {
    await _pump(
      tester,
      progress: const OnboardingProgress(
        step: OnboardingStep.account,
        returning: true,
      ),
    );
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('Apple, then the restore with its count, then on', (
    tester,
  ) async {
    final accounts = await _pump(tester);
    await tester.tap(find.text('Continue with Apple'));
    await tester.pumpAndSettle();
    expect(accounts.calls, ['signIn:apple']);
    // The page opening isn't signing in (M6.1): still choosing.
    expect(find.text('Bringing your tasks to this device…'), findsNothing);
    accounts.accounts.add(
      const SignedIn(email: 'kody@example.com', method: SignInMethod.apple),
    );
    await tester.pumpAndSettle();
    accounts.restore.add(const RestoreProgress(done: 120, total: 300));
    await tester.pump();
    await tester.pump();
    expect(find.text('Bringing your tasks to this device…'), findsOneWidget);
    expect(find.text('120 of 300'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    accounts.restore.add(const RestoreProgress(done: 300, total: 300));
    await tester.pumpAndSettle();
    expect(find.text('Your first thread'), findsOneWidget);
  });

  testWidgets('email: a bad address, then the link, then check mail', (
    tester,
  ) async {
    final accounts = await _pump(tester);
    await tester.tap(find.text('Continue with email'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'kody');
    await tester.tap(find.text('Send me a link'));
    await tester.pumpAndSettle();
    expect(
      find.text("That doesn't look like an email address."),
      findsOneWidget,
    );
    expect(accounts.calls, isEmpty);
    await tester.enterText(find.byType(TextField), ' kody@example.com ');
    await tester.tap(find.text('Send me a link'));
    await tester.pumpAndSettle();
    expect(accounts.calls, ['link:kody@example.com']);
    expect(find.text('Check your mail'), findsOneWidget);
    expect(find.textContaining('kody@example.com'), findsOneWidget);
    await tester.tap(find.text('Send it again'));
    await tester.pumpAndSettle();
    expect(accounts.calls, hasLength(2));
  });

  testWidgets('an error says why; Try again asks again', (tester) async {
    final accounts = await _pump(tester, result: const Err(AuthFailure()));
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(find.text("Couldn't sign in"), findsOneWidget);
    expect(find.textContaining('Sign in again'), findsOneWidget);
    accounts.result = const Ok(null);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(accounts.calls, ['signIn:google', 'signIn:google']);
    expect(find.text("Couldn't sign in"), findsNothing);
  });

  testWidgets('meets a11y guidelines (R-12)', (tester) async {
    await pumpOnboarding(tester, progress: _step);
    await expectA11yGuidelines(tester);
  });
}
