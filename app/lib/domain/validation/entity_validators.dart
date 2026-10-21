import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/entities/calendar.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/validation/field_rules.dart';

/// Outcome of validating an entity: the normalised entity or the first
/// failing field (docs/05 "Validation", 06 §7).
typedef Validated<T> = Result<T, ValidationFailure>;

Validated<T> _result<T>(T value, ValidationFailure? failure) =>
    failure == null ? Ok(value) : Err(failure);

/// Validates a series, trimming its title.
///
/// ```dart
/// validateSeries(s.copyWith(rrule: 'WEEKLY')); // Err(validation.recurrence…)
/// ```
Validated<Series> validateSeries(Series series) {
  final s = series.copyWith(title: series.title.trim());
  final count = s.count;
  return _result(
    s,
    firstFailure([
      ..._taskFields(s.title, s.notes, s.colorKey, s.iconKey, s.durationMin),
      checkRange(
        ValidationField.travelBuffer,
        s.travelBufferMin,
        0,
        maxTravelBufferMin,
      ),
      checkTimeZone(s.tzId),
      checkRrule(s.rrule),
      checkLocalDateTime(s.dtstartLocal),
      if (count != null)
        checkRange(ValidationField.recurrence, count, 1, 10000),
      // RFC 5545 §3.3.10: UNTIL and COUNT are mutually exclusive.
      if (count != null && s.untilUtc != null)
        const ValidationFailure(
          ValidationField.recurrence,
          ValidationRule.invalidFormat,
        ),
      checkAlerts(s.alerts),
      checkSubtaskCount(s.subtaskTemplate.length),
      for (final item in s.subtaskTemplate)
        checkRequiredText(ValidationField.title, item.title.trim()),
    ]),
  );
}

/// Validates an occurrence, trimming its title.
Validated<Occurrence> validateOccurrence(Occurrence occurrence) {
  final o = occurrence.copyWith(title: occurrence.title.trim());
  final alerts = o.alerts;
  return _result(
    o,
    firstFailure([
      ..._taskFields(o.title, o.notes, o.colorKey, o.iconKey, o.durationMin),
      checkRange(
        ValidationField.travelBuffer,
        o.travelBufferMin,
        0,
        maxTravelBufferMin,
      ),
      checkTimeZone(o.tzId),
      if (alerts != null) checkAlerts(alerts),
    ]),
  );
}

/// Validates a subtask, trimming its title.
Validated<Subtask> validateSubtask(Subtask subtask) {
  final s = subtask.copyWith(title: subtask.title.trim());
  return _result(s, checkRequiredText(ValidationField.title, s.title));
}

/// Validates the subtask count of one occurrence (≤ 50, docs/05).
ValidationFailure? checkSubtaskCount(int count) => count > maxSubtasks
    ? const ValidationFailure(ValidationField.subtasks, ValidationRule.tooLarge)
    : null;

/// Validates settings; mirrors `validate_settings()` server-side.
Validated<Settings> validateSettings(Settings s) {
  return _result(
    s,
    firstFailure([
      if (!Settings.snapChoices.contains(s.snapMinutes))
        const ValidationFailure(
          ValidationField.settings,
          ValidationRule.outOfRange,
        ),
      for (final window in s.dayBoundaries.values)
        checkTimeWindow(window, allowWrap: false),
      checkRange(
        ValidationField.duration,
        s.defaultDurationMin,
        minDurationMin,
        maxDurationMin,
      ),
      checkAlerts(s.defaultAlerts),
      if (s.quietHours case final quiet?) checkTimeWindow(quiet),
      checkRange(ValidationField.settings, s.firstDayOfWeek, 1, 7),
      checkAccentKey(s.accent),
    ]),
  );
}

/// Validates a profile and its settings, trimming the display name.
Validated<Profile> validateProfile(Profile profile) {
  final name = profile.displayName?.trim();
  final p = profile.copyWith(displayName: name);
  final settings = validateSettings(p.settings);
  return _result(
    p,
    firstFailure([
      checkOptionalText(ValidationField.displayName, name, max: 80),
      checkTimeZone(p.tzId),
      checkRequiredText(ValidationField.locale, p.locale, max: 16),
      if (settings case Err(:final failure)) failure,
    ]),
  );
}

/// Validates a calendar account, trimming its label.
Validated<CalendarAccount> validateCalendarAccount(CalendarAccount account) {
  final a = account.copyWith(label: account.label.trim());
  return _result(
    a,
    firstFailure([
      checkRequiredText(ValidationField.label, a.label, max: 80),
      checkOptionalText(ValidationField.label, a.externalAccountId, max: 256),
    ]),
  );
}

/// Validates the external identifiers of a calendar link (06 §7).
Validated<CalendarLink> validateCalendarLink(CalendarLink link) {
  return _result(
    link,
    firstFailure([
      checkRequiredText(
        ValidationField.label,
        link.externalCalendarId,
        max: 256,
      ),
      checkRequiredText(ValidationField.label, link.externalEventId, max: 512),
    ]),
  );
}

List<ValidationFailure?> _taskFields(
  String title,
  String? notes,
  String colorKey,
  String iconKey,
  int durationMin,
) => [
  checkRequiredText(ValidationField.title, title),
  checkOptionalText(ValidationField.notes, notes, max: maxNotesLength),
  checkColorKey(colorKey),
  checkIconKey(iconKey),
  checkRange(
    ValidationField.duration,
    durationMin,
    minDurationMin,
    maxDurationMin,
  ),
];
