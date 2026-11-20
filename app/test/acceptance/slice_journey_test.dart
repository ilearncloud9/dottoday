import 'package:dottoday/core/theme/dot_idiom.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'slice_journey.dart';
import 'slice_journey_steps.dart';

/// The first slice's journey on every target, in Full and in Minimal
/// (docs/09 M19.7). A device runs it at its own size through
/// `integration_test/slice_journey_test.dart`.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  for (final target in sliceTargets) {
    for (final minimal in [false, true]) {
      final layout = minimal ? 'Minimal' : 'Full';
      testWidgets('${target.name}, $layout', (tester) async {
        if (target.web) {
          debugWebChromeOverride = true;
          addTearDown(() => debugWebChromeOverride = null);
        }
        tester.view
          ..physicalSize = target.size
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await runSliceJourney(tester, minimal: minimal);
      }, variant: TargetPlatformVariant.only(target.platform));
    }
  }
}
