/// One row at a time, the JSON v1 import's rules (CR-160 Stage B3,
/// docs/cr-160-multipart-export.md §5): the staged import decodes and
/// validates each staged row with exactly the decoders and validators
/// `decodeExportJson` uses on a whole bundle, and normalises it the same
/// way (an imported block loses its calendar link). `export_json.dart` is
/// unchanged; the staged pipeline's equivalence test pins the two together.
library;

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/entities/calendar_series_template.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/validation/calendar_series_validator.dart';
import 'package:dottoday/domain/validation/entity_validators.dart';
import 'package:dottoday/domain/validation/routine_validator.dart';

/// The staged entity names: `profile` and the part tables.
const importEntities = [
  'profile',
  'series',
  'occurrences',
  'subtasks',
  'routines',
  'calendarSeries',
];

const _badFile = ValidationFailure(
  ValidationField.importFile,
  ValidationRule.invalidFormat,
);

/// [json] as a row of [entity], decoded only (the shape check every row
/// passes, even one the import then drops); [_badFile] when it isn't one.
Result<Object, ValidationFailure> decodeImportRow(
  String entity,
  Map<String, Object?> json,
) {
  try {
    final Object row = switch (entity) {
      'profile' => Profile.fromJson(json),
      'series' => Series.fromJson(json),
      'occurrences' => Occurrence.fromJson(json),
      'subtasks' => Subtask.fromJson(json),
      'routines' => Routine.fromJson(json),
      'calendarSeries' => CalendarSeriesTemplate.fromJson(json),
      _ => throw ArgumentError.value(entity, 'entity'),
    };
    return Ok(row);
  } on FormatException {
    return const Err(_badFile);
  } on TypeError {
    return const Err(_badFile);
  } on ArgumentError {
    return const Err(_badFile);
  }
}

/// [json] as a row of [entity], decoded, validated and normalised as the
/// v1 import does; the first failing rule otherwise.
Result<Object, ValidationFailure> importRow(
  String entity,
  Map<String, Object?> json,
) {
  final Object row;
  switch (decodeImportRow(entity, json)) {
    case Ok(:final value):
      row = value;
    case Err(:final failure):
      return Err(failure);
  }
  return switch (row) {
    final Profile p => validateProfile(p),
    final Series s => validateSeries(s),
    // Calendar links are device state, never imported (export_json.dart).
    final Occurrence o => validateOccurrence(
      o,
    ).map<Object>((v) => v.copyWith(calendarLinkId: null)),
    final Subtask s => validateSubtask(s),
    final Routine r => validateRoutine(r),
    final CalendarSeriesTemplate t => validateCalendarSeriesTemplate(t),
    _ => const Err(_badFile),
  };
}
