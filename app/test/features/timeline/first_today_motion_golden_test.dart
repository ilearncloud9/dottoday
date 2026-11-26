// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/data/onboarding/first_today_store.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:dottoday/features/onboarding/flow/onb_keys.dart';
import 'package:dottoday/features/timeline/first_today/first_today_rise.dart';
import 'package:dottoday/shared/dot/done_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/onboarding_harness.dart';
import '../../support/today_harness.dart';
import '../../support/youre_in_rows.dart';

// You're in, frame by frame (M20.11 part 5, ED-490): the first Today's
// rows rising, a task marked done with its burst, and on a wide window
// the card leaving as the blur clears.

final _day = Settings(
  use24h: false,
  firstDayOfWeek: 7,
  dayBoundaries: {
    for (final d in Weekday.values)
      d: const TimeWindow(start: '07:00', end: '23:00'),
  },
);

Future<void> _frames(WidgetTester tester, String name, List<int> at) async {
  var now = 0;
  for (final ms in at) {
    await tester.pump(Duration(milliseconds: ms - now));
    now = ms;
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/${name}_${ms}ms.png'),
    );
  }
}

void main() {
  tz_data.initializeTimeZones();
  setUpAll(loadAppFonts);

  testWidgets('the first Today: rows rise in turn, then the hint', (
    tester,
  ) async {
    await pumpToday(
      tester,
      rows: youreInRows(),
      settings: _day,
      firstToday: const FirstTodayState(rise: true, hint: true, sync: true),
      settle: false,
    );
    // From when the day's rows are first drawn (the data loads first).
    for (var i = 0; i < 100 && !tester.any(find.byType(FirstTodayRise)); i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await _frames(tester, 'youre_in_rise', [150, 400, 700, 1000, 1400, 2200]);
    await tester.pumpAndSettle();
  });

  testWidgets('marking done: the circle fills and the ring fades out', (
    tester,
  ) async {
    await pumpToday(tester, rows: youreInRows(), settings: _day);
    await tester.tap(find.byType(DoneCircle).first);
    await tester.pump();
    await _frames(tester, 'youre_in_done', [60, 160, 300, 500]);
    await tester.pumpAndSettle();
  });

  testWidgets('a wide window: the card leaves as the blur clears', (
    tester,
  ) async {
    await pumpOnboarding(
      tester,
      size: const Size(1280, 830),
      progress: const OnboardingProgress(step: OnboardingStep.nudge),
    );
    await tester.tap(find.text('Not now'));
    await tester.pump();
    await _frames(tester, 'youre_in_card', [100, 250, 450, 700]);
    await tester.pumpAndSettle();
    expect(find.byKey(OnbKeys.card), findsNothing);
  });
}
