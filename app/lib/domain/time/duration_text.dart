import 'package:dottoday/domain/validation/field_rules.dart';

/// The preset durations offered as chips (docs/02 F2 "15/30/45/60/90").
const durationPresetsMin = [15, 30, 45, 60, 90];

/// Parses a typed custom duration into minutes, or null if it isn't one or
/// falls outside [minDurationMin]–[maxDurationMin].
///
/// Accepts `40`, `40m`, `40 min`, `2h`, `1.5h`, `1,5h`, `1h30`, `1h 30m`,
/// `1:30`. A bare number is minutes.
///
/// ```dart
/// parseDurationText('1h30'); // 90
/// ```
int? parseDurationText(String input) {
  final text = input.trim().toLowerCase();
  final minutes =
      _bareMinutes(text) ??
      _clock(text) ??
      _decimalHours(text) ??
      _hoursMinutes(text);
  if (minutes == null) return null;
  if (minutes < minDurationMin || minutes > maxDurationMin) return null;
  return minutes;
}

int? _bareMinutes(String t) {
  final m = RegExp(r'^(\d{1,4})\s*(?:m|min|mins|minutes?)?$').firstMatch(t);
  return m == null ? null : int.parse(m[1]!);
}

int? _clock(String t) {
  final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(t);
  if (m == null) return null;
  final minute = int.parse(m[2]!);
  return minute > 59 ? null : int.parse(m[1]!) * 60 + minute;
}

int? _decimalHours(String t) {
  final m = RegExp(
    r'^(\d{1,2})[.,](\d{1,2})\s*(?:h|hrs?|hours?)$',
  ).firstMatch(t);
  if (m == null) return null;
  final hours = double.parse('${m[1]}.${m[2]}');
  return (hours * 60).round();
}

int? _hoursMinutes(String t) {
  final m = RegExp(
    r'^(\d{1,2})\s*(?:h|hrs?|hours?)\s*(?:(\d{1,2})\s*(?:m|min|mins|minutes?)?)?$',
  ).firstMatch(t);
  if (m == null) return null;
  final minute = m[2] == null ? 0 : int.parse(m[2]!);
  return minute > 59 ? null : int.parse(m[1]!) * 60 + minute;
}
