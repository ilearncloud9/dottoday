@Tags(['golden'])
library;

import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/features/timeline/widgets/siri_tip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';

// Today's one-time Siri card (docs/09 M14.3, derived — 11 §B6): iPhone
// only, so compact; light/dark, 1×/2×, the largest text and RTL.

void main() {
  setUpAll(loadAppFonts);
  goldenMatrix(
    'today_siri_tip',
    height: 300,
    widths: const {'compact'},
    a11yVariants: true,
    overrides: [siriTipDueProvider.overrideWith((ref) => Stream.value(true))],
    build: (_) => const Scaffold(body: Column(children: [SiriTipCard()])),
  );
}
