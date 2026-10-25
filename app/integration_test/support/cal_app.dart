import 'dart:ui';

import 'package:dottoday/bootstrap.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/router/router_provider.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../pass_onboarding.dart';

/// Starts the app past onboarding and returns its provider container
/// (the calendar device checks, docs/08 §6.2 M7.7).
Future<ProviderContainer> startApp(WidgetTester tester) async {
  final flutterOnError = FlutterError.onError;
  final platformOnError = PlatformDispatcher.instance.onError;
  await bootstrap();
  FlutterError.onError = flutterOnError;
  PlatformDispatcher.instance.onError = platformOnError;
  await passOnboarding(tester);
  await waitFor(tester, find.byType(TodayScreen));
  return ProviderScope.containerOf(tester.element(find.byType(TodayScreen)));
}

/// Pumps until [finder] matches, else fails with what is on screen.
Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (tester.any(finder)) return;
  }
  final texts = [
    for (final e in find.byType(Text).evaluate()) (e.widget as Text).data,
  ];
  fail('timed out waiting for $finder; on screen: $texts');
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Waits for [finder], scrolls it into view and taps it.
Future<void> tapOn(WidgetTester tester, Finder finder) async {
  await waitFor(tester, finder);
  await tester.ensureVisible(finder.first);
  await settle(tester);
  await tester.tap(finder.first);
  await settle(tester);
}

/// Goes to [location] through the app's router, closing open sheets
/// first (they sit on the root navigator, above any route).
Future<void> go(
  WidgetTester tester,
  ProviderContainer container,
  String location,
) async {
  tester
      .state<NavigatorState>(find.byType(Navigator).first)
      .popUntil((route) => route.isFirst);
  await settle(tester);
  container.read(routerProvider).go(location);
  await settle(tester);
}

Future<void> goToday(WidgetTester tester, ProviderContainer c) =>
    go(tester, c, AppRoutes.today);

/// The day card in the middle of the screen (the pager keeps its
/// neighbours built).
Finder shownCard(WidgetTester tester) {
  final cards = find.byType(DayCard);
  final middle =
      tester.view.physicalSize.width / tester.view.devicePixelRatio / 2;
  final distances = [
    for (var i = 0; i < cards.evaluate().length; i++)
      (tester.getCenter(cards.at(i)).dx - middle).abs(),
  ];
  final best = distances.indexed.reduce((a, b) => a.$2 <= b.$2 ? a : b).$1;
  return cards.at(best);
}

/// Scrolls the shown card until [text] is built: down first (the card
/// opens at "now"), then up.
Future<Finder> scrollToOnCard(WidgetTester tester, String text) async {
  final card = shownCard(tester);
  final target = find.descendant(of: card, matching: find.text(text));
  final scrollable = find
      .descendant(of: card, matching: find.byType(Scrollable))
      .first;
  for (final delta in [200.0, -200.0]) {
    if (tester.any(target)) break;
    try {
      await tester.scrollUntilVisible(
        target,
        delta,
        scrollable: scrollable,
        maxScrolls: 80,
      );
    } on StateError {
      // That edge came first.
    }
  }
  expect(target, findsWidgets, reason: '$text on the shown day');
  return target;
}

/// Scrolls the editor (the scrollable holding its EDIT TASK caption)
/// until [finder] is built: it builds its lower rows lazily.
Future<void> scrollToInEditor(WidgetTester tester, Finder finder) async {
  await waitFor(tester, find.text('EDIT TASK'));
  await settle(tester);
  if (tester.any(finder)) return;
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find
        .ancestor(of: find.text('EDIT TASK'), matching: find.byType(Scrollable))
        .first,
    maxScrolls: 40,
  );
}
