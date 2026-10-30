import 'dart:async';

import 'package:dottoday/domain/entities/settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/today_harness.dart';

// Low-energy mode on Today (docs/09 M12.2, 11 D2): Today's ⋯ turns it on
// (until the next Wake Up), Today collapses to the next dot with no strip,
// and at Wake Up it turns itself off.

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets("Today's ⋯ turns it on until tomorrow's Wake Up", (tester) async {
    await pumpToday(tester);
    expect(
      find.textContaining('October 21, 2026', findRichText: true),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Low-energy mode'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Take it easy, Kody', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Wed, Oct 21 · Low-energy'), findsOneWidget);
    expect(find.text('Low-energy · on'), findsOneWidget);
    final nudges = find.text("Nudges are off until tomorrow's Wake Up");
    await tester.scrollUntilVisible(nudges, 200);
    expect(nudges, findsOneWidget);
  });

  testWidgets('it turns itself off at the next Wake Up', (tester) async {
    final ticks = StreamController<DateTime>();
    addTearDown(ticks.close);
    // Wake Up tomorrow: 07:00 in Berlin = 05:00 UTC.
    final wake = DateTime.utc(2026, 10, 22, 5);
    await pumpToday(
      tester,
      settings: Settings(
        use24h: false,
        firstDayOfWeek: 7,
        lowEnergyUntil: wake,
      ),
      ticks: ticks.stream,
    );
    ticks.add(todayTestNow);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Take it easy, Kody', findRichText: true),
      findsOneWidget,
    );
    ticks.add(wake);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Take it easy, Kody', findRichText: true),
      findsNothing,
    );
    // Past Wake Up it is the next day.
    expect(
      find.textContaining('October 22, 2026', findRichText: true),
      findsOneWidget,
    );
  });
}
