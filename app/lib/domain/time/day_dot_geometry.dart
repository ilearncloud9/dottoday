/// Where a day dot's ring is what (docs/15 W6, owner 2026-10-31: one
/// geometry for every painter): from the top, the waking day runs clockwise
/// from Wake Up to Wind Down over [dayEnd] of the ring, and the night fills
/// the rest round to the next Wake Up. Without the night (`showNightArc`
/// off, or no next Wake Up) the day takes the whole ring, as before M17.5.
///
/// Painters draw it as is: `DayDot`, `WeekDayDot`, and, through the
/// snapshot's `night_start`, the Mac menu bar and the iOS and Android
/// widgets.
final class DayDotGeometry {
  const DayDotGeometry({required this.dayEnd, required this.progress});

  /// A dot filled to [share] of a whole-ring day (onboarding, the lock
  /// screen): no night.
  const DayDotGeometry.filled(double share) : this(dayEnd: 1, progress: share);

  /// Share of the ring the waking day takes, 0–1; 1 is no night arc.
  final double dayEnd;

  /// Share of the ring filled so far, 0–[dayEnd].
  final double progress;

  bool get hasNight => dayEnd < 1;

  /// The waking day's share elapsed, 0–1, whatever the night takes.
  double get dayShare => dayEnd <= 0 ? 0 : (progress / dayEnd).clamp(0, 1);

  @override
  bool operator ==(Object other) =>
      other is DayDotGeometry &&
      other.dayEnd == dayEnd &&
      other.progress == progress;

  @override
  int get hashCode => Object.hash(dayEnd, progress);
}

/// The smallest share the day keeps, so a long night never hides it.
const _minDay = 0.25;

/// [DayDotGeometry] of a day from [wakeUtc] to [windDownUtc] at [nowUtc],
/// with the night up to [nextWakeUtc] when [night] is on.
///
/// ```dart
/// dayDotGeometry(wakeUtc: w7, windDownUtc: w23, nextWakeUtc: w7tomorrow,
///     nowUtc: w15); // dayEnd 16/24, progress 8/24
/// ```
DayDotGeometry dayDotGeometry({
  required DateTime wakeUtc,
  required DateTime windDownUtc,
  required DateTime nowUtc,
  DateTime? nextWakeUtc,
  bool night = true,
}) {
  final day = windDownUtc.difference(wakeUtc).inSeconds;
  if (day <= 0) return const DayDotGeometry(dayEnd: 1, progress: 0);
  final elapsed = (nowUtc.difference(wakeUtc).inSeconds / day).clamp(0.0, 1.0);
  final whole = nextWakeUtc?.difference(wakeUtc).inSeconds ?? 0;
  if (!night || whole <= day) {
    return DayDotGeometry(dayEnd: 1, progress: elapsed);
  }
  final end = (day / whole).clamp(_minDay, 1.0);
  return DayDotGeometry(dayEnd: end, progress: elapsed * end);
}
