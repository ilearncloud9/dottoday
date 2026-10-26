import 'package:dottoday/shared/dot/week_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../support/sample_day.dart';
import '../../support/test_app.dart';

// The week strip never wraps a label (docs/10 §5.4): where "Wed" doesn't
// fit its column — a narrow phone at the largest text — all seven show
// the locale's one-letter weekday instead. No scaling down, no ellipsis.
void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    // Real Inter metrics: the test font draws every glyph a full em wide.
    await loadAppFonts();
  });

  Future<void> pump(
    WidgetTester tester, {
    required double width,
    required double scale,
    required TextDirection direction,
  }) async {
    tester.view
      ..physicalSize = Size(width, 400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      testApp(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: Directionality(
              textDirection: direction,
              child: Scaffold(
                body: WeekStrip(days: mainWeek, selected: 3, onSelect: (_) {}),
              ),
            ),
          ),
        ),
      ),
    );
  }

  for (final width in [320.0, 360.0, 375.0, 390.0, 700.0, 1280.0]) {
    for (final scale in [1.0, 1.5, 2.0]) {
      for (final direction in TextDirection.values) {
        testWidgets('no label wraps: $width px, ×$scale, ${direction.name}', (
          tester,
        ) async {
          await pump(tester, width: width, scale: scale, direction: direction);
          final labels = find.descendant(
            of: find.byType(WeekStrip),
            matching: find.byType(RichText),
          );
          expect(labels, findsNWidgets(14), reason: '7 weekdays + 7 dates');
          for (final e in labels.evaluate()) {
            final p = e.renderObject! as RenderParagraph;
            // One line: the text's own width fits the width it was given.
            expect(
              p.getMaxIntrinsicWidth(double.infinity),
              lessThanOrEqualTo(p.size.width + 0.01),
              reason: '"${p.text.toPlainText()}" wraps',
            );
          }
        });
      }
    }
  }

  testWidgets('390 px: "Wed" at 1.0, the narrow "W" at 2.0', (tester) async {
    await pump(tester, width: 390, scale: 1, direction: TextDirection.ltr);
    expect(find.text('Wed'), findsOneWidget);
    await pump(tester, width: 390, scale: 2, direction: TextDirection.ltr);
    expect(find.text('Wed'), findsNothing);
    expect(find.text('W'), findsOneWidget);
    expect(find.text('21'), findsOneWidget, reason: 'the date stays');
  });

  testWidgets('scrolls only when even the dates cannot fit; Wed in view', (
    tester,
  ) async {
    for (final (width, scrolls) in [(390.0, false), (375.0, true)]) {
      await pump(tester, width: width, scale: 2, direction: TextDirection.ltr);
      expect(
        find.byType(ScrollingWeek),
        scrolls ? findsOneWidget : findsNothing,
        reason: '$width px',
      );
    }
    await pump(tester, width: 320, scale: 2, direction: TextDirection.rtl);
    final wed = tester.getRect(find.text('W'));
    expect(wed.left, greaterThanOrEqualTo(0));
    expect(wed.right, lessThanOrEqualTo(320));
  });

  test("the narrow form is the locale's", () {
    final wed = DateTime(2026, 10, 21);
    expect(narrowWeekday(wed, 'en'), 'W');
    expect(narrowWeekday(wed, 'de'), 'M'); // Mittwoch
    expect(narrowWeekday(wed, 'es'), 'X'); // miércoles
    expect(narrowWeekday(wed, 'fr'), 'M'); // mercredi
  });
}
