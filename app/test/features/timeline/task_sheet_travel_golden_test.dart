// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/data/calendar/travel_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/task_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';

/// An imported appointment's sheet with the TRAVEL TIME suggestion
/// (derived, docs/09 M7.5, R-17): its place, Add 15 min before, Not now.
Widget _sheet() {
  final dentist = Occurrence(
    id: 'imported-1',
    userId: testUserId,
    title: 'Dentist',
    colorKey: 'teal',
    startUtc: DateTime.utc(2026, 10, 21, 13),
    tzId: 'Europe/Berlin',
    durationMin: 45,
    source: OccurrenceSource.calendar,
    calendarLinkId: 'link-1',
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
  return ProviderScope(
    overrides: _overrides(dentist),
    child: TaskScreen(id: dentist.id),
  );
}

List<Override> _overrides(Occurrence dentist) => [
  ...timelineOverrides(
    now: DateTime.utc(2026, 10, 21, 7, 22),
    occurrences: FakeOccurrenceRepository([dentist]),
    profile: testProfile(
      settings: const Settings(use24h: false, suggestTravelTime: true),
    ),
  ),
  calendarEventLocationProvider.overrideWith(
    (ref, linkId) => Stream.value('Dr. Weber, Hauptstraße 4'),
  ),
];

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });
  goldenMatrix(
    'task_sheet_travel',
    height: 760,
    widths: const {'compact', 'medium', 'expanded'},
    build: (_) => _sheet(),
  );
}
