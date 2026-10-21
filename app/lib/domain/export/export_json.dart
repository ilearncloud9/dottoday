import 'dart:convert';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/validation/entity_validators.dart';

/// Largest import accepted, in UTF-8 bytes (06 §7).
const maxImportBytes = 25 * 1024 * 1024;

/// Serialises [bundle] as JSON v1 (docs/05 "Export format").
String encodeExportJson(ExportBundle bundle) =>
    const JsonEncoder.withIndent(' ').convert(bundle.toJson());

const _badFile = ValidationFailure(
  ValidationField.importFile,
  ValidationRule.invalidFormat,
);

/// Parses and validates an import file (docs/05: JSON v1 only, R-11).
///
/// Rejects, without partial results: files over [maxImportBytes]; anything
/// that is not a v1 bundle (other or newer versions, wrong shapes); rows
/// failing the entity validators; duplicate ids; and occurrences/subtasks
/// pointing at rows missing from the file. Valid rows come back normalised
/// (titles trimmed, `calendar_link_id` cleared). The caller backs up first
/// and imports in one transaction (M2.4).
Result<ExportBundle, ValidationFailure> decodeExportJson(String text) {
  if (text.length > maxImportBytes ||
      utf8.encode(text).length > maxImportBytes) {
    return const Err(
      ValidationFailure(ValidationField.importFile, ValidationRule.tooLarge),
    );
  }
  final ExportBundle bundle;
  try {
    final json = jsonDecode(text);
    if (json is! Map<String, Object?> ||
        json['version'] != ExportBundle.version) {
      return const Err(_badFile);
    }
    bundle = ExportBundle.fromJson(json);
  } on FormatException {
    return const Err(_badFile);
  } on TypeError {
    // Wrong JSON shape: a field of the wrong type or missing.
    return const Err(_badFile);
  } on ArgumentError {
    // Unknown enum value.
    return const Err(_badFile);
  }
  return _validated(bundle);
}

Result<ExportBundle, ValidationFailure> _validated(ExportBundle b) {
  final profile = validateProfile(b.profile);
  final series = b.series.map(validateSeries).toList();
  final occurrences = b.occurrences.map(validateOccurrence).toList();
  final subtasks = b.subtasks.map(validateSubtask).toList();
  for (final r in [profile, ...series, ...occurrences, ...subtasks]) {
    if (r case Err(:final failure)) return Err(failure);
  }
  T ok<T>(Validated<T> r) => (r as Ok<T, ValidationFailure>).value;
  final clean = ExportBundle(
    exportedAt: b.exportedAt,
    profile: ok(profile),
    series: series.map(ok).toList(),
    // Calendar links are device/account state and are not exported, so an
    // imported block keeps its data but loses the link (re-import relinks).
    occurrences: [
      for (final o in occurrences) ok(o).copyWith(calendarLinkId: null),
    ],
    subtasks: subtasks.map(ok).toList(),
  );
  return _consistent(clean) ? Ok(clean) : const Err(_badFile);
}

/// Unique ids per table, and every reference resolves inside the file.
bool _consistent(ExportBundle b) {
  final seriesIds = {for (final s in b.series) s.id};
  final occurrenceIds = {for (final o in b.occurrences) o.id};
  final subtaskIds = {for (final s in b.subtasks) s.id};
  if (seriesIds.length != b.series.length ||
      occurrenceIds.length != b.occurrences.length ||
      subtaskIds.length != b.subtasks.length) {
    return false;
  }
  final ownerIds = {
    b.profile.id,
    for (final s in b.series) s.userId,
    for (final o in b.occurrences) o.userId,
    for (final s in b.subtasks) s.userId,
  };
  return ownerIds.length == 1 &&
      b.occurrences.every(
        (o) => o.seriesId == null || seriesIds.contains(o.seriesId),
      ) &&
      b.subtasks.every((s) => occurrenceIds.contains(s.occurrenceId));
}
