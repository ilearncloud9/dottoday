import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/month_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/timeline_fakes.dart';

// M1, the Mac/web Month (docs/09 M3e.4, `A-mac-month`). Wed 21 Oct 2026,
// 09:22 in Berlin; the demo week 18–24 Oct.

Future<GoRouter> _pump(
  WidgetTester tester, {
  ThemeMode mode = ThemeMode.light,
}) async {
  tester.view
    ..physicalSize = const Size(1280, 1100)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: '/month',
    routes: [
      GoRoute(path: '/month', builder: (_, _) => const MonthScreen()),
      GoRoute(path: '/week', builder: (_, _) => const Text('week page')),
      GoRoute(
        path: '/day/:date',
        builder: (_, s) => Text('day ${s.pathParameters['date']}'),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        now: DateTime.utc(2026, 10, 21, 7, 22),
        occurrences: FakeOccurrenceRepository(demoWeekRows()),
        profile: testProfile(
          settings: const Settings(use24h: false, firstDayOfWeek: 7),
        ),
      ),
      child: MaterialApp.router(
        routerConfig: router,
        theme: DotTheme.light(),
        darkTheme: DotTheme.dark(),
        themeMode: mode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('the month: title, numbers, cells', (tester) async {
    await _pump(tester);
    expect(find.text('October 2026'), findsOneWidget);
    expect(
      find.textContaining(RegExp(r'^\d+ done · \d+ not done · \d+ ahead')),
      findsOneWidget,
    );
    expect(find.textContaining('busiest day Tue, Oct 20'), findsOneWidget);
    // Today shows three tasks; the live one is fourth, behind "+N more".
    expect(find.textContaining(RegExp(r'^\+\d+ more')), findsWidgets);
    expect(find.textContaining('of 3 done'), findsWidgets);
  });

  testWidgets('Ctrl+→ steps a month; a day opens its Today', (tester) async {
    final router = await _pump(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.text('November 2026'), findsOneWidget);
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel(RegExp('^Thursday, October 22')));
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), '/day/2026-10-22');
  });

  testWidgets('Week | Month goes to the Week board', (tester) async {
    final router = await _pump(tester);
    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), '/week');
  });

  testWidgets('meets a11y guidelines in both themes', (tester) async {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await _pump(tester, mode: mode);
      await expectA11yGuidelines(tester);
    }
  });
}
