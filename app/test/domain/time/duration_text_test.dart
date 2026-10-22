import 'package:dottoday/domain/time/duration_presets.dart';
import 'package:dottoday/domain/time/duration_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const cases = <String, int?>{
    '40': 40,
    '40m': 40,
    '40 min': 40,
    '40 minutes': 40,
    '2h': 120,
    '2 hours': 120,
    '1.5h': 90,
    '1,5h': 90,
    '1h30': 90,
    '1h 30m': 90,
    '1:30': 90,
    '24h': 1440,
    '5': 5,
    '4': null,
    '25h': null,
    '1441': null,
    '1h60': null,
    '1:75': null,
    '': null,
    'soon': null,
  };
  for (final MapEntry(key: input, value: want) in cases.entries) {
    test('"$input" → $want', () => expect(parseDurationText(input), want));
  }

  test('default presets are valid', () {
    expect(validPresets(defaultDurationPresets), isTrue);
  });
}
