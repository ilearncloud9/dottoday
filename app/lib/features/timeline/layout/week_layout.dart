/// Where a card sits in a Week board column, in logical px from the top
/// of the hour axis.
typedef WeekCardBox = ({String id, double top, double height});

/// A task to place: its id, start and length (already on this day).
typedef WeekCardInput = ({String id, DateTime startUtc, int minutes});

/// Lays out one day of the Week board (`A-mac-week-alt3-board`): each card
/// at its start time on an axis that begins at [axisStartUtc], [pxPerMinute]
/// tall per minute but never shorter than [minHeight]; a card that would
/// overlap the one above moves down below it ([gap] apart), so titles stay
/// readable and nothing hides another. Earlier starts come first; ties
/// keep the given order.
///
/// ```dart
/// weekColumnLayout(cards, axisStartUtc: sevenAm, pxPerMinute: .6,
///     minHeight: 28, gap: 4).first.top; // 18.0 for a 7:30 task
/// ```
List<WeekCardBox> weekColumnLayout(
  List<WeekCardInput> cards, {
  required DateTime axisStartUtc,
  required double pxPerMinute,
  required double minHeight,
  required double gap,
}) {
  final sorted = [...cards.indexed]
    ..sort((a, b) {
      final byStart = a.$2.startUtc.compareTo(b.$2.startUtc);
      return byStart != 0 ? byStart : a.$1 - b.$1;
    });
  final out = <WeekCardBox>[];
  var floor = double.negativeInfinity;
  for (final (_, c) in sorted) {
    final at = c.startUtc.difference(axisStartUtc).inSeconds / 60 * pxPerMinute;
    final top = at < floor ? floor : at;
    final height = c.minutes * pxPerMinute < minHeight
        ? minHeight
        : c.minutes * pxPerMinute;
    out.add((id: c.id, top: top, height: height));
    floor = top + height + gap;
  }
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
