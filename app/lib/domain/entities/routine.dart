import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/icon_keys.dart';
import 'package:dottoday/domain/entities/task_color_keys.gen.dart';
import 'package:dottoday/domain/entities/utc_millis_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'routine.freezed.dart';
part 'routine.g.dart';

/// A saved slice of thread (11 C2, docs/05 `routines`): ordered steps
/// with their lengths and gaps, placed on a day by [anchor]. Dropping it
/// proposes one task per step; nothing on the timeline points back here.
@freezed
abstract class Routine with _$Routine {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory Routine({
    required String id,
    required String userId,
    required String title,
    @Default(RoutineAnchor.wake) RoutineAnchor anchor,

    /// Local minute of day the first step starts at; set only for
    /// [RoutineAnchor.time].
    int? anchorMinute,
    @Default(<RoutineItem>[]) List<RoutineItem> items,
    @Default(0) double sortOrder,
    @UtcMillisConverter() required DateTime createdAt,
    @UtcMillisConverter() required DateTime updatedAt,
    @UtcMillisConverter() DateTime? deletedAt,
  }) = _Routine;

  const Routine._();

  factory Routine.fromJson(Map<String, Object?> json) =>
      _$RoutineFromJson(json);

  /// Minutes from the first step's start to the last step's end.
  int get spanMinutes => items.fold(
    0,
    (end, i) =>
        i.offsetMin + i.durationMin > end ? i.offsetMin + i.durationMin : end,
  );
}

/// One step of a [Routine] (camelCase inside the JSON column, as
/// `series.subtask_template`).
@freezed
abstract class RoutineItem with _$RoutineItem {
  const factory RoutineItem({
    required String id,
    required String title,
    @Default(defaultTaskColorKey) String colorKey,
    @Default(defaultIconKey) String iconKey,

    /// Minutes after the routine's first step starts (0 for the first).
    required int offsetMin,
    required int durationMin,
  }) = _RoutineItem;

  factory RoutineItem.fromJson(Map<String, Object?> json) =>
      _$RoutineItemFromJson(json);
}
