import 'package:dottoday/domain/entities/reveal_hint.dart';
import 'package:timezone/timezone.dart' as tz;

/// Where a hint can show: the row above Today's thread, or a coach mark on
/// the Wake Up card (docs/15 §11). Each asks with its own signals; the
/// one-a-day budget is shared through the records.
enum HintSurface { today, wakeUpCard }

/// What today looks like to the hint scheduler (docs/14 §5): each field is
/// one trigger, already derived from the day (see `hint_signals.dart`).
final class HintSignals {
  const HintSignals({
    required this.daysOfUse,
    this.surface = HintSurface.today,
    this.minimal = true,
    this.wakeUpOffer = false,
    this.alarmStopped = false,
    this.shiftOffered = false,
    this.lateMornings = false,
    this.movedTaskId,
    this.sameMornings = false,
    this.longTaskId,
    this.liveActivityDismissed = false,
    this.overrunsThisWeek = 0,
    this.inFocus = false,
    this.inWindDownReview = false,
    this.lowEnergy = false,
  });

  /// Whole days since the profile was made.
  final int daysOfUse;

  /// Which surface is asking.
  final HintSurface surface;

  /// The minimal layout: its six hints reveal what it hides, so they never
  /// show in the full layout. Discovery shows in both (15 §11).
  final bool minimal;

  /// Wake Up is off on a phone that can ring it (15 §11 promise).
  final bool wakeUpOffer;

  /// The card is open after "I'm up" stopped today's alarm.
  final bool alarmStopped;

  /// The card shows Shift the rest? (a late start).
  final bool shiftOffered;

  /// The last [lateMorningsForHint] mornings were stopped at least
  /// [lateMorningMinutes] after Wake Up, missions off, alarm tier.
  final bool lateMornings;

  /// A task moved [unstickMoves] times with no steps (B3 Unstick).
  final String? movedTaskId;

  /// The last [routineMornings] mornings began with the same three dots.
  final bool sameMornings;

  /// A task longer than [longTaskMinutes] saved without steps (B1).
  final String? longTaskId;

  /// The user dismissed their first Live Activity (A1).
  final bool liveActivityDismissed;

  /// Tasks finished more than [overrunMinutes] after plan this week.
  final int overrunsThisWeek;

  /// Never inside Focus, a Wind Down review or low-energy mode (§5).
  final bool inFocus;
  final bool inWindDownReview;
  final bool lowEnergy;

  bool get _quiet => inFocus || inWindDownReview || lowEnergy;
}

/// The hint to show today, and whether this is its first showing today
/// (the caller then records it: [RevealHint.shownCount] + 1).
typedef HintPick = ({HintId hint, bool firstToday, String? taskId});

/// Most showings of one hint, ever (docs/14 §5 "each hint twice").
const hintMaxShows = 2;

/// [hint]'s showings, ever: twice, or once where 15 §11 says once.
int hintMaxShowsOf(HintId hint) =>
    hint == HintId.wakeUpShift ? 1 : hintMaxShows;

/// The least time between two showings of [hint] (15 §11: the promise
/// returns after 7 days, the mission offer after 30), else none.
Duration hintGapOf(HintId hint) => switch (hint) {
  HintId.wakeUpPromise => const Duration(days: 7),
  HintId.missionOffer => const Duration(days: 30),
  _ => Duration.zero,
};

/// Trigger thresholds (docs/14 §5).
const unstickMoves = 3;
const routineMornings = 3;
const longTaskMinutes = 60;
const weekReviewDays = 14;
const overrunMinutes = 20;
const overrunsForHint = 3;
const lateMorningsForHint = 3;
const lateMorningMinutes = 20;

/// At most one hint per local calendar day, each at most twice ever (or
/// [hintMaxShowsOf]), at least [hintGapOf] apart, never after *Not now*,
/// never in Focus, a Wind Down review or low-energy mode (docs/14 §5).
/// Pure: [nowUtc] comes from the injected Clock.
///
/// A hint already shown today keeps showing until dismissed; otherwise the
/// first hint in [HintId] order triggered on [HintSignals.surface] that
/// still has a showing left.
///
/// ```dart
/// pickHint(signals: s, records: {}, nowUtc: now, zone: berlin);
/// // (hint: HintId.weekReview, firstToday: true, taskId: null) on day 14
/// ```
HintPick? pickHint({
  required HintSignals signals,
  required Map<HintId, RevealHint> records,
  required DateTime nowUtc,
  required tz.Location zone,
}) {
  if (signals._quiet) return null;
  bool today(DateTime? utc) => utc != null && _sameDay(utc, nowUtc, zone);
  final shownToday = records.values.where((r) => today(r.lastShownUtc));
  if (shownToday.isNotEmpty) {
    final r = shownToday.first;
    if (r.dismissedAtUtc != null || !_triggered(r.hintId, signals)) {
      return null;
    }
    return (
      hint: r.hintId,
      firstToday: false,
      taskId: _task(r.hintId, signals),
    );
  }
  for (final hint in HintId.values) {
    final r = records[hint];
    if (r?.dismissedAtUtc != null) continue;
    if ((r?.shownCount ?? 0) >= hintMaxShowsOf(hint)) continue;
    if (r?.lastShownUtc case final last?
        when nowUtc.difference(last) < hintGapOf(hint)) {
      continue;
    }
    if (!_triggered(hint, signals)) continue;
    return (hint: hint, firstToday: true, taskId: _task(hint, signals));
  }
  return null;
}

bool _triggered(HintId hint, HintSignals s) {
  final today = s.surface == HintSurface.today;
  final minimal = today && s.minimal;
  final card = s.surface == HintSurface.wakeUpCard;
  return switch (hint) {
    HintId.unstick => minimal && s.movedTaskId != null,
    HintId.routines => minimal && s.sameMornings,
    HintId.breakDown => minimal && s.longTaskId != null,
    HintId.nextUpWidget => minimal && s.liveActivityDismissed,
    HintId.weekReview => minimal && s.daysOfUse >= weekReviewDays,
    HintId.learnedDefaults => minimal && s.overrunsThisWeek >= overrunsForHint,
    HintId.wakeUpPromise => today && s.wakeUpOffer,
    HintId.wakeUpStartDay => card && s.alarmStopped,
    HintId.wakeUpShift => card && s.shiftOffered,
    // The check's notification text, never a surface (15 §11).
    HintId.wakeUpCheckPing => false,
    HintId.missionOffer => today && s.lateMornings,
  };
}

String? _task(HintId hint, HintSignals s) => switch (hint) {
  HintId.unstick => s.movedTaskId,
  HintId.breakDown => s.longTaskId,
  _ => null,
};

bool _sameDay(DateTime a, DateTime b, tz.Location zone) {
  final x = tz.TZDateTime.from(a, zone);
  final y = tz.TZDateTime.from(b, zone);
  return x.year == y.year && x.month == y.month && x.day == y.day;
}
