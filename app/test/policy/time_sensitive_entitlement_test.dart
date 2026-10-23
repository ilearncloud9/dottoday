import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// The time-sensitive entitlement is Release-only (docs/09 M6.5.4, 11 A0):
// the Personal Team can't provision it, so a Debug/Profile build that
// gained it would stop signing, and a Release build that lost it would let
// Focus silence dot-starts.
const _key = 'com.apple.developer.usernotifications.time-sensitive';

String _read(String path) => File(path).readAsStringSync();

/// CODE_SIGN_ENTITLEMENTS per configuration name for the target that uses
/// [entitlementsDir] (XCBuildConfiguration blocks end with `name = X;`).
Map<String, String> _entitlementsByConfig(String pbxproj, String prefix) {
  final out = <String, String>{};
  String? pending;
  for (final line in _read(pbxproj).split('\n')) {
    final ent = RegExp(r'CODE_SIGN_ENTITLEMENTS = (\S+);').firstMatch(line);
    if (ent != null && ent.group(1)!.startsWith(prefix)) pending = ent[1];
    final name = RegExp(r'^\s*name = (\w+);').firstMatch(line);
    if (name != null && pending != null) {
      out[name.group(1)!] = pending;
      pending = null;
    }
  }
  return out;
}

void main() {
  test('iOS: Release has it, Debug and Profile do not', () {
    final configs = _entitlementsByConfig(
      'ios/Runner.xcodeproj/project.pbxproj',
      'Runner/',
    );
    expect(configs['Release'], 'Runner/Release.entitlements');
    expect(configs['Debug'], 'Runner/Runner.entitlements');
    expect(configs['Profile'], 'Runner/Runner.entitlements');
    expect(_read('ios/Runner/Release.entitlements'), contains(_key));
    expect(_read('ios/Runner/Runner.entitlements'), isNot(contains(_key)));
  });

  test('macOS: not yet — added with the paid team (08 §6.1)', () {
    // On the Personal Team the entitlement makes a local Release build fail
    // provisioning (checked 2026-10-23), so it lands with the paid account;
    // until then Mac alerts at dot-start are "active", not time-sensitive.
    expect(_read('macos/Runner/Release.entitlements'), isNot(contains(_key)));
    expect(
      _read('macos/Runner/DebugProfile.entitlements'),
      isNot(contains(_key)),
    );
  });
}
