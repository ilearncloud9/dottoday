import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/duration_presets.dart';
import 'package:dottoday/domain/validation/entity_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('withPreset adds in order, once, within range and the cap', () {
    expect(withPreset([15, 60], 40), [15, 40, 60]);
    expect(withPreset([15, 60], 60), [15, 60]);
    expect(withPreset([15], 4), [15]);
    expect(withPreset([15], 1441), [15]);
    final full = [for (var i = 1; i <= maxDurationPresets; i++) i * 10];
    expect(withPreset(full, 5), full);
  });

  test('withoutPreset removes, but never the last one', () {
    expect(withoutPreset([15, 30], 15), [30]);
    expect(withoutPreset([30], 30), [30]);
    expect(withoutPreset([15, 30], 45), [15, 30]);
  });

  test('validPresets', () {
    expect(validPresets(defaultDurationPresets), isTrue);
    expect(validPresets(const []), isFalse);
    expect(validPresets(const [15, 15]), isFalse);
    expect(validPresets(const [3]), isFalse);
    expect(validPresets([for (var i = 1; i <= 13; i++) i * 10]), isFalse);
  });

  test('settings: default presets, JSON round trip, validation', () {
    expect(const Settings().durationPresets, defaultDurationPresets);
    final s = const Settings(durationPresets: [20, 40]);
    expect(Settings.fromJson(s.toJson()).durationPresets, [20, 40]);
    // Rows written before M3c.3 have no key: they get the defaults.
    expect(Settings.fromJson(const {}).durationPresets, defaultDurationPresets);
    expect(validateSettings(s), isA<Ok<Settings, AppFailure>>());
    expect(
      validateSettings(const Settings(durationPresets: [])),
      isA<Err<Settings, AppFailure>>(),
    );
  });
}
