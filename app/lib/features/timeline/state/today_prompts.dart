import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'today_prompts.g.dart';

/// Today's prompts (docs/09 M3f.5): the Day review at Wind Down, the
/// running-late nudge, and the weekly review at Wind Down on the week's last
/// day (11 D1, M12.1), and low-energy mode's "move everything optional
/// to tomorrow?", offered once a day (11 D2, M12.2).
enum TodayPromptKind { review, late, week, lowEnergy }

/// Prompts put away with "Not now", per day, for this session only: a
/// prompt is a suggestion, so it is not worth syncing, and it comes back
/// on the next launch if the day still needs it.
@Riverpod(keepAlive: true)
class DismissedPrompts extends _$DismissedPrompts {
  @override
  Set<(TodayPromptKind, DateTime)> build() => const {};

  void dismiss(TodayPromptKind kind, DateTime day) =>
      state = {...state, (kind, day)};
}
