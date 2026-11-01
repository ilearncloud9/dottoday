// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/time/day_dot_geometry.dart';
import 'package:dottoday/shared/dot/day_dot.dart';
import 'package:dottoday/shared/dot/week_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';
import '../../support/sample_day.dart';

class _Specimen extends StatelessWidget {
  const _Specimen();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DotSpace.page),
      child: Column(
        spacing: DotSpace.l,
        children: [
          const Wrap(
            spacing: DotSpace.l,
            runSpacing: DotSpace.l,
            children: [
              DayDot(geometry: DayDotGeometry.filled(0)),
              DayDot(geometry: DayDotGeometry.filled(0.4)),
              DayDot(geometry: DayDotGeometry.filled(1)),
              DayDot(
                geometry: DayDotGeometry.filled(0.4),
                size: DotSize.dayDotWatch,
              ),
              // The night (docs/15 W6): 5 h, 8 h and 10 h after a 07:00
              // Wake Up, the day half gone.
              DayDot(
                geometry: DayDotGeometry(dayEnd: 19 / 24, progress: 9.5 / 24),
              ),
              DayDot(
                geometry: DayDotGeometry(dayEnd: 16 / 24, progress: 8 / 24),
              ),
              DayDot(
                geometry: DayDotGeometry(dayEnd: 14 / 24, progress: 7 / 24),
              ),
            ],
          ),
          WeekStrip(
            days: mainWeek,
            selected: 3,
            onSelect: (_) {},
            onPull: () {},
          ),
        ],
      ),
    );
  }
}

void main() {
  setUpAll(loadAppFonts);
  goldenMatrix('week_strip', height: 300, build: (_) => const _Specimen());
}
