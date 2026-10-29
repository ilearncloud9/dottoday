@Tags(['golden'])
library;

import 'package:dottoday/features/settings/pages/siri_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';

// Settings › Siri & Shortcuts (docs/09 M14.3, derived — 11 §B6, D3): iPhone
// only, so compact; light/dark, 1×/2×, the largest text and RTL.

void main() {
  setUpAll(loadAppFonts);
  goldenMatrix(
    'siri_page',
    height: 1100,
    widths: const {'compact'},
    a11yVariants: true,
    build: (_) => const SiriPage(),
  );
}
