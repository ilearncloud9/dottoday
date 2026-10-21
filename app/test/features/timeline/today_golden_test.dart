// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';

/// Today at 09:22 in Berlin on the demo day (T1, `Main`).
Widget _today() => ProviderScope(
  overrides: timelineOverrides(
    now: DateTime.utc(2026, 10, 21, 7, 22),
    occurrences: FakeOccurrenceRepository(demoDayRows(DateTime(2026, 10, 21))),
    subtasks: FakeSubtaskRepository(demoDaySubtasks(DateTime(2026, 10, 21))),
    profile: testProfile(
      settings: const Settings(use24h: false, firstDayOfWeek: 7),
    ).copyWith(displayName: 'Kody'),
  ),
  child: const TodayScreen(),
);

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });
  goldenMatrix('today', height: 844, build: (_) => _today());
}
