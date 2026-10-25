// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/journal_fixtures.dart';
import '../../support/timeline_fakes.dart';
import '../../support/week_review_fixtures.dart';

// Search › Past days (docs/09 M12.3, derived — 11 §D3): the list, a
// search, and the year strip sheet.

List<Override> _overrides() => timelineOverrides(
  now: reviewNow,
  occurrences: FakeOccurrenceRepository(journalRows()),
  profile: testProfile(
    settings: const Settings(use24h: false, firstDayOfWeek: 7),
  ),
);

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Past days'));
  await tester.pumpAndSettle();
}

void main() {
  tz_data.initializeTimeZones();
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });
  goldenMatrix(
    'past_days',
    height: 900,
    overrides: _overrides(),
    build: (_) => const SearchScreen(),
    act: _open,
  );
  goldenMatrix(
    'past_days_search',
    height: 900,
    widths: const {'compact'},
    overrides: _overrides(),
    build: (_) => const SearchScreen(),
    act: (tester) async {
      await _open(tester);
      await tester.enterText(find.byType(TextField), 'run');
    },
  );
  goldenMatrix(
    'year_strip',
    height: 700,
    widths: const {'compact', 'expanded'},
    overrides: _overrides(),
    build: (_) => const SearchScreen(),
    act: (tester) async {
      await _open(tester);
      await tester.tap(find.text('Year strip'));
    },
  );
}
