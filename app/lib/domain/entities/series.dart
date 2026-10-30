import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/icon_keys.dart';
import 'package:dottoday/domain/entities/task_color_keys.gen.dart';
import 'package:dottoday/domain/entities/utc_millis_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'series.freezed.dart';
part 'series.g.dart';

/// A recurring task template (docs/05 `series`, ADR-0004). Never shown on the
/// timeline itself; occurrences are materialised from it.
///
/// [rrule] is the RFC 5545 rule body without the `RRULE:` prefix
/// (e.g. `FREQ=WEEKLY;BYDAY=MO`). [dtstartLocal] is wall-clock ISO-8601 with
/// no offset, interpreted in [tzId] so DST never moves the task (R-01).
@freezed
abstract class Series with _$Series {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory Series({
    required String id,
    required String userId,
    required String title,
    String? notes,
    @Default(defaultTaskColorKey) String colorKey,
    @Default(defaultIconKey) String iconKey,
    required int durationMin,
    required String rrule,
    required String dtstartLocal,
    required String tzId,
    @UtcMillisConverter() DateTime? untilUtc,
    int? count,
    @Default(false) bool pinned,
    @Default(0) int travelBufferMin,

    /// Whether [durationMin] follows the template steps' sum (11 B2).
    @Default(false) bool durationFromSteps,
    Energy? energy,
    @Default(<Alert>[]) List<Alert> alerts,

    /// The reminder sound (docs/12 §3): null inherits
    /// `Settings.reminderSound`, `"none"` is silent, else a sound id.
    String? soundId,
    @Default(<SubtaskTemplateItem>[]) List<SubtaskTemplateItem> subtaskTemplate,
    @UtcMillisConverter() DateTime? materialisedThroughUtc,
    @UtcMillisConverter() DateTime? archivedAt,
    @UtcMillisConverter() required DateTime createdAt,
    @UtcMillisConverter() required DateTime updatedAt,
    @UtcMillisConverter() DateTime? deletedAt,
  }) = _Series;

  factory Series.fromJson(Map<String, Object?> json) => _$SeriesFromJson(json);
}
