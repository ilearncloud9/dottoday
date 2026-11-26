// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/data/onboarding/first_today_store.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';
import '../../support/youre_in_rows.dart';

// You're in (M20.11 part 5, ED-490): the first Today after onboarding,
// with "Tap the circle when it's done" at Read's circle and "Sign in to
// sync" at the foot. 9:22 in Berlin; the prototype's 12-hour clock.

void main() {
  tz_data.initializeTimeZones();
  setUpAll(loadAppFonts);
  goldenMatrix(
    'today_youre_in',
    height: 844,
    widths: const {'compact', 'expanded'},
    a11yVariants: true,
    overrides: timelineOverrides(
      now: DateTime.utc(2026, 10, 21, 7, 22),
      occurrences: FakeOccurrenceRepository(youreInRows()),
      profile: testProfile(
        settings: Settings(
          use24h: false,
          firstDayOfWeek: 7,
          dayBoundaries: {
            for (final d in Weekday.values)
              d: const TimeWindow(start: '07:00', end: '23:00'),
          },
        ),
      ).copyWith(displayName: 'Kody'),
      firstToday: const FirstTodayState(hint: true, sync: true),
    ),
    // The hint rises at 1.1 s, the card at 1.6 s.
    act: (tester) => tester.pump(const Duration(seconds: 3)),
    build: (_) => const TodayScreen(),
  );
}
