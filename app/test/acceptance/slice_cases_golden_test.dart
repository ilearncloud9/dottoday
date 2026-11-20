@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'slice_world.dart';

/// The slice's cases drawn (M19.7): Today in Full and Now in Minimal,
/// empty, dense, loading, failed, with long titles and at 200 % text, on
/// an iPhone, an iPad in portrait and the Mac. Light; dark is covered by
/// each part's own goldens.
void main() {
  setUpAll(tz_data.initializeTimeZones);
  setUpAll(loadAppFonts);

  for (final minimal in [false, true]) {
    final screen = minimal ? 'now' : 'today';
    for (final w in SliceWidth.values) {
      for (final c in SliceCase.values) {
        testWidgets('golden: $screen ${c.name} ${w.name}', (tester) async {
          await pumpSlice(tester, minimal: minimal, c: c, w: w);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/${screen}_${c.name}_${w.name}.png'),
          );
        }, variant: TargetPlatformVariant.only(w.platform));
      }
    }
  }
}
