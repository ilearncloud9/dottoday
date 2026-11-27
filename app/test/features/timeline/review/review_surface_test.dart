import 'dart:async';

import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/timeline/now/wide/day_column.dart';
import 'package:dottoday/features/timeline/review/review_panel.dart';
import 'package:dottoday/features/timeline/review/review_place.dart';
import 'package:dottoday/features/timeline/review/review_presenter.dart';
import 'package:dottoday/features/timeline/review/review_state.dart';
import 'package:dottoday/features/timeline/workspace/inspector/inspector_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../calendar/calendar_world.dart';

// The one review, one surface per layout (ED-099 Q1, ED-297): the sheet
// with Week in review pushed in it on phones, the Review place in Full on
// the Mac and web, the pane beside the day on tablets, Minimal's Day
// column; `/review` lands on each.

const _phone = Size(390, 900);
const _wide = Size(1400, 900);

String _path(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.path;

Future<void> _open(WidgetTester tester, {ReviewPage? page}) async {
  final context = tester.element(find.byType(Scaffold).hitTestable().first);
  final today = DateTime(2026, 11, 3);
  unawaited(openReview(context, day: today, page: page ?? ReviewPage.day));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('phones: a sheet; Week in review pushes, Back returns', (
    tester,
  ) async {
    final router = await pumpCalendar(tester, size: _phone);
    router.go(AppRoutes.today);
    await tester.pumpAndSettle();
    await _open(tester);
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Day review'), findsWidgets);
    await tester.tap(find.text('This week'));
    await tester.pumpAndSettle();
    expect(find.text('No streaks here — just what happened.'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('This week'), findsOneWidget);
    expect(find.textContaining('done so far'), findsOneWidget);
  });

  testWidgets('Minimal phones: no Week in review row', (tester) async {
    final router = await pumpCalendar(
      tester,
      size: _phone,
      layout: UiLayout.minimal,
    );
    router.go(AppRoutes.today);
    await tester.pumpAndSettle();
    await _open(tester);
    expect(find.byType(ReviewPanel), findsOneWidget);
    expect(find.textContaining('done so far'), findsNothing);
  });

  testWidgets('/review on a phone hands over to Today with the sheet', (
    tester,
  ) async {
    final router = await pumpCalendar(tester, size: _phone);
    router.go(AppRoutes.review);
    await tester.pumpAndSettle();
    expect(_path(router), AppRoutes.today);
    expect(find.byType(ReviewPanel), findsOneWidget);
  });

  testWidgets('Mac: the Review place, both halves, stepped with ‹ ›', (
    tester,
  ) async {
    final router = await pumpCalendar(tester, size: _wide);
    router.go(AppRoutes.today);
    await tester.pumpAndSettle();
    await _open(tester);
    expect(_path(router), AppRoutes.review);
    expect(find.byType(ReviewPlace), findsOneWidget);
    expect(find.text('Day review'), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);
    // The review's own day is the latest: › waits, ‹ steps back.
    final next = find.ancestor(
      of: find.byTooltip('Next day'),
      matching: find.byType(IconButton),
    );
    expect(tester.widget<IconButton>(next).onPressed, isNull);
    final before = find.textContaining('Nov 3');
    expect(before, findsWidgets);
    await tester.tap(find.byTooltip('Previous day'));
    await tester.pumpAndSettle();
    expect(find.text('Mon, Nov 2'), findsOneWidget);
    expect(tester.widget<IconButton>(next).onPressed, isNotNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('iPad: the pane beside the day; Esc puts it away', (
    tester,
  ) async {
    final router = await pumpCalendar(tester, size: _wide);
    router.go(AppRoutes.today);
    await tester.pumpAndSettle();
    await _open(tester, page: ReviewPage.week);
    expect(_path(router), isNot(AppRoutes.review));
    expect(
      find.descendant(
        of: find.byType(InspectorFrame),
        matching: find.byType(ReviewPanel),
      ),
      findsOneWidget,
    );
    expect(find.text('This week'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(ReviewPanel), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('Minimal Mac: in the Day column, no Week in review', (
    tester,
  ) async {
    final router = await pumpCalendar(
      tester,
      size: _wide,
      layout: UiLayout.minimal,
    );
    router.go(AppRoutes.inbox);
    await tester.pumpAndSettle();
    await _open(tester);
    expect(_path(router), AppRoutes.now);
    expect(
      find.descendant(
        of: find.byType(DayColumn),
        matching: find.byType(ReviewPanel),
      ),
      findsOneWidget,
    );
    expect(find.text('Day review · Tue, Nov 3'), findsOneWidget);
    expect(find.textContaining('done so far'), findsNothing);
    await tester.tap(
      find.descendant(
        of: find.byType(ReviewPanel),
        matching: find.byTooltip('Close'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ReviewPanel), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
}
