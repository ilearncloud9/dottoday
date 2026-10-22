import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/onboarding_harness.dart';

// O5 Account (docs/09 M4.5): sign in, or carry on without an account.

/// Accounts on; [signIn] answers [result].
final class _Accounts implements AccountService {
  _Accounts(this.result);

  final Result<void, AppFailure> result;
  final asked = <SignInMethod>[];

  @override
  bool get available => true;

  @override
  Stream<Account> watch() => Stream.value(const LocalOnly());

  @override
  Future<Result<void, AppFailure>> signIn(SignInMethod method) async {
    asked.add(method);
    return result;
  }

  @override
  Future<Result<void, AppFailure>> signOut() async => const Ok(null);

  @override
  Future<Result<void, AppFailure>> deleteAccount() async => const Ok(null);
}

const _step = OnboardingProgress(step: OnboardingStep.account);

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

  testWidgets('signed in with Apple: on', (tester) async {
    final accounts = _Accounts(const Ok(null));
    final c = await pumpOnboarding(
      tester,
      progress: _step,
      extra: [accountServiceProvider.overrideWithValue(accounts)],
    );
    await tester.tap(find.text('Continue with Apple'));
    await tester.pumpAndSettle();
    expect(accounts.asked, [SignInMethod.apple]);
    expect(stepOf(c), OnboardingStep.done);
  });

  testWidgets('a failed sign-in stays and says why', (tester) async {
    final accounts = _Accounts(const Err(AuthFailure()));
    final c = await pumpOnboarding(
      tester,
      progress: _step,
      extra: [accountServiceProvider.overrideWithValue(accounts)],
    );
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(stepOf(c), OnboardingStep.account);
    expect(find.textContaining('Sign in again'), findsOneWidget);
  });

  testWidgets('meets a11y guidelines (R-12)', (tester) async {
    await pumpOnboarding(tester, progress: _step);
    await expectA11yGuidelines(tester);
  });
}
