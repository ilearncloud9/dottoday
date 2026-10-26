// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/energy_history.dart';
import '../../support/timeline_fakes.dart';

// Today's learning reveal (docs/13 §4.2–§4.3, §11): the day card's caption
// before the reality threshold (7 of 10), and the toggle's one-time
// highlight mid-hold at it. Light/dark, compact/expanded, 1×/2×, the
// largest text and RTL.

Widget _today(int runs) => ProviderScope(
  overrides: timelineOverrides(
    now: DateTime.utc(2026, 10, 21, 7, 22),
    occurrences: FakeOccurrenceRepository([
      ...demoDayRows(DateTime(2026, 10, 21)),
      ...energyHistory(count: runs),
    ]),
    subtasks: FakeSubtaskRepository(demoDaySubtasks(DateTime(2026, 10, 21))),
    profile: testProfile(
      settings: const Settings(use24h: false, firstDayOfWeek: 7),
    ).copyWith(displayName: 'Kody'),
  ),
  child: TodayScreen(date: DateTime(2026, 10, 21)),
);

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });

  goldenMatrix(
    'today_learning_caption',
    height: 844,
    widths: const {'compact', 'expanded'},
    a11yVariants: true,
    build: (_) => _today(7),
  );
  // Nothing advances the clock after the first frames, so the 2 s hold is
  // caught lit.
  goldenMatrix(
    'today_reality_highlight',
    height: 844,
    widths: const {'compact', 'expanded'},
    a11yVariants: true,
    build: (_) => _today(10),
  );
}
