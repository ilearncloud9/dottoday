// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/state/reality_thread.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/reality_fixtures.dart';
import '../../support/timeline_fakes.dart';

// The Reality thread (docs/09 M11.2, `B-ios-reality-thread`): the plan's
// ghost lane beside what really happened. The milestone's gate golden.

final class _On extends RealityMode {
  _On(this.on);

  final bool on;

  @override
  bool build() => on;
}

Widget _today({bool reality = true, DateTime? date, DateTime? now}) {
  final day = date ?? DateTime(2026, 10, 21);
  return ProviderScope(
    overrides: [
      realityModeProvider.overrideWith(() => _On(reality)),
      ...timelineOverrides(
        now: now ?? DateTime.utc(2026, 10, 21, 7, 22),
        occurrences: FakeOccurrenceRepository(realityDayRows(day)),
        subtasks: FakeSubtaskRepository(demoDaySubtasks(day)),
        profile: testProfile(
          settings: const Settings(use24h: false, firstDayOfWeek: 7),
        ).copyWith(displayName: 'Kody'),
      ),
    ],
    child: TodayScreen(date: date),
  );
}

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });
  goldenMatrix(
    'reality_thread',
    height: 1100,
    widths: const {'compact', 'medium'},
    build: (_) => _today(),
  );
  // Mac/web: the spread's today card.
  goldenMatrix(
    'reality_spread',
    height: 900,
    widths: const {'expanded'},
    build: (_) => _today(),
  );
  // The toggle on the plan, before Reality is picked.
  goldenMatrix(
    'reality_plan',
    height: 600,
    widths: const {'compact'},
    build: (_) => _today(reality: false),
  );
  // Sun 25 Oct 2026, the day Berlin falls back an hour, at 09:22 CET.
  goldenMatrix(
    'reality_dst',
    height: 1100,
    widths: const {'compact'},
    build: (_) => _today(
      date: DateTime(2026, 10, 25),
      now: DateTime.utc(2026, 10, 25, 8, 22),
    ),
  );
}
