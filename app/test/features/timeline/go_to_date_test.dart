import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/features/timeline/widgets/go_to_date.dart';
import 'package:dottoday/shared/dot/month_cells.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';

/// Go to date (E-R2-36, ED-342; M19.5 part 5c): the approved month from
/// the date button, ⇧⌘T and the Day menu; a popover on the Mac, a dialog
/// on Android tablets, a sheet on phones; Page Up / Down change the
/// month, Esc closes.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  Future<GoRouter> pump(
    WidgetTester tester, {
    Size size = const Size(1280, 900),
    String at = '/today/2026-10-21',
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = buildRouter(appScreens);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      testRouterApp(
        router,
        overrides: [
          ...timelineOverrides(
            now: DateTime.utc(2026, 10, 21, 8),
            occurrences: FakeOccurrenceRepository(
              demoDayRows(DateTime(2026, 10, 21)),
            ),
          ),
          siriTipDueProvider.overrideWith((ref) => Stream.value(false)),
        ],
      ),
    );
    await tester.pumpAndSettle();
    router.go(at);
    await tester.pumpAndSettle();
    return router;
  }

  String where(GoRouter r) => r.routerDelegate.currentConfiguration.uri.path;

  // The toolbar lays out a copy per width and paints one.
  Finder dateButton() =>
      find.textContaining('Oct 21, 2026').hitTestable().first;

  void macTest(String name, WidgetTesterCallback body) => testWidgets(
    name,
    body,
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );

  macTest('the date button opens the month; a day goes there', (tester) async {
    final router = await pump(tester);
    await tester.tap(dateButton());
    await tester.pumpAndSettle();
    expect(find.byType(GoToDatePanel), findsOneWidget);
    expect(find.textContaining('days planned'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(GoToDatePanel),
        matching: find.text('25'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(GoToDatePanel), findsNothing);
    expect(where(router), contains('2026-10-25'));
  });

  macTest('the week on show is tinted, today ringed', (tester) async {
    await pump(tester, at: '/day/2026-10-23');
    await tester.tap(find.textContaining('Oct 23, 2026').hitTestable().first);
    await tester.pumpAndSettle();
    final cells = tester
        .widgetList<CompactMonthCell>(find.byType(CompactMonthCell))
        .toList();
    expect(cells.where((c) => c.day.tinted), hasLength(7));
    expect(cells.where((c) => c.day.ringed).single.day.date, '21');
  });

  macTest('⇧⌘T opens it; Page Down shows the next month; Esc closes', (
    tester,
  ) async {
    await pump(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pumpAndSettle();
    expect(find.byType(GoToDatePanel), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pumpAndSettle();
    expect(find.textContaining('Dec'), findsWidgets, reason: 'Oct · Nov · Dec');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(GoToDatePanel), findsNothing);
  });

  macTest('the Day menu has Go to date…', (tester) async {
    final menu = const MethodChannel('dottoday/context_menu');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          menu,
          (_) async => throw MissingPluginException(),
        );
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(menu, null),
    );
    await pump(tester);
    await tester.tap(find.byTooltip('More options').hitTestable().first);
    await tester.pumpAndSettle();
    // The Mac's title case (E-FullA-v2).
    await tester.tap(find.text('Go to Date…').last);
    await tester.pumpAndSettle();
    expect(find.byType(GoToDatePanel), findsOneWidget);
  });

  testWidgets('an Android tablet: in a dialog', (tester) async {
    await pump(tester);
    await tester.tap(dateButton());
    await tester.pumpAndSettle();
    expect(
      find.ancestor(
        of: find.byType(GoToDatePanel),
        matching: find.byType(Dialog),
      ),
      findsOneWidget,
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('a phone: ⌘⇧T opens it in a sheet', (tester) async {
    await pump(tester, size: const Size(390, 844));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pumpAndSettle();
    expect(
      find.ancestor(
        of: find.byType(GoToDatePanel),
        matching: find.byType(BottomSheet),
      ),
      findsOneWidget,
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  macTest('a11y holds in the popover', (tester) async {
    await pump(tester);
    await tester.tap(dateButton());
    await tester.pumpAndSettle();
    await expectA11yGuidelines(tester);
  });
}
