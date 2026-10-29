import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_status.dart';
import 'package:flutter_test/flutter_test.dart';

// docs/09 M14.1: the status says which path answers and whether a gentle
// nudge may show (D4: only where switching on or waiting would help).

void main() {
  const nudging = {
    ThinkingAvailability.notEnabled,
    ThinkingAvailability.downloadable,
    ThinkingAvailability.downloading,
  };

  for (final vendor in ThinkingVendor.values) {
    for (final availability in ThinkingAvailability.values) {
      test('${vendor.name} × ${availability.name}', () {
        final s = ThinkingStatus(availability: availability, vendor: vendor);
        expect(
          s.path,
          availability == ThinkingAvailability.available
              ? ThinkingPath.onDevice
              : ThinkingPath.rules,
        );
        expect(
          s.offersNudge,
          vendor != ThinkingVendor.none && nudging.contains(availability),
        );
      });
    }
  }

  test('never nudges where the device cannot run the model', () {
    for (final vendor in ThinkingVendor.values) {
      final s = ThinkingStatus(
        availability: ThinkingAvailability.notEligible,
        vendor: vendor,
      );
      expect(s.offersNudge, isFalse);
    }
  });

  test('value equality', () {
    const a = ThinkingStatus(
      availability: ThinkingAvailability.available,
      vendor: ThinkingVendor.google,
    );
    const b = ThinkingStatus(
      availability: ThinkingAvailability.available,
      vendor: ThinkingVendor.google,
    );
    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });
}
