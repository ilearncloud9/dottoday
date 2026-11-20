import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/shared/navigation/dot_sidebar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../support/a11y.dart';
import '../support/test_app.dart';
import '../support/timeline_fakes.dart';

/// Minimal's places by width (ED-068, ED-266, ED-207; M19.6 part 6a):
/// Now · Today · Inbox on phones; Now · Inbox · Calendar · Search wider,
/// the sidebar 200 on Mac and web; ⌘1–4 to Now · Inbox · Calendar ·
/// Search. Full keeps its own.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  Future<GoRouter> pump(
    WidgetTester tester,
    Size size, {
    UiLayout layout = UiLayout.minimal,
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
        overrides: timelineOverrides(
          now: DateTime.utc(2026, 10, 21, 8),
          occurrences: FakeOccurrenceRepository(
            demoDayRows(DateTime(2026, 10, 21)),
          ),
          profile: testProfile(
            settings: Settings(uiLayout: layout, use24h: false),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  String where(GoRouter r) => r.routerDelegate.currentConfiguration.uri.path;

  // A place by its name (the Inbox with its count: "Inbox, 2 tasks").
  bool shows(String place) => find
      .bySemanticsLabel(RegExp('^$place(, .* tasks?)?\$'))
      .evaluate()
      .isNotEmpty;

  testWidgets('an iPhone: Now · Today · Inbox, Now first', (tester) async {
    final router = await pump(tester, const Size(390, 844));
    for (final p in ['Now', 'Today', 'Inbox']) {
      expect(shows(p), isTrue, reason: p);
    }
    expect(shows('Calendar'), isFalse);
    expect(shows('Search'), isFalse);
    final now = tester.getCenter(find.bySemanticsLabel('Now').last);
    final today = tester.getCenter(find.bySemanticsLabel('Today').last);
    expect(now.dx, lessThan(today.dx), reason: 'Now leads');
    await tester.tap(find.bySemanticsLabel('Now').last);
    await tester.pumpAndSettle();
    expect(where(router), '/now');
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('an Android tablet at medium: Now · Inbox · Calendar · Search', (
    tester,
  ) async {
    final router = await pump(tester, const Size(800, 1280));
    for (final p in ['Now', 'Inbox', 'Calendar', 'Search']) {
      expect(shows(p), isTrue, reason: p);
    }
    expect(find.bySemanticsLabel('Today'), findsNothing, reason: 'not a place');
    await tester.tap(find.bySemanticsLabel('Calendar').last);
    await tester.pumpAndSettle();
    expect(where(router), '/calendar');
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('the Mac: the sidebar is 200; ⌘1 Now, ⌘3 Calendar, ⌘4 Search', (
    tester,
  ) async {
    final router = await pump(tester, const Size(1280, 800));
    expect(
      tester.getSize(find.byType(DotSidebar)).width,
      DotSize.sidebarMinimal,
    );
    Future<void> cmd(LogicalKeyboardKey key) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(key);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await tester.pumpAndSettle();
    }

    await cmd(LogicalKeyboardKey.digit3);
    expect(where(router), '/calendar');
    await cmd(LogicalKeyboardKey.digit4);
    expect(where(router), '/search');
    await cmd(LogicalKeyboardKey.digit1);
    expect(where(router), '/now');
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('Full keeps its places', (tester) async {
    await pump(tester, const Size(390, 844), layout: UiLayout.full);
    expect(shows('Now'), isFalse);
    expect(shows('Today'), isTrue);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  for (final p in [TargetPlatform.iOS, TargetPlatform.android]) {
    testWidgets('a11y holds on a ${p.name} phone', (tester) async {
      await pump(tester, const Size(390, 844));
      await expectA11yGuidelines(tester);
    }, variant: TargetPlatformVariant.only(p));
  }
}
