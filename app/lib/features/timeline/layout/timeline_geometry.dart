import 'dart:math' as math;

import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/layout/day_layout.dart';
import 'package:dottoday/features/timeline/layout/time_scale.dart';
import 'package:dottoday/features/timeline/layout/timeline_day.dart';

/// Density inputs, already multiplied by the text scale.
typedef TimelineDensity = ({
  double pxPerMin,
  double collapsedPxPerMin,
  double minBlockHeight,
});

/// Everything positional about one rendered day, computed once per data or
/// size change (pure; the widgets only read it).
final class TimelineGeometry {
  TimelineGeometry._({
    required this.day,
    required this.scale,
    required this.layout,
    required this.hours,
    required this.coreFrom,
    required this.coreTo,
  });

  /// Builds the geometry of [day] with [blocks] and its [boundary].
  factory TimelineGeometry.build({
    required TimelineDay day,
    required List<Occurrence> blocks,
    required TimeWindow boundary,
    required TimelineDensity density,
    required ({bool before, bool after}) expanded,
  }) {
    final (from, to) = day.coreMinutes(boundary);
    final scale = TimeScale.forDay(
      dayMinutes: day.minutes,
      coreFrom: from,
      coreTo: to,
      pxPerMin: density.pxPerMin,
      collapsedPxPerMin: density.collapsedPxPerMin,
      expandBefore: expanded.before,
      expandAfter: expanded.after,
    );
    return TimelineGeometry._(
      day: day,
      scale: scale,
      layout: layoutDay(
        blocks: blocks,
        day: day,
        scale: scale,
        minHeight: density.minBlockHeight,
      ),
      hours: [for (final h in day.hourMarks) (y: scale.yOf(h.minute), mark: h)],
      coreFrom: from,
      coreTo: to,
    );
  }

  final TimelineDay day;
  final TimeScale scale;
  final DayLayout layout;
  final List<({double y, HourMark mark})> hours;

  /// Core hours in elapsed minutes.
  final double coreFrom;
  final double coreTo;

  bool get hasBeforeZone => coreFrom > 0;
  bool get hasAfterZone => coreTo < day.minutes;

  /// Pixel ranges of the outside-hours zones.
  List<(double, double)> get zones => [
    if (hasBeforeZone) (0, scale.yOf(coreFrom)),
    if (hasAfterZone) (scale.yOf(coreTo), scale.height),
  ];

  /// Total height: the day, or further if the last block's minimum height
  /// runs past midnight.
  double get height => math.max(
    scale.height,
    layout.placements.fold(0, (h, p) => math.max(h, p.bottom)),
  );
}
