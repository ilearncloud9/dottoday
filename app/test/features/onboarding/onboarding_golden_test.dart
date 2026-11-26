// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/onboarding/onboarding_store.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:dottoday/features/onboarding/onboarding_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/account_fakes.dart';
import '../../support/calendar_fakes.dart';
import '../../support/dot_golden.dart';
import '../../support/first_thread_rows.dart';
import '../../support/onboarding_fakes.dart';
import '../../support/timeline_fakes.dart';

// The approved onboarding (the "Dottoday Onboarding Prototype", ED-305;
// M20.11, ED-485). Your day, What fills your days and the nudge are the
// built steps until parts 2 to 4 replace them.

/// A first run: nobody has been asked about notifications yet.
final class _NotAsked implements NotificationPermission {
  const _NotAsked();

  @override
  Future<PermissionState> status() async => PermissionState.notAsked;

  @override
  Future<PermissionState> request() async => PermissionState.granted;

  @override
  Future<bool> openSettings() async => false;
}

List<Override> _at(
  OnboardingStep step, {
  NotificationPermission permission = const _NotAsked(),
  bool account = false,
}) => [
  ...timelineOverrides(
    now: DateTime.utc(2026, 10, 21, 9),
    notificationPermission: permission,
    // A phone with device calendars, not asked yet (O4's row, M7.1).
    calendarGateway: FakeDeviceCalendarGateway(),
    occurrences: FakeOccurrenceRepository(firstThreadRows()),
    profile: testProfile(),
  ),
  onboardingProvider.overrideWith(
    () => FakeOnboarding(OnboardingProgress(step: step, account: account)),
  ),
];

void main() {
  // The overrides are built as the tests are declared.
  tz_data.initializeTimeZones();
  setUpAll(loadAppFonts);
  const widths = {'compact', 'expanded'};
  for (final step in [
    OnboardingStep.hello,
    OnboardingStep.day,
    OnboardingStep.fills,
    OnboardingStep.nudge,
  ]) {
    goldenMatrix(
      'onboarding_${step.name}',
      height: 844,
      widths: widths,
      a11yVariants: step == OnboardingStep.hello,
      overrides: _at(step),
      build: (_) => const OnboardingGate(child: _App()),
    );
  }
  // Android: ← alone, the dots balanced by 48 (prototype `.android .back`).
  goldenMatrix(
    'onboarding_day_android',
    height: 844,
    widths: const {'compact'},
    platform: TargetPlatform.android,
    overrides: _at(OnboardingStep.day),
    build: (_) => const OnboardingGate(child: _App()),
  );
  // I have an account: sign-in over Hello, Back only.
  goldenMatrix(
    'onboarding_account',
    height: 844,
    widths: widths,
    overrides: _at(OnboardingStep.hello, account: true),
    build: (_) => const OnboardingGate(child: _App()),
  );
  // O4 once notifications are allowed: the test alarm (M6.5.9).
  goldenMatrix(
    'onboarding_reminders_allowed',
    height: 844,
    widths: widths,
    overrides: _at(
      OnboardingStep.nudge,
      permission: const UnwiredNotificationPermission(),
    ),
    act: (tester) async {
      await tester.ensureVisible(find.text('Send me a test alarm'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send me a test alarm'));
    },
    build: (_) => const OnboardingGate(child: _App()),
  );
  // M4.7 states, with accounts on.
  final accounts = FakeAccountService();
  goldenMatrix(
    'onboarding_check_mail',
    height: 844,
    widths: widths,
    overrides: [
      ..._at(OnboardingStep.hello, account: true),
      accountServiceProvider.overrideWithValue(accounts),
    ],
    act: (tester) async {
      await tester.tap(find.text('Continue with email'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'kody@example.com');
      await tester.tap(find.text('Send me a link'));
    },
    build: (_) => const OnboardingGate(child: _App()),
  );
  goldenMatrix(
    'onboarding_restoring',
    height: 844,
    widths: widths,
    overrides: [
      ..._at(OnboardingStep.hello, account: true),
      accountServiceProvider.overrideWithValue(accounts),
    ],
    act: (tester) async {
      await tester.tap(find.text('Continue with Apple'));
      await tester.pumpAndSettle();
      // Signed in once the provider's page is done (M6.1).
      accounts.accounts.add(
        const SignedIn(email: 'kody@example.com', method: SignInMethod.apple),
      );
      await tester.pumpAndSettle();
      accounts.restore.add(const RestoreProgress(done: 120, total: 300));
      await tester.pump();
    },
    build: (_) => const OnboardingGate(child: _App()),
  );
}

/// A stand-in for the app behind the card on wide screens: the Today
/// title over the thread's rows, so the blur has something to blur.
class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return ColoredBox(
      color: t.colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(DotSpace.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: DotSpace.l,
          children: [
            Text('Today', style: t.styles.onbHero), // l10n-ignore: fixture
            for (final c in [TaskColor.amber, TaskColor.coral, TaskColor.sky])
              Row(
                spacing: DotSpace.m,
                children: [
                  CircleAvatar(
                    radius: DotSpace.l,
                    backgroundColor: t.tasks[c].ring,
                  ),
                  Text(
                    'Morning run',
                    style: t.styles.rowTitle,
                  ), // l10n-ignore: fixture
                ],
              ),
          ],
        ),
      ),
    );
  }
}
