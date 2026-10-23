// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/data/security/app_lock_store.dart';
import 'package:dottoday/data/security/device_auth.dart';
import 'package:dottoday/features/lock/lock_gate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';

// The app lock screen (derived, docs/09 M5.8; docs/10 §5.4 system states).

final class _Refuses implements DeviceAuth {
  @override
  bool asking = false;

  @override
  Future<bool> available() async => true;

  @override
  Future<bool> authenticate(String reason) async => false;
}

void main() {
  setUpAll(loadAppFonts);
  goldenMatrix(
    'lock_screen',
    height: 700,
    widths: const {'compact', 'expanded'},
    overrides: [
      deviceAuthProvider.overrideWithValue(_Refuses()),
      appLockSettingProvider.overrideWith(FakeAppLockSetting.new),
    ],
    build: (_) => const LockScreen(),
  );
}
