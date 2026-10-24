// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/shared/dot/shift_chip.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';

void main() {
  setUpAll(loadAppFonts);
  goldenMatrix(
    'shift_chip',
    height: 192,
    widths: const {'compact'},
    build: (_) => Column(
      children: [
        for (final on in [false, true])
          SizedBox(
            height: 64,
            child: Stack(children: [ShiftChip(on: ValueNotifier(on))]),
          ),
        // With "Calendar events too" beside it (docs/09 M7.6).
        SizedBox(
          height: 64,
          child: Stack(
            children: [
              ShiftChip(
                on: ValueNotifier(true),
                calendar: ValueNotifier(false),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
