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

    /// When it was ticked done (ADR-0012), cleared when unticked; null for
    /// steps ticked before it existed. Meaningful only while [done].
    @UtcMillisConverter() DateTime? doneAt,
    @UtcMillisConverter() required DateTime createdAt,
    @UtcMillisConverter() required DateTime updatedAt,
    @UtcMillisConverter() DateTime? deletedAt,
  }) = _Subtask;

  factory Subtask.fromJson(Map<String, Object?> json) =>
      _$SubtaskFromJson(json);
}

/// [step] ticked ([done] true) or unticked at [nowUtc]: the one way a tick
/// is written, so its time is never forgotten or inferred (ADR-0012).
///
/// ```dart
/// tick(step, done: true, nowUtc: now).doneAt; // now
/// ```
Subtask tick(Subtask step, {required bool done, required DateTime nowUtc}) =>
    step.copyWith(done: done, doneAt: done ? nowUtc : null, updatedAt: nowUtc);
