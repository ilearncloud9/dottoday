// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/data/calendar/write_back_providers.dart';
import 'package:dottoday/features/calendar_import/write_back_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/calendar_fakes.dart';
import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';

// Write-back's clash banner (docs/09 M7.3, derived from the §5.4 strip):
// one event changed here and in its calendar; two actions.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  goldenMatrix(
    'write_back_banner',
    height: 200,
    widths: const {'compact', 'expanded'},
    overrides: timelineOverrides(
      now: DateTime.utc(2026, 10, 21, 10),
      writeBack: () =>
          IdleWriteBackController(initial: const WriteBackState(clashes: 1)),
    ),
    build: (_) => const Scaffold(body: Column(children: [WriteBackBanner()])),
  );
}
