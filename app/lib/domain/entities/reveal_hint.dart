import 'package:dottoday/domain/entities/utc_millis_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'reveal_hint.freezed.dart';
part 'reveal_hint.g.dart';

/// The progressive-reveal hints: minimal mode's six (docs/14 §5), then Wake
/// Up's discovery (docs/15 §11, M17.6), in the order the scheduler prefers
/// them when two trigger on the same day. All share one budget (owner).
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

  /// Wake Up is off on a phone that can ring it → the promise card on
  /// Today (15 §11 "Update to M17"); again once after 7 days.
  wakeUpPromise,

  /// "I'm up" stopped today's alarm → the coach mark on the card's Start
  /// the day (15 §11 "First dismissal of the alarm").
  wakeUpStartDay,

  /// The card offers Shift the rest? → its coach mark, once (15 §11).
  wakeUpShift,

  /// The Wake Up Check's notification says where to change it (15 §11
  /// "First check ping"). Not a row: the notification's own text.
  wakeUpCheckPing,

  /// Three mornings stopped ≥ 20 min after Wake Up, missions off → the
  /// mission soft reveal (15 §11); again only after 30 days.
  missionOffer,
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
