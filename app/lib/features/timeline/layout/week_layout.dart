/// Where a block sits in an hour-grid column, in logical px from the top
/// of the hour axis: [lane] of [lanes] side by side when tasks overlap.
typedef WeekCardBox = ({
  String id,
  double top,
  double height,
  int lane,
  int lanes,
});

/// A task to place: its id, start and length (already on this day).
typedef WeekCardInput = ({String id, DateTime startUtc, int minutes});

/// Lays out one day of the hour grid (E-FullA-v2 Week, M19.2 part 2):
/// each block at its start on an axis that begins at [axisStartUtc],
/// [pxPerMinute] tall per minute but never shorter than [minHeight].
/// Tasks whose blocks overlap share the column side by side: each takes
/// the first free lane, and every block of an overlapping run knows how
/// many lanes the run uses. Earlier starts come first; ties keep the
/// given order.
///
/// ```dart
/// weekColumnLayout([deep, call], axisStartUtc: sevenAm, pxPerMinute: 1.4,
///     minHeight: 21); // deep lane 0 of 2, call lane 1 of 2
/// ```
List<WeekCardBox> weekColumnLayout(
  List<WeekCardInput> cards, {
  required DateTime axisStartUtc,
  required double pxPerMinute,
  required double minHeight,
}) {
  final sorted = [...cards.indexed]
    ..sort((a, b) {
      final byStart = a.$2.startUtc.compareTo(b.$2.startUtc);
      return byStart != 0 ? byStart : a.$1 - b.$1;
    });
  final out = <WeekCardBox>[];
  // The run of overlapping blocks being placed: its lanes' bottoms.
  final laneEnds = <double>[];
  var runStart = 0;
  var runEnd = double.negativeInfinity;
  void closeRun() {
    for (var i = runStart; i < out.length; i++) {
      out[i] = (
        id: out[i].id,
        top: out[i].top,
        height: out[i].height,
        lane: out[i].lane,
        lanes: laneEnds.length,
      );
    }
    laneEnds.clear();
    runStart = out.length;
  }

  for (final (_, c) in sorted) {
    final top =
        c.startUtc.difference(axisStartUtc).inSeconds / 60 * pxPerMinute;
    final scaled = c.minutes * pxPerMinute;
    final height = scaled < minHeight ? minHeight : scaled;
    if (top >= runEnd) closeRun();
    var lane = laneEnds.indexWhere((end) => end <= top);
    if (lane < 0) {
      lane = laneEnds.length;
      laneEnds.add(0);
    }
    laneEnds[lane] = top + height;
    if (top + height > runEnd) runEnd = top + height;
    out.add((id: c.id, top: top, height: height, lane: lane, lanes: 1));
  }
  closeRun();
  return out;
}

/// The start a drop at [y] px down the axis means: [axisStartUtc] plus the
/// minutes, snapped to [snapMinutes] and kept inside the axis' [minutes].
DateTime weekDropStart({
  required double y,
  required DateTime axisStartUtc,
  required double pxPerMinute,
  required int axisMinutes,
  required int durationMin,
  required int snapMinutes,
}) {
  final raw = (y / pxPerMinute).round();
  final snapped = (raw / snapMinutes).round() * snapMinutes;
  final last = axisMinutes - durationMin;
  final minute = snapped.clamp(0, last < 0 ? 0 : last);
  return axisStartUtc.add(Duration(minutes: minute));
}
