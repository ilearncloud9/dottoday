import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/router_provider.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/onboarding/onboarding_store.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:dottoday/features/onboarding/onboarding_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'onboarding_fakes.dart';
import 'timeline_fakes.dart';

/// The onboarding gate at [progress] in front of a stand-in app ("the
/// app"), at 9:00 UTC on Wed 21 Oct 2026. Returns the container.
Future<ProviderContainer> pumpOnboarding(
  WidgetTester tester, {
  OnboardingProgress progress = OnboardingProgress.start,
  List<Override> extra = const [],
  FakeOccurrenceRepository? repo,
  Size size = const Size(390, 844),
  NotificationPermission? permission,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(
    overrides: [
      ...timelineOverrides(
        now: DateTime.utc(2026, 10, 21, 9),
        occurrences: repo,
        profile: testProfile(),
        notificationPermission:
            permission ?? const UnwiredNotificationPermission(),
      ),
      onboardingProvider.overrideWith(() => FakeOnboarding(progress)),
      // "Open today" goes to /today (M6.1); this app has no routes of its own.
      routerProvider.overrideWithValue(
        GoRouter(
          routes: [GoRoute(path: '/', builder: (_, _) => const SizedBox())],
        ),
      ),
      ...extra,
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: DotTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (_, child) => OnboardingGate(child: child!),
        home: const Scaffold(
          body: Text('the app'), // l10n-ignore: test fixture
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

/// The step the flow is on.
OnboardingStep stepOf(ProviderContainer c) =>
    c.read(onboardingProvider).requireValue.step;
