// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/proposals/proposal_host.dart';
import 'package:dottoday/features/routines/routines_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/routine_samples.dart';
import '../../support/timeline_fakes.dart';

// Routines (docs/09 M11.4, `B-ios-routines`): the page, the editor
// (derived) and a drop's proposal, on the demo day at 9:22 in Berlin.

List<Override> _overrides() => timelineOverrides(
  now: DateTime.utc(2026, 10, 21, 7, 22),
  occurrences: FakeOccurrenceRepository(demoDayRows(DateTime(2026, 10, 21))),
  profile: testProfile(
    settings: const Settings(use24h: false, firstDayOfWeek: 7),
  ).copyWith(displayName: 'Kody'),
  routines: sampleRoutines(),
);

Widget _page() => const ProposalHost(child: RoutinesPage());

void main() {
  // The overrides below are built while the tests are declared.
  tz_data.initializeTimeZones();
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });
  goldenMatrix(
    'routines',
    height: 1200,
    overrides: _overrides(),
    build: (_) => _page(),
  );
  goldenMatrix(
    'routines_empty',
    height: 600,
    widths: const {'compact'},
    overrides: timelineOverrides(now: DateTime.utc(2026, 10, 21, 7, 22)),
    build: (_) => _page(),
  );
  // The editor (derived): a sheet on phones, a dialog when wide.
  goldenMatrix(
    'routine_editor',
    height: 1100,
    widths: const {'compact', 'expanded'},
    overrides: _overrides(),
    build: (_) => _page(),
    act: (tester) async {
      await tester.tap(find.text('Edit').first);
      await tester.pumpAndSettle();
    },
  );
  // Dropping Gym day on today: the proposal over the day.
  goldenMatrix(
    'routine_drop',
    height: 1100,
    widths: const {'compact', 'expanded'},
    overrides: _overrides(),
    build: (_) => _page(),
    act: (tester) async {
      await tester.tap(find.text('Drop on today').last);
      await tester.pumpAndSettle();
    },
  );
}
