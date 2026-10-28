import 'dart:io';

import 'package:dottoday/data/thinking/channel_thinking_transport.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:flutter_test/flutter_test.dart';

// The model's availability crosses `dottoday/thinking` as a word (docs/09
// M14.1): Swift, Kotlin and the web transport must send only words Dart
// reads, and every reason the UI explains must have a word, or a user
// with Apple Intelligence off is told their device can't run it.

/// Every word `parseAvailability` knows, and what it means.
const _wire = {
  'available': ThinkingAvailability.available,
  'downloadable': ThinkingAvailability.downloadable,
  'downloading': ThinkingAvailability.downloading,
  'not_enabled': ThinkingAvailability.notEnabled,
  'not_eligible': ThinkingAvailability.notEligible,
  'unknown': ThinkingAvailability.unknown,
  // Chrome's own word for "this browser can't".
  'unavailable': ThinkingAvailability.notEligible,
};

final _quoted = RegExp('"([a-z_]+)"');

/// The quoted words in [source] between [from] and [to].
Set<String> _words(String source, String from, String to) {
  final start = source.indexOf(from);
  expect(start, isNonNegative, reason: from);
  final end = source.indexOf(to, start);
  expect(end, greaterThan(start), reason: to);
  return {
    for (final m in _quoted.allMatches(source.substring(start, end)))
      m.group(1)!,
  };
}

void main() {
  test('Dart reads every word as documented', () {
    for (final MapEntry(key: word, value: state) in _wire.entries) {
      expect(parseAvailability(word), state, reason: word);
    }
    expect(parseAvailability('maybe'), ThinkingAvailability.unknown);
    expect(parseAvailability(null), ThinkingAvailability.unknown);
  });

  test('Swift sends only known words, with every Apple reason', () {
    final src = File('ios/Runner/ThinkingBridge.swift').readAsStringSync();
    final words = _words(
      src,
      'static func availability()',
      "/// The model's answer",
    );
    expect(_wire.keys, containsAll(words));
    expect(
      words,
      containsAll(['available', 'not_enabled', 'not_eligible', 'downloading']),
    );
  });

  test('Kotlin sends only known words, with every AICore state', () {
    final src = File(
      'android/app/src/main/kotlin/app/dottoday/planner/thinking/'
      'ThinkingBridge.kt',
    ).readAsStringSync();
    final words = {
      ..._words(src, '"availability" ->', '"generate" ->'),
      ..._words(src, 'fun availabilityWord', 'private fun model()'),
    }..remove('availability');
    expect(_wire.keys, containsAll(words));
    expect(
      words,
      containsAll(['available', 'downloadable', 'downloading', 'not_eligible']),
    );
  });

  test('the web reports a missing API as not eligible', () {
    final src = File(
      'lib/data/thinking/web/prompt_api_transport_web.dart',
    ).readAsStringSync();
    expect(src, contains("parseAvailability('not_eligible')"));
    expect(src, contains('parseAvailability(value.toDart)'));
  });

  test('every reason the UI explains has a word', () {
    expect(_wire.values.toSet(), ThinkingAvailability.values.toSet());
  });
}
