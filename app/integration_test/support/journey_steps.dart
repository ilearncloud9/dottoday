import 'package:dottoday/shared/dot/day_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps until [finder] matches, or fails listing what is on screen.
Future<void> until(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(minutes: 3),
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

/// A few frames for animations to settle (pumpAndSettle never settles
/// while the now-marker ticks).
Future<void> rest(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Waits for [finder], brings it on screen and taps it.
Future<void> tapOn(WidgetTester tester, Finder finder) async {
  await until(tester, finder);
  await tester.ensureVisible(finder.first);
  await rest(tester);
  await tester.tap(finder.first);
  await rest(tester);
}

/// Scrolls [scrollable] until [finder] is built: up first (the card opens
/// at "now"), then down (it may sit at the top of the day).
Future<void> scrollTo(
  WidgetTester tester,
  Finder finder,
  Finder scrollable,
) async {
  for (final delta in [-200.0, 200.0]) {
    if (tester.any(finder)) break;
    try {
      await tester.scrollUntilVisible(
        finder,
        delta,
        scrollable: scrollable,
        maxScrolls: 60,
      );
    } on StateError {
      // Not that way: the edge was reached first.
    }
  }
  expect(finder, findsWidgets);
}

/// The day card shown now: the spread's raised card (its neighbours are
/// side days), or on the pager the card nearest the middle of the screen
/// (neighbours stay built either side).
Finder shownCard(WidgetTester tester) {
  final raised = find.byWidgetPredicate((w) => w is DayCard && w.side == null);
  final count = raised.evaluate().length;
  final middle =
      tester.view.physicalSize.width / tester.view.devicePixelRatio / 2;
  return raised.at(
    [
      for (var i = 0; i < count; i++)
        (tester.getCenter(raised.at(i)).dx - middle).abs(),
    ].indexed.reduce((a, b) => a.$2 <= b.$2 ? a : b).$1,
  );
}

/// The centre of the first "… free" gap below [from] on [card], else a
/// little further down: which gap labels show depends on the time of day
/// ("45 min free · add here" only while ahead; found at 08:10, M5.10).
Offset gapBelow(WidgetTester tester, Finder card, Offset from) {
  final gaps = find.descendant(
    of: card,
    matching: find.textContaining(' free'),
  );
  final below = [
    for (var i = 0; i < gaps.evaluate().length; i++)
      tester.getCenter(gaps.at(i)),
  ].where((c) => c.dy > from.dy + 10).toList();
  return below.isEmpty
      ? from + const Offset(0, 120)
      : below.reduce((a, b) => a.dy < b.dy ? a : b);
}
