import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/validation/field_rules.dart';

/// Most steps a routine holds (docs/05 `routines`; the server's CHECK).
const maxRoutineItems = 30;

/// Validates a routine (docs/05 `routines`, 06 §7), trimming its title and
/// step titles: 1–[maxRoutineItems] steps of 5–1440 min, offsets within a
/// day, and a minute of day exactly when anchored to a time.
///
/// ```dart
/// validateRoutine(r.copyWith(items: const [])); // Err(validation.subtasks…)
/// ```
Result<Routine, ValidationFailure> validateRoutine(Routine routine) {
  final r = routine.copyWith(
    title: routine.title.trim(),
    items: [for (final i in routine.items) i.copyWith(title: i.title.trim())],
  );
  final minute = r.anchorMinute;
  final failure = firstFailure([
    checkRequiredText(ValidationField.title, r.title),
    if (r.items.isEmpty)
      const ValidationFailure(
        ValidationField.subtasks,
        ValidationRule.required,
      ),
    if (r.items.length > maxRoutineItems)
      const ValidationFailure(
        ValidationField.subtasks,
        ValidationRule.tooLarge,
      ),
    if ((r.anchor == RoutineAnchor.time) != (minute != null))
      const ValidationFailure(
        ValidationField.startTime,
        ValidationRule.required,
      ),
    if (minute != null) checkRange(ValidationField.startTime, minute, 0, 1439),
    for (final i in r.items) ...[
      checkRequiredText(ValidationField.title, i.title),
      checkRange(
        ValidationField.duration,
        i.durationMin,
        minDurationMin,
        maxDurationMin,
      ),
      checkRange(ValidationField.startTime, i.offsetMin, 0, 1440),
      checkColorKey(i.colorKey),
      checkIconKey(i.iconKey),
    ],
  ]);
  return failure == null ? Ok(r) : Err(failure);
}
