import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/features/timeline/calendar/calendar_day_card.dart';
import 'package:dottoday/features/timeline/calendar/calendar_page.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/a11y.dart';
import 'calendar_world.dart';

/// The Calendar tab (docs/09 M20.1; E-Phones Calendar, ED-075, ED-079;
/// tablets at medium width E-R2-12, ED-293).
void main() {
  setUpAll(tz_data.initializeTimeZones);

  const phone = Size(390, 844);
  const tablet = Size(820, 1180);
  final ios = TargetPlatformVariant.only(TargetPlatform.iOS);

  String at(GoRouter r) => r.routerDelegate.currentConfiguration.uri.path;

  Finder card(String text) => find.descendant(
    of: find.byType(CalendarDayCard),
    matching: find.textContaining(text),
  );

  testWidgets('the phone tab bar has Calendar, which opens Month', (
    tester,
  ) async {
    final router = await pumpCalendar(tester, size: phone);
    router.go(AppRoutes.today);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calendar').hitTestable().last);
    await tester.pumpAndSettle();
    expect(at(router), AppRoutes.month);
    expect(find.byType(CalendarPage), findsOneWidget);
    // Today is picked: its card, with the day's numbers.
    expect(card('Today'), findsOneWidget);
    expect(card('3 of 9 done'), findsOneWidget);
  }, variant: ios);

  testWidgets('a tapped day shows below; Open day opens it', (tester) async {
    final router = await pumpCalendar(tester, size: phone);
    await tester.tap(find.bySemanticsLabel(RegExp('^Thursday, November 5')));
    await tester.pumpAndSettle();
    expect(card('Haircut'), findsOneWidget);
    await tester.tap(find.text('Open day'));
    await tester.pumpAndSettle();
    expect(at(router), AppRoutes.day(DateTime(2026, 11, 5)));
  }, variant: ios);

  testWidgets('swipe, ‹ › and Today change the month', (tester) async {
    final router = await pumpCalendar(tester, size: phone);
    await tester.fling(
      find.bySemanticsLabel(RegExp('^Wednesday, November 18')),
      const Offset(-300, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(at(router), AppRoutes.monthOf(DateTime(2026, 12)));
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(at(router), AppRoutes.monthOf(DateTime(2026, 10)));
    await tester.tap(find.widgetWithText(TextButton, 'Today'));
    await tester.pumpAndSettle();
    expect(at(router), AppRoutes.month);
  }, variant: ios);

  testWidgets('a phone has no Week: /week opens the month', (tester) async {
    final router = await pumpCalendar(tester, size: phone);
    router.go(AppRoutes.weekOf(DateTime(2026, 12, 9)));
    await tester.pumpAndSettle();
    expect(at(router), AppRoutes.monthOf(DateTime(2026, 12)));
  }, variant: ios);

  testWidgets('medium width: Month · Week switches both ways', (tester) async {
    final router = await pumpCalendar(tester, size: tablet);
    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();
    expect(at(router), AppRoutes.weekOf(DateTime(2026, 11, 3)));
    expect(find.text('This week'), findsOneWidget);
    await tester.tap(find.text('Month'));
    await tester.pumpAndSettle();
    expect(at(router), AppRoutes.month);
  }, variant: ios);

  testWidgets('Open day on today opens Today', (tester) async {
    final router = await pumpCalendar(tester, size: phone);
    await tester.tap(find.text('Open day'));
    await tester.pumpAndSettle();
    expect(at(router), AppRoutes.today);
    expect(find.byType(TodayScreen), findsOneWidget);
  }, variant: ios);

  for (final (name, size, platform) in [
    ('iPhone', phone, TargetPlatform.iOS),
    ('Android', const Size(412, 892), TargetPlatform.android),
    ('iPad', tablet, TargetPlatform.iOS),
  ]) {
    testWidgets('meets a11y guidelines on $name (R-12)', (tester) async {
      await pumpCalendar(tester, size: size);
      await expectA11yGuidelines(tester);
    }, variant: TargetPlatformVariant.only(platform));

    testWidgets('200 % text on $name: nothing overflows', (tester) async {
      await pumpCalendar(tester, size: size, text: 2);
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant.only(platform));
  }
}
