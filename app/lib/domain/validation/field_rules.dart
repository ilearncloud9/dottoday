import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/block_color_keys.gen.dart';
import 'package:dottoday/domain/entities/icon_keys.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:rrule/rrule.dart';
import 'package:timezone/timezone.dart' as tz;

// Field-level rules from docs/05 "Validation". Each returns the first
// failure, or null when the value is valid. Inputs are already normalised
// (titles trimmed) by the entity validators.

const maxTitleLength = 200;
const maxNotesLength = 10000;
const minDurationMin = 5;
const maxDurationMin = 1440;
const maxTravelBufferMin = 180;
const maxAlerts = 5;
const maxAlertOffsetMin = 1440;
const maxSubtasks = 50;

ValidationFailure _fail(ValidationField field, ValidationRule rule) =>
    ValidationFailure(field, rule);

/// Returns a failure when [value] is outside `min..max` (inclusive).
ValidationFailure? checkRange(
  ValidationField field,
  int value,
  int min,
  int max,
) {
  if (value < min || value > max) {
    return _fail(field, ValidationRule.outOfRange);
  }
  return null;
}

/// Required text of 1..[max] characters ([value] already trimmed).
ValidationFailure? checkRequiredText(
  ValidationField field,
  String value, {
  int max = maxTitleLength,
}) {
  if (value.isEmpty) return _fail(field, ValidationRule.required);
  if (value.length > max) return _fail(field, ValidationRule.tooLong);
  return null;
}

/// Optional text of at most [max] characters.
ValidationFailure? checkOptionalText(
  ValidationField field,
  String? value, {
  required int max,
}) {
  if (value != null && value.length > max) {
    return _fail(field, ValidationRule.tooLong);
  }
  return null;
}

ValidationFailure? checkColorKey(String key) => blockColorKeys.contains(key)
    ? null
    : _fail(ValidationField.color, ValidationRule.invalidFormat);

ValidationFailure? checkIconKey(String key) => iconKeyPattern.hasMatch(key)
    ? null
    : _fail(ValidationField.icon, ValidationRule.invalidFormat);

/// [tzId] must be a known IANA zone.
///
/// Throws [StateError] if the time-zone database was never loaded: that is a
/// startup bug (bootstrap calls `initializeTimeZones`), not bad input.
ValidationFailure? checkTimeZone(String tzId) {
  final zones = tz.timeZoneDatabase.locations;
  if (zones.isEmpty) {
    throw StateError('Time-zone database not initialised');
  }
  return zones.containsKey(tzId)
      ? null
      : _fail(ValidationField.timeZone, ValidationRule.invalidFormat);
}

/// Up to [maxAlerts] alerts, each offset within 0..[maxAlertOffsetMin].
ValidationFailure? checkAlerts(List<Alert> alerts) {
  if (alerts.length > maxAlerts) {
    return _fail(ValidationField.alerts, ValidationRule.tooLarge);
  }
  for (final alert in alerts) {
    final failure = checkRange(
      ValidationField.alertOffset,
      alert.offsetMin,
      0,
      maxAlertOffsetMin,
    );
    if (failure != null) return failure;
  }
  return null;
}

/// [rrule] is an RFC 5545 rule body without the `RRULE:` prefix and must
/// parse with a `FREQ` part.
ValidationFailure? checkRrule(String rrule) {
  final invalid =
      _fail(ValidationField.recurrence, ValidationRule.invalidFormat);
  if (rrule.length > 512 || !rrule.startsWith('FREQ=')) return invalid;
  try {
    RecurrenceRule.fromString('RRULE:$rrule');
    return null;
  } on FormatException {
    return invalid;
  }
}

final _localDateTime = RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(:\d{2})?$');

/// Wall-clock ISO-8601 with no offset, e.g. `2026-10-21T08:30`.
ValidationFailure? checkLocalDateTime(String value) {
  final invalid =
      _fail(ValidationField.startTime, ValidationRule.invalidFormat);
  if (!_localDateTime.hasMatch(value)) return invalid;
  final parsed = DateTime.tryParse(value);
  // Rejects rolled-over dates such as 2026-02-30 that DateTime would accept.
  if (parsed == null || !_sameDigits(parsed, value)) return invalid;
  return null;
}

bool _sameDigits(DateTime parsed, String value) {
  String two(int n) => n.toString().padLeft(2, '0');
  final prefix = '${parsed.year.toString().padLeft(4, '0')}-'
      '${two(parsed.month)}-${two(parsed.day)}T${two(parsed.hour)}:'
      '${two(parsed.minute)}';
  return value.startsWith(prefix);
}

final _hhmm = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

/// A `HH:mm`–`HH:mm` window; [allowWrap] permits end before start.
ValidationFailure? checkTimeWindow(TimeWindow window, {bool allowWrap = true}) {
  final invalid = _fail(ValidationField.settings, ValidationRule.invalidFormat);
  if (!_hhmm.hasMatch(window.start) || !_hhmm.hasMatch(window.end)) {
    return invalid;
  }
  final order = window.start.compareTo(window.end);
  if (order == 0 || (!allowWrap && order > 0)) {
    return _fail(ValidationField.settings, ValidationRule.outOfRange);
  }
  return null;
}

/// Returns the first non-null failure in [checks].
ValidationFailure? firstFailure(Iterable<ValidationFailure?> checks) =>
    checks.firstWhere((f) => f != null, orElse: () => null);
