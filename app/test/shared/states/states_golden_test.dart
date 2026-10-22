// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';

// The loading skeleton and the inline error (derived, docs/09 M3f.9b;
// 10 §5.4).

void main() {
  setUpAll(loadAppFonts);
  const widths = {'compact', 'expanded'};
  goldenMatrix(
    'state_loading',
    height: 400,
    widths: widths,
    build: (_) =>
        StateScaffold(inputs: const [AsyncLoading<Object?>()], onRetry: () {}),
  );
  goldenMatrix(
    'state_error',
    height: 400,
    widths: widths,
    build: (_) => StateScaffold(
      inputs: const [AsyncError<Object?>(StorageFailure(), StackTrace.empty)],
      onRetry: () {},
    ),
  );
}
