import 'package:dottoday/domain/snapshot/day_snapshot.dart';

/// What the Live Activity (iOS, M9.3) and the Android ongoing notification
/// (M9.4) show at a moment: one focus dot and the two after it. Both
/// surfaces follow the same lifecycle (docs/11 A1):
///
/// - shown while a dot is live, or the next one starts within [lead];
/// - kept for [grace] after the planned end of a dot not yet done (an
///   overrun is when the reminder matters most);
/// - gone on Done, or once nothing is live or near.
final class LiveDotPlan {
  const LiveDotPlan({
    required this.focus,
    required this.isLive,
    required this.next,
    required this.dayDone,
    required this.dayTotal,
  });

  static const lead = Duration(minutes: 60);
  static const grace = Duration(minutes: 30);

  /// The dot the surface is about.
  final SnapshotDot focus;

  /// Under way (or overrunning); false = coming up within [lead].
  final bool isLive;

  /// Up to two dots after [focus], so the surface can name what's next
  /// without an update.
  final List<SnapshotDot> next;

  final int dayDone;
  final int dayTotal;

  /// When the surface ends by itself: [grace] after the planned end.
  DateTime get endsAtUtc => focus.endUtc.add(grace);
}

/// The plan for [snapshot] at [nowUtc], or null when nothing should show.
///
/// ```dart
/// liveDotPlan(snapshot, now)?.focus.title; // 'Deep work: roadmap'
/// ```
LiveDotPlan? liveDotPlan(DaySnapshot snapshot, DateTime nowUtc) {
  final open = [
    for (final d in snapshot.dots)
      if (!d.done) d,
  ];
  bool started(SnapshotDot d) => !d.startUtc.isAfter(nowUtc);
  // A dot in its planned time wins over one overrunning its grace.
  final running = open.where((d) => started(d) && d.endUtc.isAfter(nowUtc));
  final overrun = open.where(
    (d) => started(d) && d.endUtc.add(LiveDotPlan.grace).isAfter(nowUtc),
  );
  final soon = open.where(
    (d) => !started(d) && !d.startUtc.isAfter(nowUtc.add(LiveDotPlan.lead)),
  );
  final live = running.firstOrNull ?? overrun.firstOrNull;
  final focus = live ?? soon.firstOrNull;
  if (focus == null) return null;
  return LiveDotPlan(
    focus: focus,
    isLive: live != null,
    next: [
      for (final d in open)
        if (d.startUtc.isAfter(focus.startUtc) ||
            (d.startUtc == focus.startUtc && d.id.compareTo(focus.id) > 0))
          d,
    ].take(DaySnapshot.nextCount).toList(),
    dayDone: snapshot.dayDone,
    dayTotal: snapshot.dayTotal,
  );
}

/// When [liveDotPlan] next changes by itself (a dot coming within the
/// lead, starting, or passing its grace), after [nowUtc]; null when no
/// such moment is in the snapshot. Lets an open app re-plan on time.
DateTime? nextPlanChange(DaySnapshot snapshot, DateTime nowUtc) {
  final moments = [
    for (final d in snapshot.dots)
      if (!d.done) ...[
        d.startUtc.subtract(LiveDotPlan.lead),
        d.startUtc,
        d.endUtc.add(LiveDotPlan.grace),
      ],
  ].where((t) => t.isAfter(nowUtc)).toList()..sort();
  return moments.firstOrNull;
}
