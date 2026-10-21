import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// `flutter drive` entry for the design sweep (docs/08 §7): saves each
/// `binding.takeScreenshot(name)` to `build/sweep/<name>.png`.
Future<void> main() => integrationDriver(
  onScreenshot: (name, bytes, [args]) async {
    final file = File('build/sweep/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);
    return true;
  },
);
