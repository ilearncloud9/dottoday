@Tags(['golden'])
library;

import 'package:dottoday/data/thinking/thinking_providers.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_status.dart';
import 'package:dottoday/features/settings/pages/thinking_status_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';

// Settings › Privacy › Help with thinking's status (docs/09 M14.2, derived
// — 11 §B4 AI status): Apple Intelligence off on iPhone (step, Open
// Settings, the own-page note) in every cell incl. 2.0 text and RTL; Gemini
// Nano downloadable and a device that can't run a model at compact.

void main() {
  setUpAll(loadAppFonts);
  for (final (name, a, v, a11y) in [
    (
      'apple_off',
      ThinkingAvailability.notEnabled,
      ThinkingVendor.appleIos,
      true,
    ),
    (
      'google_downloadable',
      ThinkingAvailability.downloadable,
      ThinkingVendor.google,
      false,
    ),
    (
      'not_eligible',
      ThinkingAvailability.notEligible,
      ThinkingVendor.chrome,
      false,
    ),
  ]) {
    goldenMatrix(
      'privacy_ai_status_$name',
      height: 640,
      widths: a11y
          ? const {'compact', 'medium', 'expanded'}
          : const {'compact'},
      a11yVariants: a11y,
      overrides: [
        thinkingStatusProvider.overrideWith(
          (ref) async => ThinkingStatus(availability: a, vendor: v),
        ),
      ],
      build: (_) => const Scaffold(
        body: Padding(
          padding: EdgeInsetsDirectional.all(16),
          child: ThinkingStatusBlock(),
        ),
      ),
    );
  }
}
