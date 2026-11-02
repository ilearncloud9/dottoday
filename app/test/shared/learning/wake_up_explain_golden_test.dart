// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/shared/learning/wake_up_explain_sheet.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';

// Wake Up's explain sheet (derived — docs/15 §11; no reference render): the
// four lines, and Help's fifth, how Wake Up rings on this phone.

void main() {
  setUpAll(loadAppFonts);
  goldenMatrix(
    'wake_up_explain',
    height: 520,
    a11yVariants: true,
    widths: const {'compact'},
    build: (_) => const Scaffold(
      body: AppSheet(
        title: 'How it works',
        child: WakeUpExplain(tierLine: 'Alarm-grade wake-up is on.'),
      ),
    ),
  );
}
