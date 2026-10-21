import 'dart:convert';

const _fnvOffset = 0x811c9dc5;
const _fnvPrime = 0x01000193;

/// Stable notification ID for one alert of one occurrence (docs/04 §6,
/// R-10): 32-bit FNV-1a of `occurrenceId#alertIndex`, kept to 31 bits so it
/// is a positive Android `int`.
///
/// Same inputs always give the same ID on every device and run, so
/// re-planning replaces a notification instead of adding a duplicate.
///
/// ```dart
/// notificationIdFor('0192…', 0); // e.g. 1462385721
/// ```
int notificationIdFor(String occurrenceId, int alertIndex) {
  var hash = _fnvOffset;
  for (final byte in utf8.encode('$occurrenceId#$alertIndex')) {
    hash = ((hash ^ byte) * _fnvPrime) & 0xFFFFFFFF;
  }
  return hash & 0x7FFFFFFF;
}
