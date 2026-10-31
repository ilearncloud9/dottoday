import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/wake_up/wake_up_day.dart';
import 'package:dottoday/features/proposals/proposal_host.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_gate.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../support/test_l10n.dart';
import '../../../support/timeline_fakes.dart';
import '../../../support/today_harness.dart';

/// The demo day (Berlin, Wed 21 Oct 2026) with the Wake Up alarm on.
const wakeUpOn = Settings(use24h: true, wakeUpAlarm: true);

/// A Wake Up card test's handles.
typedef WakeUpHarness = ({FakeWakeUpDayRepository days, GoRouter router});

/// Pumps the card's routes: Today (behind the gate), the card, and stubs
/// for Focus, a task and Add. Starts at [location].
Future<WakeUpHarness> pumpWakeUp(
  WidgetTester tester, {
  String location = AppRoutes.wakeUp,
  Settings settings = wakeUpOn,
  DateTime? now,
  List<Occurrence>? rows,
  List<WakeUpDay> days = const [],
  ThemeMode mode = ThemeMode.light,
  Size size = const Size(390, 1000),
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final store = FakeWakeUpDayRepository(days);
  final router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(
        path: AppRoutes.today,
        // Rebalance's sheet opens over Today, as in the app shell.
        builder: (_, _) => const ProposalHost(
          child: WakeUpCardGate(child: Scaffold(body: Text('today'))),
        ),
      ),
      GoRoute(
        path: AppRoutes.wakeUp,
        builder: (_, _) => const WakeUpCardScreen(),
      ),
      GoRoute(
        path: AppRoutes.focusPattern,
        builder: (_, s) => Text('focus ${s.pathParameters['id']}'),
      ),
      GoRoute(
        path: AppRoutes.taskPattern,
        builder: (_, s) => Text('task ${s.pathParameters['id']}'),
      ),
      GoRoute(path: AppRoutes.add, builder: (_, _) => const Text('add')),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        now: now ?? todayTestNow,
        occurrences: FakeOccurrenceRepository(
          rows ?? demoDayRows(todayTestDate),
        ),
        profile: testProfile(settings: settings),
        wakeUpDays: store,
      ),
      child: MaterialApp.router(
        theme: DotTheme.light(),
        darkTheme: DotTheme.dark(),
        themeMode: mode,
        localizationsDelegates: testL10nDelegates,
        supportedLocales: testL10nLocales,
        locale: testL10nLocale,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (days: store, router: router);
}
