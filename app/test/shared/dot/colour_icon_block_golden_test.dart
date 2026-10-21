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
}
