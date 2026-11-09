import 'package:dottoday/domain/entities/reveal_hint.dart';
import 'package:dottoday/domain/onboarding/starter_habits.dart';
import 'package:uuid/uuid.dart';

/// Ids derived from their owner and meaning instead of drawn at random
/// (CR-160 criterion 8): two devices, or a guest adopted into an account,
/// that make "the same" row make one row, which sync merges, never two.

/// One row per user and hint, on every device: a name-based UUID (v5)
/// of both, so two devices showing the same hint update one row.
///
/// ```dart
/// revealHintRowId(userId, HintId.unstick) ==
///     revealHintRowId(userId, HintId.unstick); // true
/// ```
String revealHintRowId(String userId, HintId hint) =>
    const Uuid().v5(Namespace.url.value, 'dottoday:hint:$userId:${hint.name}');

/// The starter [habit] planted on [day] (a local date) for [userId]: the
/// same person onboarding on two devices plants one task, not two.
///
/// ```dart
/// starterTaskId(userId, StarterHabit.lunch, DateTime(2026, 10, 22));
/// ```
String starterTaskId(String userId, StarterHabit habit, DateTime day) =>
    const Uuid().v5(
      Namespace.url.value,
      'dottoday:starter:$userId:${habit.name}:'
      '${day.year}-${day.month}-${day.day}',
    );
