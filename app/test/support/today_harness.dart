import 'package:dottoday/app_task_links.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/onboarding/first_today_store.dart';
import 'package:dottoday/data/scheduling/learning_meta.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_l10n.dart';
import 'timeline_fakes.dart';

/// The demo day the Today tests run on.
final todayTestDate = DateTime(2026, 10, 21);

/// 09:22 in Berlin: Deep work (9:00–11:00) is live.
final todayTestNow = DateTime.utc(2026, 10, 21, 7, 22);

/// Pumps [TodayScreen] on the demo day at [todayTestNow], 1 px per pt.
Future<void> pumpToday(
  WidgetTester tester, {
  List<Occurrence>? rows,
  FakeOccurrenceRepository? repo,
  Size size = const Size(390, 844),
  ThemeMode mode = ThemeMode.light,
  DateTime? date,
  // The Workspace's 3 days view (`/3-days/<date>`, M19.2) on [date] or
  // today; off, Day.
  bool threeDays = false,
  String? name = 'Kody',
  int firstDayOfWeek = 7,
  Settings? settings,
  Stream<DateTime>? ticks,
  ValueChanged<AddTaskIntent>? onAddTask,
  Widget Function(Widget today)? wrap,
  Set<String> readOnlyCalendarIds = const {},
  LearningMetaState learningMeta = const LearningMetaState(),
  FirstTodayState firstToday = const FirstTodayState(),
  bool settle = true,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final profile = testProfile(
    settings:
        settings ?? Settings(use24h: false, firstDayOfWeek: firstDayOfWeek),
  ).copyWith(displayName: name);
  final router = GoRouter(
    // A test's day opens at its own address, as a link to it does.
    initialLocation: threeDays
        ? AppRoutes.threeDays(date ?? todayTestDate)
        : date == null
        ? AppRoutes.today
        : AppRoutes.day(date),
    // Today and its days are one page, as in the app (ED-097).
    routes: [
      // Focus over Today (ED-285): a stand-in naming its task.
      GoRoute(
        path: AppRoutes.focusPattern,
        builder: (_, state) => Text(
          'Focus ${state.pathParameters['id']}', // l10n-ignore: test stand-in
        ),
      ),
      GoRoute(
        path: AppRoutes.today,
        pageBuilder: (_, _) => NoTransitionPage(
          key: const ValueKey(AppRoutes.today),
          child: (wrap ?? (w) => w)(const TodayScreen()),
        ),
      ),
      GoRoute(
        path: AppRoutes.dayPattern,
        pageBuilder: (_, state) => NoTransitionPage(
          key: const ValueKey(AppRoutes.today),
          child: (wrap ?? (w) => w)(
            TodayScreen(date: parseRouteDate(state.pathParameters['date']!)),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.threeDaysPattern,
        pageBuilder: (_, state) => NoTransitionPage(
          key: const ValueKey(AppRoutes.today),
          child: (wrap ?? (w) => w)(
            TodayScreen(
              date: parseRouteDate(state.pathParameters['date']!),
              threeDays: true,
            ),
          ),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        readOnlyCalendarIds: readOnlyCalendarIds,
        now: todayTestNow,
        occurrences:
            repo ??
            FakeOccurrenceRepository(rows ?? demoDayRows(todayTestDate)),
        profile: profile,
        minuteTicks: ticks,
        learningMeta: learningMeta,
        firstToday: firstToday,
      ),
      child: MaterialApp.router(
        theme: DotTheme.light(),
        darkTheme: DotTheme.dark(),
        themeMode: mode,
        localizationsDelegates: testL10nDelegates,
        supportedLocales: testL10nLocales,
        locale: testL10nLocale,
        routerConfig: router,
        // The app root handles AddTaskIntent (M3c.5); tests may listen. A
        // task opens through `?task=` as in the app (ED-097).
        builder: (context, child) => Actions(
          actions: {
            AddTaskIntent: CallbackAction<AddTaskIntent>(
              onInvoke: (i) => onAddTask?.call(i),
            ),
          },
          child: TaskLinkHost(router: router, child: child!),
        ),
      ),
    ),
  );
  if (settle) await tester.pumpAndSettle();
}
