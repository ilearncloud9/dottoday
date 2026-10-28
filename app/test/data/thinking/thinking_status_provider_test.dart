import 'package:dottoday/data/thinking/thinking_providers.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_status.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/thinking_fakes.dart';

// docs/09 M14.1: the vendor comes from the platform in the data layer (no
// Platform.isX in widgets), and the status pairs it with the transport's
// answer; a transport that throws reads as unknown.

void main() {
  final vendors = {
    TargetPlatform.iOS: ThinkingVendor.appleIos,
    TargetPlatform.macOS: ThinkingVendor.appleMac,
    TargetPlatform.android: ThinkingVendor.google,
    TargetPlatform.linux: ThinkingVendor.none,
    TargetPlatform.windows: ThinkingVendor.none,
  };
  for (final MapEntry(key: platform, value: vendor) in vendors.entries) {
    test('${platform.name} → ${vendor.name}', () {
      debugDefaultTargetPlatformOverride = platform;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(thinkingVendorProvider), vendor);
    });
  }

  for (final state in ThinkingAvailability.values) {
    test('status carries ${state.name}', () async {
      final c = ProviderContainer(
        overrides: [
          thinkingTransportProvider.overrideWithValue(
            FakeThinkingTransport(state: state),
          ),
          thinkingVendorProvider.overrideWithValue(ThinkingVendor.appleIos),
        ],
      );
      addTearDown(c.dispose);
      expect(
        await c.read(thinkingStatusProvider.future),
        ThinkingStatus(availability: state, vendor: ThinkingVendor.appleIos),
      );
    });
  }

  test('a transport that throws reads as unknown', () async {
    final c = ProviderContainer(
      overrides: [
        thinkingTransportProvider.overrideWithValue(_Throwing()),
        thinkingVendorProvider.overrideWithValue(ThinkingVendor.google),
      ],
    );
    addTearDown(c.dispose);
    final s = await c.read(thinkingStatusProvider.future);
    expect(s.availability, ThinkingAvailability.unknown);
  });
}

class _Throwing extends FakeThinkingTransport {
  @override
  Future<ThinkingAvailability> availability() async => throw StateError('x');
}
