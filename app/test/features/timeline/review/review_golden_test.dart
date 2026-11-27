// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'dart:async';

import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/now/wide/day_column.dart';
import 'package:dottoday/features/timeline/review/review_place.dart';
import 'package:dottoday/features/timeline/review/review_presenter.dart';
import 'package:dottoday/features/timeline/review/review_state.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/workspace/inspector/inspector_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/dot_golden.dart';
import '../../../support/timeline_fakes.dart';

// The one review (ED-099, ED-297): the phone sheet with the Week in
// review row (E-Phones-2), Week in review pushed in it, the Review place
// on the Mac and web (E-FullA-v2), Minimal's Day column (E-Minimal) and
// the tablet pane beside the day (E-R2-14).

final _day = DateTime(2026, 10, 21);
// 7:30 PM in Berlin: some of the day done, the rest to move.
final _now = DateTime.utc(2026, 10, 21, 17, 30);

List<Occurrence> _rows() {
  final rows = demoDayRows(_day);
  return [
    for (final (i, o) in rows.indexed)
      i < 2 ? o.copyWith(status: OccurrenceStatus.done) : o,
  ];
}

List<Override> _overrides() => timelineOverrides(
  now: _now,
  occurrences: FakeOccurrenceRepository(_rows()),
  profile: testProfile(
    // As the boards: unfinished rolls to tomorrow, a sleep target set.
    settings: const Settings(
      use24h: false,
      firstDayOfWeek: 1,
      rollUnfinished: true,
      sleepTargetMin: 480,
    ),
  ),
);

/// Keeps the profile and today alive, as Today does, under [child].
Widget _alive(Widget child) => Consumer(
  builder: (context, ref, _) {
    ref
      ..watch(currentProfileProvider)
      ..watch(todayDateProvider)
      ..watch(reviewDateProvider);
    return child;
  },
);

Widget _opener() => Scaffold(
  body: _alive(
    Builder(
      builder: (context) => Center(
        child: TextButton(
          onPressed: () => unawaited(showReviewSheet(context, day: _day)),
          child: const Text('open'), // l10n-ignore: test trigger
        ),
      ),
    ),
  ),
);

/// A frame with [beside] at its end and a trigger that opens the review
/// beside the day.
Widget _beside(Widget Function() beside) => Scaffold(
  body: _alive(
    Consumer(
      builder: (context, ref, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: TextButton(
                onPressed: () => ref
                    .read(reviewBesideProvider.notifier)
                    .show(ReviewOpen(_day, ReviewPage.day)),
                child: const Text('open'), // l10n-ignore: test trigger
              ),
            ),
          ),
          beside(),
        ],
      ),
    ),
  ),
);

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> _openWeek(WidgetTester tester) async {
  await _open(tester);
  await tester.tap(find.text('This week'));
  await tester.pumpAndSettle();
}

void main() {
  tz_data.initializeTimeZones();
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });
  goldenMatrix(
    'review_sheet',
    height: 900,
    widths: const {'compact', 'medium'},
    overrides: _overrides(),
    build: (_) => _opener(),
    act: _open,
  );
  goldenMatrix(
    'review_sheet_android',
    height: 900,
    widths: const {'compact'},
    platform: TargetPlatform.android,
    overrides: _overrides(),
    build: (_) => _opener(),
    act: _open,
  );
  goldenMatrix(
    'review_sheet_week',
    height: 1100,
    widths: const {'compact'},
    overrides: _overrides(),
    build: (_) => _opener(),
    act: _openWeek,
  );
  goldenMatrix(
    'review_place',
    height: 1100,
    widths: const {'expanded'},
    platform: TargetPlatform.macOS,
    overrides: _overrides(),
    build: (_) => Scaffold(body: _alive(const ReviewPlace())),
  );
  goldenMatrix(
    'review_column',
    height: 800,
    widths: const {'expanded'},
    platform: TargetPlatform.macOS,
    overrides: _overrides(),
    build: (_) => _beside(() => DayColumn(today: _day)),
    act: _open,
  );
  goldenMatrix(
    'review_pane',
    height: 900,
    widths: const {'expanded'},
    overrides: _overrides(),
    build: (_) => _beside(
      () => const Expanded(
        flex: 3,
        child: InspectorFrame(inspects: true, child: SizedBox.expand()),
      ),
    ),
    act: _open,
  );
}
