// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';

/// Three tasks overlapping (E-R2-27 §1, ED-330): the demo day's Deep work
/// (9–11) and Design review (10:30–11:15), and Quick sync (10:45–11:15):
/// a chain of pairwise knots, nothing compacted.
void main() {
  setUpAll(tz_data.initializeTimeZones);
  setUpAll(loadAppFonts);
  final day = DateTime(2026, 10, 21);
  goldenMatrix(
    'today_overlap_chain',
    height: 900,
    widths: const {'compact'},
    build: (_) => ProviderScope(
      overrides: timelineOverrides(
        now: DateTime.utc(2026, 10, 21, 7, 22),
        learningMeta: captionPutAway(day),
        occurrences: FakeOccurrenceRepository([
          ...demoDayRows(day),
          occurrenceFixture().copyWith(
            id: 'quick sync', // l10n-ignore: fixture id
            title: 'Quick sync', // l10n-ignore: fixture data
            colorKey: 'violet',
            iconKey: 'call',
            startUtc: DateTime.utc(2026, 10, 21, 8, 45),
            tzId: 'Europe/Berlin',
            durationMin: 30,
          ),
        ]),
        profile: testProfile(
          settings: const Settings(use24h: false, firstDayOfWeek: 7),
        ),
      ),
      child: const TodayScreen(),
    ),
  );
}
