// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/features/timeline/widgets/zone_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';

// The travel banner (docs/09 M5.9, derived from the §5.4 strip): a Berlin
// planner in New York.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  goldenMatrix(
    'zone_banner',
    height: 200,
    widths: const {'compact', 'expanded'},
    overrides: timelineOverrides(
      now: DateTime.utc(2026, 10, 21, 10),
      deviceZone: 'America/New_York',
    ),
    build: (_) => const Scaffold(body: Column(children: [ZoneBanner()])),
  );
}
