import 'dart:math' as math;

/// One stretch of the day axis drawn at a constant density.
final class AxisSegment {
  const AxisSegment(this.fromMin, this.toMin, this.pxPerMin);

  /// Elapsed minutes since the day's start (DST-aware, so a day can be
  /// 1380 or 1500 minutes long).
  final double fromMin;
  final double toMin;
  final double pxPerMin;

  double get height => (toMin - fromMin) * pxPerMin;
}

/// Piecewise-linear mapping between elapsed minutes and pixels. Core hours
/// get full density; the outside-hours zones are compressed until expanded
/// (docs/02 F1 "collapsed outside hours zone", R-17), and the whole day is
/// always laid out, so the bottom of the day is never cut off (R-14).
final class TimeScale {
  TimeScale(this.segments)
    : assert(segments.isNotEmpty),
      _tops = _cumulativeTops(segments);

  /// A day of [dayMinutes] with `[coreFrom, coreTo)` at [pxPerMin] and the
  /// rest at [collapsedPxPerMin] unless [expandBefore]/[expandAfter].
  ///
  /// ```dart
  /// TimeScale.forDay(dayMinutes: 1440, coreFrom: 420, coreTo: 1320,
  ///     pxPerMin: 1.6, collapsedPxPerMin: 0.4).height; // 1440 + 216
  /// ```
  factory TimeScale.forDay({
    required double dayMinutes,
    required double coreFrom,
    required double coreTo,
    required double pxPerMin,
    required double collapsedPxPerMin,
    bool expandBefore = false,
    bool expandAfter = false,
  }) {
    final from = coreFrom.clamp(0, dayMinutes).toDouble();
    final to = coreTo.clamp(from, dayMinutes).toDouble();
    return TimeScale(
      [
        if (from > 0)
          AxisSegment(0, from, expandBefore ? pxPerMin : collapsedPxPerMin),
        AxisSegment(from, to, pxPerMin),
        if (to < dayMinutes)
          AxisSegment(
            to,
            dayMinutes,
            expandAfter ? pxPerMin : collapsedPxPerMin,
          ),
      ].where((s) => s.toMin > s.fromMin).toList(),
    );
  }

  final List<AxisSegment> segments;
  final List<double> _tops;

  static List<double> _cumulativeTops(List<AxisSegment> segments) {
    final tops = <double>[];
    var top = 0.0;
    for (final s in segments) {
      tops.add(top);
      top += s.height;
    }
    return tops;
  }

  double get dayMinutes => segments.last.toMin;

  double get height => _tops.last + segments.last.height;

  /// Pixel offset of [minute], clamped to the day.
  double yOf(double minute) {
    final m = minute.clamp(0, dayMinutes).toDouble();
    for (var i = segments.length - 1; i >= 0; i--) {
      final s = segments[i];
      if (m >= s.fromMin) return _tops[i] + (m - s.fromMin) * s.pxPerMin;
    }
    return 0;
  }

  /// Elapsed minute at pixel [y], clamped to the day (inverse of [yOf]).
  double minuteAt(double y) {
    final py = math.max(0.0, y);
    for (var i = segments.length - 1; i >= 0; i--) {
      if (py >= _tops[i]) {
        final s = segments[i];
        return math.min(s.toMin, s.fromMin + (py - _tops[i]) / s.pxPerMin);
      }
    }
    return 0;
  }
}
