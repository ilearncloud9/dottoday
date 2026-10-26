// When Today offers the reality thread and when it promises it instead
// (docs/13 §4.2–§4.3, §9). Pure; the day page feeds it.

/// Whether today's card offers Plan / Reality: once the reality threshold
/// was crossed (on this device, or by the history now), on today's card
/// only — also on a day where nothing has started yet, where Reality shows
/// the plan with "nothing started yet today" (owner, 2026-10-26).
///
/// ```dart
/// offerReality(isToday: true, isSide: false, revealed: true); // true
/// ```
bool offerReality({
  required bool isToday,
  required bool isSide,
  required bool revealed,
}) => isToday && !isSide && revealed;

/// Whether the learning prompts on Today — the day-card caption and the
/// one-time highlight — may show (docs/13 §9): never in low-energy mode,
/// which hides counts, nor in minimal mode. Settings › Learning is not a
/// Today prompt and always shows.
bool showLearningPromptsOnToday({
  required bool lowEnergy,
  required bool minimalMode,
}) => !lowEnergy && !minimalMode;

/// Whether today's card shows "Your reality thread appears after about 10
/// finished tasks · 7 so far": before the reveal, on today's card, unless
/// it was put away on [today] (a local date) — so at most once a day, and
/// back the next day.
bool showLearningCaption({
  required bool isToday,
  required bool revealed,
  required bool promptsOnToday,
  required DateTime today,
  DateTime? putAwayOn,
}) =>
    isToday &&
    !revealed &&
    promptsOnToday &&
    (putAwayOn == null || !_sameDay(putAwayOn, today));

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
