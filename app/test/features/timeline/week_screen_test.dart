import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/week/grid_block_lines.dart';
import 'package:dottoday/features/timeline/week/week_card.dart';
import 'package:dottoday/features/timeline/week_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/timeline_fakes.dart';

// W1, the Mac/web Week board (docs/09 M3e.3). Wed 21 Oct 2026, 09:22 in
// Berlin; the week starts on Sunday. Tests run on Android, so Ctrl.

Future<FakeOccurrenceRepository> _pump(
  WidgetTester tester, {
  ThemeMode mode = ThemeMode.light,
}) async {
  tester.view
    ..physicalSize = const Size(1280, 1000)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = FakeOccurrenceRepository(demoWeekRows());
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        now: DateTime.utc(2026, 10, 21, 7, 22),
        occurrences: repo,
        profile: testProfile(
          settings: const Settings(use24h: false, firstDayOfWeek: 7),
        ),
      ),
      child: MaterialApp.router(
        theme: DotTheme.light(),
        darkTheme: DotTheme.dark(),
        themeMode: mode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: _router(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

/// This week and another are one page, as in the app (ED-097); Month is
/// a placeholder.
GoRouter _router() => GoRouter(
  initialLocation: '/week',
  routes: [
    GoRoute(
      path: '/week',
      pageBuilder: (_, _) =>
          const NoTransitionPage(key: ValueKey('/week'), child: WeekScreen()),
    ),
    GoRoute(
      path: '/week/:date',
      pageBuilder: (_, s) => NoTransitionPage(
        key: const ValueKey('/week'),
        child: WeekScreen(date: parseRouteDate(s.pathParameters['date']!)),
      ),
    ),
    GoRoute(path: '/month', builder: (_, _) => const Text('month page')),
  ],
);

Future<void> _ctrl(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(key);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('this week: days, their counts, summary chips', (tester) async {
    await _pump(tester);
    expect(find.text('This week'), findsOneWidget);
    expect(find.textContaining('October 18 – 24'), findsOneWidget);
    // The hour grid's headers (E-FullA-v2 Week): today's count and time.
    expect(find.text('Wed · Today'), findsOneWidget);
    expect(find.textContaining(RegExp(r'^\d+ of \d+ · ')), findsOneWidget);
    expect(find.text('Busiest · Tue · 6 h 30'), findsOneWidget);
    expect(find.text('Lightest · Sun · 1 h 15'), findsOneWidget);
    expect(find.textContaining('Free · '), findsOneWidget);
    // No drop boxes on the grid (Concept E, owner 2026-11-19).
    expect(find.textContaining('Drop a task here'), findsNothing);
  });

  testWidgets('› and Ctrl+← step a week; Ctrl+T comes back', (tester) async {
    await _pump(tester);
    await tester.tap(find.byTooltip('Next week'));
    await tester.pumpAndSettle();
    // The address is the shown week, by its first day (ED-097).
    String address() => GoRouter.of(
      tester.element(find.byType(WeekScreen)),
    ).routerDelegate.currentConfiguration.uri.toString();
    expect(find.text('October 25 – 31'), findsOneWidget);
    expect(address(), '/week/2026-10-25');
    await _ctrl(tester, LogicalKeyboardKey.arrowLeft);
    await _ctrl(tester, LogicalKeyboardKey.arrowLeft);
    expect(find.text('October 11 – 17'), findsOneWidget);
    expect(address(), '/week/2026-10-11');
    await _ctrl(tester, LogicalKeyboardKey.keyT);
    expect(find.text('This week'), findsOneWidget);
    expect(address(), '/week');
  });

  testWidgets('a mouse drags a card to another day and time, with Undo', (
    tester,
  ) async {
    final repo = await _pump(tester);
    final email = repo.rows.firstWhere(
      (o) => o.title == 'Reply to email' && o.startUtc!.day == 22,
    );
    final card = find.text('Reply to email').at(2); // Thu's
    // Friday's column, two hours lower than the card.
    final friday =
        tester.getCenter(find.text('Fri')) +
        Offset(
          0,
          tester.getCenter(card).dy -
              tester.getCenter(find.text('Fri')).dy +
              168,
        );
    final g = await tester.startGesture(
      tester.getCenter(card),
      kind: PointerDeviceKind.mouse,
    );
    await g.moveBy(const Offset(0, 20));
    await tester.pump();
    await g.moveTo(friday);
    await tester.pump();
    expect(find.textContaining('Fri · '), findsOneWidget);
    // The dragged copy lifts (ED-116).
    expect(
      find.byWidgetPredicate((w) => w is WeekCard && w.lifted),
      findsOneWidget,
    );
    await g.up();
    await tester.pumpAndSettle();
    final moved = repo.rows.singleWhere((o) => o.id == email.id);
    expect(moved.startUtc!.day, 23);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(
      repo.rows.singleWhere((o) => o.id == email.id).startUtc,
      email.startUtc,
    );
  });

  group('hover, focus and keys (ED-116)', () {
    Finder card(String title, int at) => find.ancestor(
      of: find.text(title).at(at),
      matching: find.byType(WeekCard),
    );
    Color fill(WidgetTester tester, Finder c) => tester
        .widget<Material>(
          find.descendant(of: c, matching: find.byType(Material)).first,
        )
        .color!;

    testWidgets('a pointer hover tints a movable block', (tester) async {
      await _pump(tester);
      // Lunch is pinned, so it doesn't drag: Reply to email does.
      final lunch = card('Reply to email', 2);
      final colors = DotTheme.of(tester.element(lunch)).colors;
      expect(fill(tester, lunch), colors.card, reason: 'flat at rest');
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(lunch));
      await tester.pumpAndSettle();
      expect(fill(tester, lunch), colors.sunk);
      await mouse.moveTo(Offset.zero);
      await tester.pumpAndSettle();
      expect(fill(tester, lunch), colors.card);
      await mouse.removePointer();
    });

    testWidgets('Alt+Down moves a focused block one snap step, Alt+Right a '
        'day, with Undo', (tester) async {
      final repo = await _pump(tester);
      final email = repo.rows.firstWhere(
        (o) => o.title == 'Reply to email' && o.startUtc!.day == 22,
      );
      Focus.of(
        tester.element(
          find.descendant(
            of: card('Reply to email', 2),
            matching: find.byType(GridBlockLines),
          ),
        ),
      ).requestFocus();
      await tester.pumpAndSettle();
      Future<void> alt(LogicalKeyboardKey key) async {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
        await tester.sendKeyEvent(key);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
        await tester.pumpAndSettle();
      }

      DateTime start() =>
          repo.rows.singleWhere((o) => o.id == email.id).startUtc!;
      await alt(LogicalKeyboardKey.arrowDown);
      // Settings' snap step: 5 min by default (R-05).
      expect(start(), email.startUtc!.add(const Duration(minutes: 5)));
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(start(), email.startUtc);
      // Same time, the day after.
      Focus.of(
        tester.element(
          find.descendant(
            of: card('Reply to email', 2),
            matching: find.byType(GridBlockLines),
          ),
        ),
      ).requestFocus();
      await tester.pumpAndSettle();
      await alt(LogicalKeyboardKey.arrowRight);
      expect(start(), email.startUtc!.add(const Duration(days: 1)));
    });

    testWidgets('the move actions are there for screen readers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester);
      final node = tester.getSemantics(card('Reply to email', 2));
      expect(
        node,
        isSemantics(
          customActions: const [
            CustomSemanticsAction(label: 'Move earlier'),
            CustomSemanticsAction(label: 'Move later'),
            CustomSemanticsAction(label: 'Move to the day before'),
            CustomSemanticsAction(label: 'Move to the day after'),
          ],
        ),
      );
      handle.dispose();
    });

    testWidgets('high contrast keeps an edge at rest', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(highContrast: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await _pump(tester);
      final shape =
          tester
                  .widget<Material>(
                    find
                        .descendant(
                          of: card('Lunch with Sam', 1),
                          matching: find.byType(Material),
                        )
                        .first,
                  )
                  .shape!
              as RoundedRectangleBorder;
      expect(shape.side, isNot(BorderSide.none));
    });
  });

  testWidgets('meets a11y guidelines in both themes', (tester) async {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await _pump(tester, mode: mode);
      await expectA11yGuidelines(tester);
    }
  });
}
