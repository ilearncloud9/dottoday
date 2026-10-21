import 'package:dottoday/domain/entities/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert.freezed.dart';
part 'alert.g.dart';

/// One notification attached to a series or occurrence (docs/05 `alerts`,
/// R-10). Up to 5 per task.
///
/// [offsetMin] is minutes before the start for [AlertKind.before], and after
/// the end for [AlertKind.overdue]; ignored for the other kinds.
@freezed
abstract class Alert with _$Alert {
  const factory Alert({
    required AlertKind kind,
    @Default(0) int offsetMin,
    String? sound,
  }) = _Alert;

  factory Alert.fromJson(Map<String, Object?> json) => _$AlertFromJson(json);
}

/// One row of `series.subtask_template`; copied into a fresh [Subtask] per
/// materialised occurrence so completion never leaks across days (R-09).
@freezed
abstract class SubtaskTemplateItem with _$SubtaskTemplateItem {
  const factory SubtaskTemplateItem({
    required String id,
    required String title,
    @Default(0) double sortOrder,
  }) = _SubtaskTemplateItem;

  factory SubtaskTemplateItem.fromJson(Map<String, Object?> json) =>
      _$SubtaskTemplateItemFromJson(json);
}
