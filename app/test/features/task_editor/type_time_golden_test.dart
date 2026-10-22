// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'dart:async';

import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/features/task_editor/add/widgets/type_time_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';

/// Time ⋯ › Type a time (derived, docs/10 §5.3).
void main() {
  setUpAll(loadAppFonts);
  const widths = {'compact', 'expanded'};
  goldenMatrix(
    'picker_type_time',
    height: 400,
    widths: widths,
    act: (tester) => tester.tap(find.text('open')),
    build: (_) => Builder(
      builder: (c) => Center(
        child: TextButton(
          onPressed: () => unawaited(
            showTypeTimeSheet(
              c,
              initial: const ClockTime(17, 0),
              use24h: false,
            ),
          ),
          child: const Text('open'), // l10n-ignore: test fixture
        ),
      ),
    ),
  );
}
