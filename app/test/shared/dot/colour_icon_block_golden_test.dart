// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/colour_icon_block.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';

void main() {
  setUpAll(loadAppFonts);
  goldenMatrix(
    'colour_icon_block',
    height: 120,
    build: (_) => Padding(
      padding: const EdgeInsets.all(DotSpace.page),
      child: ColourIconBlock(
        color: TaskColor.coral,
        icon: TaskIcon.bag,
        onColor: (_) {},
        onIcon: (_) {},
      ),
    ),
  );
  // The full picker (docs/10 §3 task icon library, ADR-0013; derived):
  // colours, search, then the categories from Planning & rhythm down.
  goldenMatrix(
    'task_icon_picker',
    height: 760,
    a11yVariants: true,
    build: (_) => Padding(
      padding: const EdgeInsets.all(DotSpace.page),
      child: ColourIconBlock(
        color: TaskColor.coral,
        icon: TaskIcon.focusBlock,
        onColor: (_) {},
        onIcon: (_) {},
      ),
    ),
    act: (tester) async {
      await tester.ensureVisible(find.byTooltip('All icons'));
      await tester.tap(find.byTooltip('All icons'));
      await tester.pumpAndSettle();
    },
  );
}
