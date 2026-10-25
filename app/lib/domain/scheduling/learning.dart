import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/suggestions/suggestion_service.dart';

/// What the user's own history says about a task (11 C3 learning, docs/09
/// M11.3): local, rule-based, from actual timestamps only (B1).
final class Learned {
  const Learned({
    required this.samples,
    this.usualMinutes,
    this.startOffsetMinutes,
  });

  /// Occurrences with an actual start and end it was taken from.
  final int samples;

  /// Median actual length, rounded to 5 minutes; null under
  /// [learningMinSamples].
  final int? usualMinutes;

  /// Median of actual start − planned start: positive when it usually
  /// starts after the plan. Null under [learningMinSamples].
  final int? startOffsetMinutes;

  static const none = Learned(samples: 0);
}

/// How many recent occurrences are looked at, per task.
const learningWindow = 10;

/// Fewer samples than this say nothing.
const learningMinSamples = 3;

/// The user's tasks with actual timestamps, indexed by normalised title
/// and by series, so each lookup is cheap.
final class LearningIndex {
  LearningIndex._(this._byTitle, this._bySeries);

  /// From [history] (any order, any length; deleted rows are skipped).
  factory LearningIndex.from(Iterable<Occurrence> history) {
    final ran = [
      for (final o in history)
        if (o.deletedAt == null && _span(o) != null) o,
    ]..sort((a, b) => b.actualStartUtc!.compareTo(a.actualStartUtc!));
    final byTitle = <String, List<Occurrence>>{};
    final bySeries = <String, List<Occurrence>>{};
    for (final o in ran) {
      (byTitle[normaliseTitle(o.title)] ??= []).add(o);
      if (o.seriesId case final s?) (bySeries[s] ??= []).add(o);
    }
    return LearningIndex._(byTitle, bySeries);
  }

  static final empty = LearningIndex._(const {}, const {});

  final Map<String, List<Occurrence>> _byTitle;
  final Map<String, List<Occurrence>> _bySeries;

  /// What the last [learningWindow] runs of [title] — or of [seriesId]'s
  /// repeats, so a renamed repeat keeps its history — say.
  ///
  /// ```dart
  /// index.forTask(title: 'Deep work').usualMinutes; // 140
  /// ```
  Learned forTask({required String title, String? seriesId}) {
    final seen = <String>{};
    final rows = [
      for (final o in [
        ...?_bySeries[seriesId],
        ...?_byTitle[normaliseTitle(title)],
      ])
        if (seen.add(o.id)) o,
    ]..sort((a, b) => b.actualStartUtc!.compareTo(a.actualStartUtc!));
    final recent = rows.take(learningWindow).toList();
    if (recent.length < learningMinSamples) {
      return Learned(samples: recent.length);
    }
    final usual = _median([for (final o in recent) _span(o)!]);
    final offsets = [
      for (final o in recent)
        if (o.startUtc != null)
          o.actualStartUtc!.difference(o.startUtc!).inMinutes,
    ];
    return Learned(
      samples: recent.length,
      usualMinutes: ((usual / 5).round() * 5).clamp(5, 1440),
      startOffsetMinutes: offsets.length < learningMinSamples
          ? null
          : _median(offsets).round(),
    );
  }
}

/// Actual minutes [o] ran, or null without a real span (never inferred).
int? _span(Occurrence o) {
  final start = o.actualStartUtc;
  final end = o.actualEndUtc;
  if (start == null || end == null || !end.isAfter(start)) return null;
  final minutes = end.difference(start).inMinutes;
  return minutes < 1 || minutes > 1440 ? null : minutes;
}

/// The median: one outlier among ten never moves it far.
double _median(List<int> values) {
  final sorted = [...values]..sort();
  final mid = sorted.length ~/ 2;
  return sorted.length.isOdd
      ? sorted[mid].toDouble()
      : (sorted[mid - 1] + sorted[mid]) / 2;
}

/// The Running late amount [learned] suggests for a task planned at
/// [plannedMinutes] (11 C3 "used by C1", docs/09 M11.3): the smallest of
/// [choices] (ascending) covering how much longer it usually takes, else
/// the largest; null when it usually fits its plan.
///
/// ```dart
/// lateAmountFor(60, learned /* usually 75 */, [5, 15, 30]); // 15
/// ```
int? lateAmountFor(int plannedMinutes, Learned learned, List<int> choices) {
  final usual = learned.usualMinutes;
  if (usual == null || usual <= plannedMinutes || choices.isEmpty) {
    return null;
  }
  final extra = usual - plannedMinutes;
  return choices.firstWhere((c) => c >= extra, orElse: () => choices.last);
}
