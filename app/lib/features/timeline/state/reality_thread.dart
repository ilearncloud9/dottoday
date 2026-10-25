import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/learning.dart';
import 'package:dottoday/domain/scheduling/reality.dart';
import 'package:dottoday/shared/dot/thread_day.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reality_thread.g.dart';

/// Whether Today's card shows the Reality thread (11 C3, docs/09 M11.2):
/// a view choice for this session, like the Week/Month switch.
@Riverpod(keepAlive: true)
class RealityMode extends _$RealityMode {
  @override
  bool build() => false;

  void set({required bool on}) => state = on;
}

/// Whether the Plan / Reality toggle is offered: a day where at least one
/// task really started (B1). Before that the two threads are the same.
bool hasActuals(List<Occurrence> blocks) =>
    blocks.any((o) => o.actualStartUtc != null);

/// [blocks] moved to when they really ran, and each task's captions, for
/// `threadEntries(reality:)`: "7:42 – 8:16 · planned 7:30" and "took 34
/// min", "9:10 – now · planned 9:00 – 11:00" and "1 h 14 in", "not
/// started yet". Plain words, never "late" (11 §D).
({List<Occurrence> blocks, Map<String, ThreadReality> reality}) realityThread(
  AppLocalizations l10n,
  ThreadFormat format, {
  required List<Occurrence> blocks,
  required DateTime nowUtc,
  LearningIndex? learning,
}) {
  final day = realityOf(blocks, nowUtc);
  String? usual(Reality r) {
    if (r.kind != RealityKind.underWay) return null;
    final m = _learned(learning, r.planned).usualMinutes;
    return m == null ? null : l10n.learnUsually(format.duration(m));
  }

  return (
    blocks: [for (final r in day) r.shown],
    reality: {
      for (final r in day)
        r.planned.id: _caption(l10n, format, r, nowUtc, usual(r)),
    },
  );
}

Learned _learned(LearningIndex? learning, Occurrence o) =>
    learning?.forTask(title: o.title, seriesId: o.seriesId) ?? Learned.none;

/// The task under way whose usual length differs from its plan by at
/// least [insightFromMinutes], with that length (the insight strip,
/// `B-ios-reality-thread`, M11.3); null otherwise.
({Occurrence task, int usualMinutes})? realityInsight(
  List<Occurrence> blocks,
  DateTime nowUtc,
  LearningIndex? learning,
) {
  for (final r in realityOf(blocks, nowUtc)) {
    if (r.kind != RealityKind.underWay) continue;
    final usual = _learned(learning, r.planned).usualMinutes;
    if (usual == null) continue;
    if ((usual - r.planned.durationMin).abs() >= insightFromMinutes) {
      return (task: r.planned, usualMinutes: usual);
    }
  }
  return null;
}

/// A usual length this close to the plan is not worth a strip.
const insightFromMinutes = 15;

/// Insight strips put away with OK, by occurrence id, this session.
@Riverpod(keepAlive: true)
class DismissedInsights extends _$DismissedInsights {
  @override
  Set<String> build() => const {};

  void dismiss(String id) => state = {...state, id};
}

ThreadReality _caption(
  AppLocalizations l10n,
  ThreadFormat f,
  Reality r,
  DateTime now,
  String? usual,
) {
  final shown = r.shown;
  final plan = r.planned;
  final took = r.tookMinutes(now);
  switch (r.kind) {
    case RealityKind.finished:
      return ThreadReality(
        range: f.range(f.time(shown.startUtc!), f.time(shown.endUtc!)),
        meta: r.startShiftMinutes == 0
            ? null
            : l10n.realityPlanned(f.time(plan.startUtc!)),
        note: l10n.realityTook(f.duration(took!)),
        ghost: _ghost(r),
      );
    case RealityKind.underWay:
      return ThreadReality(
        range: f.range(f.time(shown.startUtc!), l10n.realityNow),
        meta: l10n.realityPlanned(
          f.range(f.time(plan.startUtc!), f.time(plan.endUtc!)),
        ),
        note: took! < 1 ? null : l10n.realityRunning(f.duration(took)),
        ghost: _ghost(r),
        underWay: true,
        usual: usual,
      );
    case RealityKind.notStartedYet:
      return ThreadReality(meta: l10n.realityNotStarted);
    case RealityKind.asPlanned:
      return const ThreadReality();
  }
}

GhostShift _ghost(Reality r) => switch (r.startShiftMinutes) {
  0 => GhostShift.none,
  > 0 => GhostShift.earlier,
  _ => GhostShift.later,
};
