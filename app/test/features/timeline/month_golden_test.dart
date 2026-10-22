// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/month_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';

/// M1 at 09:22 in Berlin with the demo week (`A-mac-month`, M3e.4).
void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });
  goldenMatrix(
    'month',
    height: 1100,
    widths: const {'expanded', 'expanded_min'},
    build: (_) => ProviderScope(
      overrides: timelineOverrides(
        now: DateTime.utc(2026, 10, 21, 7, 22),
        occurrences: FakeOccurrenceRepository(demoWeekRows()),
        profile: testProfile(
          settings: const Settings(use24h: false, firstDayOfWeek: 7),
        ),
      ),
      child: const MonthScreen(),
    ),
  );
}
