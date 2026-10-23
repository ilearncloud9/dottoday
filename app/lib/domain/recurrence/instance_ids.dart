import 'dart:convert';

import 'package:crypto/crypto.dart';

/// The id of the occurrence series [seriesId] makes at [originalStartUtc]:
/// the same on every device, so two devices extending one repeat make one
/// row, not two that the server's unique `(series_id, original_start_utc)`
/// refuses forever (docs/09 M6.2, R-08).
///
/// A UUID v7 in form (deep links accept it): its time is the instance's
/// start, the rest comes from a SHA-256 of the pair.
///
/// ```dart
/// instanceId('0192…', DateTime.utc(2026, 10, 24, 7)); // stable
/// ```
String instanceId(String seriesId, DateTime originalStartUtc) {
  final ms = originalStartUtc.millisecondsSinceEpoch;
  return _v7(ms, '$seriesId|$ms');
}

/// The id of the [index]th template subtask of instance [occurrenceId]
/// (starting at [startUtc]), stable across devices like [instanceId].
String templateSubtaskId(String occurrenceId, int index, DateTime startUtc) =>
    _v7(startUtc.millisecondsSinceEpoch, '$occurrenceId|subtask|$index');

String _v7(int ms, String seed) {
  final hash = sha256.convert(utf8.encode(seed)).bytes;
  final b = List<int>.filled(16, 0);
  for (var i = 0; i < 6; i++) {
    b[i] = (ms >> (8 * (5 - i))) & 0xff;
  }
  for (var i = 6; i < 16; i++) {
    b[i] = hash[i];
  }
  b[6] = 0x70 | (b[6] & 0x0f); // version 7
  b[8] = 0x80 | (b[8] & 0x3f); // RFC 4122 variant
  final hex = [for (final x in b) x.toRadixString(16).padLeft(2, '0')].join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
