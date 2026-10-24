// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/task_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';

/// An imported meeting's sheet with its LINKS (derived, docs/09 M7.2):
/// the description's video link under the subtasks.
Widget _sheet() {
  final meeting = Occurrence(
    id: 'imported-1',
    userId: testUserId,
    title: 'Design review',
    notes: 'Agenda in the doc.\n\nhttps://meet.example.com/abc-def',
    colorKey: 'sky',
    startUtc: DateTime.utc(2026, 10, 21, 8),
    tzId: 'Europe/Berlin',
    durationMin: 45,
    source: OccurrenceSource.calendar,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
  return ProviderScope(
    overrides: timelineOverrides(
      now: DateTime.utc(2026, 10, 21, 7, 22),
      occurrences: FakeOccurrenceRepository([meeting]),
      profile: testProfile(settings: const Settings(use24h: false)),
    ),
    child: TaskScreen(id: meeting.id),
  );
}

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });
  goldenMatrix(
    'task_sheet_links',
    height: 760,
    widths: const {'compact', 'medium', 'expanded'},
    build: (_) => _sheet(),
  );
}
