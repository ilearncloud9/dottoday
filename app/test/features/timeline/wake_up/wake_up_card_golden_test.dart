// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/wake_up/wake_up_day.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_screen.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/dot_golden.dart';
import '../../../support/reveal_hint_fakes.dart';
import '../../../support/timeline_fakes.dart';
import '../../../support/today_harness.dart';
import 'wake_up_harness.dart';

// The Wake Up card (derived — docs/15 §5, §10; no reference render): the
// day with the late-start line, minimal mode, low energy and an empty day,
// each after its coach marks have had their showings; then the first
// morning, with Start the day's coach mark (docs/15 §11).

List<Override> _overrides({
  Settings settings = wakeUpOn,
  List<Occurrence>? rows,
  bool firstMorning = false,
}) => timelineOverrides(
  now: todayTestNow,
  occurrences: FakeOccurrenceRepository(rows ?? demoDayRows(todayTestDate)),
  profile: testProfile(settings: settings),
  // The harness has every coach mark spent; the first morning has none.
  revealHints: firstMorning ? FakeRevealHintRepository() : null,
  wakeUpDays: FakeWakeUpDayRepository([
    // Up at 07:25 in Berlin, Wake Up 07:00.
    WakeUpDay(
      date: '2026-10-21',
      stoppedAtUtc: DateTime.utc(2026, 10, 21, 5, 25),
    ),
  ]),
);

void main() {
  // The demo day is built while the matrix is declared.
  tz_data.initializeTimeZones();
  setUpAll(loadAppFonts);
  goldenMatrix(
    'wake_up_card',
    height: 1000,
    a11yVariants: true,
    overrides: _overrides(),
    build: (_) => const WakeUpCardScreen(),
  );
  goldenMatrix(
    'wake_up_card_minimal',
    height: 800,
    widths: const {'compact'},
    overrides: _overrides(
      settings: wakeUpOn.copyWith(uiLayout: UiLayout.minimal),
    ),
    build: (_) => const WakeUpCardScreen(),
  );
  goldenMatrix(
    'wake_up_card_low_energy',
    height: 700,
    widths: const {'compact'},
    overrides: _overrides(
      settings: wakeUpOn.copyWith(
        lowEnergyUntil: DateTime.utc(2026, 10, 21, 22),
      ),
    ),
    build: (_) => const WakeUpCardScreen(),
  );
  goldenMatrix(
    'wake_up_card_first_morning',
    height: 1000,
    widths: const {'compact'},
    overrides: _overrides(firstMorning: true),
    build: (_) => const WakeUpCardScreen(),
  );
  goldenMatrix(
    'wake_up_card_empty',
    height: 600,
    widths: const {'compact'},
    overrides: _overrides(rows: const []),
    build: (_) => const WakeUpCardScreen(),
  );
}
