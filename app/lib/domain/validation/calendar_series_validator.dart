import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/calendar/imported_event.dart';
import 'package:dottoday/domain/entities/calendar_series.dart';
import 'package:dottoday/domain/entities/calendar_series_template.dart';
import 'package:dottoday/domain/validation/entity_validators.dart';
import 'package:dottoday/domain/validation/field_rules.dart';

/// Validates what the person set for a repeating calendar event (docs/02
/// F5.7, 06 §7), trimming its title and step titles. Every override is
/// checked like the same field on a task; null fields are not set.
///
/// ```dart
/// validateCalendarSeries(s.copyWith(startMinute: 1440)); // Err(startTime…)
/// ```
Result<CalendarSeries, ValidationFailure> validateCalendarSeries(
  CalendarSeries series,
) {
  final title = series.title?.trim();
  final steps = series.subtaskTemplate;
  final s = series.copyWith(
    title: title,
    subtaskTemplate: steps == null
        ? null
        : [for (final i in steps) i.copyWith(title: i.title.trim())],
  );
  final failure = firstFailure([
    checkRequiredText(
      ValidationField.label,
      s.seriesKey,
      max: maxExternalEventIdLength,
    ),
    if (title != null) checkRequiredText(ValidationField.title, title),
    checkOptionalText(ValidationField.notes, s.notes, max: maxNotesLength),
    if (s.colorKey case final c?) checkColorKey(c),
    if (s.iconKey case final i?) checkIconKey(i),
    if (s.durationMin case final d?)
      checkRange(ValidationField.duration, d, minDurationMin, maxDurationMin),
    if (s.startMinute case final m?)
      checkRange(ValidationField.startTime, m, 0, 1439),
    if (s.tzId case final z?) checkTimeZone(z),
    if (s.travelBufferMin case final t?)
      checkRange(ValidationField.travelBuffer, t, 0, maxTravelBufferMin),
    if (s.alerts case final a?) checkAlerts(a),
    checkSoundKey(s.soundId),
    if (s.subtaskTemplate case final t?) ...[
      checkSubtaskCount(t.length),
      for (final item in t)
        checkRequiredText(ValidationField.title, item.title),
    ],
  ]);
  return failure == null ? Ok(s) : Err(failure);
}

/// What a device install tag looks like (`calendarDeviceTag`): 16 hex.
final _deviceTag = RegExp(r'^[0-9a-f]{16}$');

/// Validates one `calendarSeries` item of an import file (CR-160 Stage A,
/// 06 §7): its settings as [validateCalendarSeries] does, its calendar id
/// as the importer bounds it, and a [CalendarSeriesTemplate.deviceTag]
/// only on a device calendar, in its own shape. A tampered id only ever
/// fails here or stays unmatched: matching is exact, within the owner.
Result<CalendarSeriesTemplate, ValidationFailure>
validateCalendarSeriesTemplate(CalendarSeriesTemplate t) {
  final tag = t.deviceTag;
  final failure = firstFailure([
    checkRequiredText(
      ValidationField.label,
      t.externalCalendarId,
      max: maxExternalCalendarIdLength,
    ),
    if (tag != null && (!t.isDevice || !_deviceTag.hasMatch(tag)))
      const ValidationFailure(
        ValidationField.label,
        ValidationRule.invalidFormat,
      ),
  ]);
  if (failure != null) return Err(failure);
  return switch (validateCalendarSeries(t.settings)) {
    Ok(:final value) => Ok(t.copyWith(settings: value)),
    Err(:final failure) => Err(failure),
  };
}
