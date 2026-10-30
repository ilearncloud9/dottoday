import 'package:dottoday/domain/entities/utc_millis_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'reveal_hint.freezed.dart';
part 'reveal_hint.g.dart';

/// The six progressive-reveal hints of minimal mode (docs/14 §5), in the
/// order the scheduler prefers them when two trigger on the same day.
enum HintId {
  /// Same task moved 3 times → B3 Unstick.
  unstick,

  /// Three mornings with the same first three dots → C2 Routines.
  routines,

  /// A task over 60 min saved without steps → B1 Break it down.
  breakDown,

  /// The first Live Activity dismissed by the user → A1 Next-up widget.
  nextUpWidget,

  /// 14 days of use → D1 Weekly review.
  weekReview,

  /// Three tasks finished > 20 min after plan in a week → C3 defaults.
  learnedDefaults,
}

/// One hint's lifetime record (docs/14 §6 `reveal_hints`), synced so the
/// twice-ever budget holds across devices. One row per user and hint: the
/// id is derived from both (see `revealHintRowId`).
@freezed
abstract class RevealHint with _$RevealHint {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory RevealHint({
    required String id,
    required String userId,
    required HintId hintId,
    @Default(0) int shownCount,
    @UtcMillisConverter() DateTime? lastShownUtc,

    /// Set by *Not now*: the hint never shows again.
    @UtcMillisConverter() DateTime? dismissedAtUtc,
    @UtcMillisConverter() required DateTime createdAt,
    @UtcMillisConverter() required DateTime updatedAt,
  }) = _RevealHint;

  factory RevealHint.fromJson(Map<String, Object?> json) =>
      _$RevealHintFromJson(json);
}
