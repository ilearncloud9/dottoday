import 'package:dottoday/domain/entities/utc_millis_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subtask.freezed.dart';
part 'subtask.g.dart';

/// A checklist item belonging to exactly one occurrence (docs/05 `subtasks`).
/// Never shared across occurrences, so ticking it today leaves tomorrow's
/// copy untouched (R-09).
@freezed
abstract class Subtask with _$Subtask {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Subtask({
    required String id,
    required String userId,
    required String occurrenceId,
    required String title,
    @Default(false) bool done,
    @Default(0) double sortOrder,

    /// Optional length of this step in minutes, 1–1440 (11 B2).
    int? durationMin,
    @UtcMillisConverter() required DateTime createdAt,
    @UtcMillisConverter() required DateTime updatedAt,
    @UtcMillisConverter() DateTime? deletedAt,
  }) = _Subtask;

  factory Subtask.fromJson(Map<String, Object?> json) =>
      _$SubtaskFromJson(json);
}
