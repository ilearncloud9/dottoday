// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'dart:async';

import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/copy_day_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';

// Duplicate day… (E-R2-22 section 2): "Copy to which day?" as the month
// sheet over Today, on the demo day.

void main() {
  tz_data.initializeTimeZones();
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });
  goldenMatrix(
    'copy_day_sheet',
    height: 900,
    widths: const {'compact', 'expanded'},
    overrides: timelineOverrides(
      now: DateTime.utc(2026, 10, 21, 7, 22),
      occurrences: FakeOccurrenceRepository(
        demoDayRows(DateTime(2026, 10, 21)),
      ),
      profile: testProfile(
        settings: const Settings(use24h: false, firstDayOfWeek: 1),
      ),
    ),
    build: (_) => Scaffold(
      // Keeps the profile and today alive, as Today does.
      body: Consumer(
        builder: (context, ref, _) {
          ref
            ..watch(currentProfileProvider)
            ..watch(todayDateProvider);
          return Center(
            child: TextButton(
              onPressed: () => unawaited(
                showDuplicateDaySheet(context, source: DateTime(2026, 10, 21)),
              ),
              child: const Text('open'), // l10n-ignore: test trigger
            ),
          );
        },
      ),
    ),
    act: (tester) async {
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    },
  );
}
