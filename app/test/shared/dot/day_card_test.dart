import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/sample_day.dart';

// DayCard in a short slot (docs/09 M4.9: a small phone with a prompt
// above Today overflowed it): the header scrolls with the thread.

Future<void> _pump(WidgetTester tester, double height) => tester.pumpWidget(
  MaterialApp(
    theme: DotTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SizedBox(
        height: height,
        child: const DayCard(
          title: 'Wednesday', // l10n-ignore: test fixture
          isToday: true,
          summary: DaySummary(
            done: 2,
            total: 7,
            plannedMinutes: 345,
            freeMinutes: 300,
          ),
          entries: mainThread,
        ),
      ),
    ),
  ),
);

void main() {
  for (final height in [40.0, 90.0, 159.0, 400.0]) {
    testWidgets('no overflow at $height px', (tester) async {
      await _pump(tester, height);
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(
        find.textContaining('Wednesday', findRichText: true),
        findsOneWidget,
      );
    });
  }
}
