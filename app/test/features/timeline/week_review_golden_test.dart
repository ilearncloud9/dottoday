// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/review/week_review.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/review/week_review_sheet.dart';
import 'package:dottoday/features/timeline/review/week_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';
import '../../support/week_review_fixtures.dart';

// The weekly review (docs/09 M12.1, `B-ios-week-review`): the sheet with
// Thursday's thread open, and the share image with titles off (the
// default) and on.

List<Override> _overrides() => timelineOverrides(
  now: reviewNow,
  occurrences: FakeOccurrenceRepository(weekReviewRows()),
  profile: testProfile(
    settings: const Settings(use24h: false, firstDayOfWeek: 7),
  ),
);

WeekReview _review() {
  final berlin = tz.getLocation('Europe/Berlin');
  final rows = weekReviewRows();
  return WeekReview.of([
    for (var i = 0; i < 7; i++)
      () {
        final date = DateTime(2026, 10, 18 + i);
        return WeekReviewDay(
          date: date,
          snapshot: DaySnapshot.ofDay(
            blocks: rows,
            shape: DayShape.on(berlin, date, Settings.defaultDayBoundary),
          ),
        );
      }(),
  ], berlin);
}

Widget _share({required bool titles}) => Padding(
  padding: const EdgeInsets.all(20),
  child: Align(
    alignment: Alignment.topCenter,
    child: WeekShareCard(
      review: _review(),
      range: 'Oct 18 – Oct 24',
      titles: titles,
      boundary: GlobalKey(),
    ),
  ),
);

void main() {
  tz_data.initializeTimeZones();
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });
  goldenMatrix(
    'week_review',
    height: 1000,
    overrides: _overrides(),
    build: (_) => Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: WeekReviewBody(today: DateTime(2026, 10, 25)),
          ),
        ),
      ),
    ),
    act: (tester) async {
      await tester.tap(find.text('5/7'));
      await tester.pumpAndSettle();
    },
  );
  goldenMatrix(
    'week_share_titles_off',
    height: 260,
    widths: const {'compact'},
    build: (_) => _share(titles: false),
  );
  goldenMatrix(
    'week_share_titles_on',
    height: 420,
    widths: const {'compact'},
    build: (_) => _share(titles: true),
  );
}
