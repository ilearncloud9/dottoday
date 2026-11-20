import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Max fraction of differing pixels a golden may have and still pass.
///
/// Absorbs anti-aliasing noise between macOS machines (CI saw 0.01 % on
/// identical output) while still catching real token/layout changes.
const goldenTolerance = 0.001; // 0.1 %

/// The native bridges a test has no host for (owner, native pass): the
/// system alert and menu. Without an answer the app's call waits for a
/// platform reply that `pumpAndSettle` doesn't wait for; "no bridge" makes
/// it draw its own at once, as a build without the bridge does. A test of
/// the native path sets its own handler, which this replaces next test.
const _bridgesWithoutHost = [
  MethodChannel('dottoday/alert'),
  MethodChannel('dottoday/context_menu'),
];

void _noNativeBridges() {
  final TestDefaultBinaryMessenger messenger;
  try {
    messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  } on FlutterError {
    return; // A plain test() with no binding: no widgets, no bridges.
  }
  for (final channel in _bridgesWithoutHost) {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => throw MissingPluginException(),
    );
  }
}

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUp(_noNativeBridges);
  final current = goldenFileComparator;
  if (current is LocalFileComparator) {
    goldenFileComparator = _TolerantComparator(
      current.basedir.resolve('flutter_test_config.dart'),
    );
  }
  await testMain();
}

final class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    try {
      if (result.passed || result.diffPercent <= goldenTolerance) return true;
      throw FlutterError(await generateFailureOutput(result, golden, basedir));
    } finally {
      result.dispose();
    }
  }
}
