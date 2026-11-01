// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';

// The Running late sheet, the Day review at Wind Down and the running-late
// nudge on Today (derived, docs/09 M3f.5; docs/10 §5.3).

/// Today on the demo day, the clock at [now].
List<Override> _at(
  DateTime now, {
  Settings settings = const Settings(use24h: false, firstDayOfWeek: 7),
}) => timelineOverrides(
  now: now,
  learningMeta: captionPutAway(DateTime(now.year, now.month, now.day)),
  minuteTicks: Stream.value(now),
  occurrences: FakeOccurrenceRepository(demoDayRows(DateTime(2026, 10, 21))),
  profile: testProfile(settings: settings).copyWith(displayName: 'Kody'),
);

Widget _today(GoldenCell _) => const TodayScreen();

/// The spread's own button, else the ⋯ menu's item.
Future<void> _openLate(WidgetTester tester) async {
  final button = find.widgetWithText(OutlinedButton, 'Running late');
  if (button.evaluate().isNotEmpty) {
    await tester.tap(button);
  } else {
    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Running late…'));
  }
}

void main() {
  // The overrides below are built as the tests are declared.
  tz_data.initializeTimeZones();
  setUpAll(loadAppFonts);
  const widths = {'compact', 'expanded'};
  goldenMatrix(
    'today_running_late',
    height: 900,
    widths: widths,
    act: _openLate,
    overrides: _at(DateTime.utc(2026, 10, 21, 7, 22)),
    build: _today,
  );
  // 23:30 in Berlin, after Wind Down.
  goldenMatrix(
    'today_day_review',
    height: 900,
    widths: widths,
    overrides: _at(DateTime.utc(2026, 10, 21, 21, 30)),
    build: _today,
  );
  // Missions on (M17.7c): "Tomorrow matters" switched on, and tomorrow
  // has nothing to pick from, so Breathe will be used instead.
  goldenMatrix(
    'today_day_review_tomorrow_matters',
    height: 1000,
    widths: const {'compact'},
    overrides: _at(
      DateTime.utc(2026, 10, 21, 21, 30),
      settings: const Settings(
        use24h: false,
        firstDayOfWeek: 7,
        missionMode: MissionMode.whenAsked,
        missionKind: MissionKind.oneThing,
        missionFlagDate: '2026-10-22',
      ),
    ),
    build: _today,
  );
  // 11:45: Design review ended 30 min ago unticked.
  goldenMatrix(
    'today_late_nudge',
    height: 900,
    widths: widths,
    overrides: _at(DateTime.utc(2026, 10, 21, 9, 45)),
    build: _today,
  );
}
