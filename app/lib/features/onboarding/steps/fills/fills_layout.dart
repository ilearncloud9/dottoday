import 'dart:math' as math;

import 'package:dottoday/core/theme/dot_theme.dart';

/// What a row on What fills your days' thread is.
enum FillRowKind {
  wake,
  pick,

  /// The nudge's subject (`.trow.task`): a filled 44 dot, never shrunk.
  task,
  wind,
}

/// A row to place: its kind and its minute.
typedef FillRowSpec = ({FillRowKind kind, int minute});

/// How far a row reaches above and below its line (its dot and words);
/// only used at large text, where words wrap.
typedef FillRowRoom = ({double above, double below});

/// Where the rows sit (`threadHTML`): their heights, whether the thread
/// is full (rows shrunk), the thread's ends and the NOW line.
typedef FillThreadLayout = ({
  List<double> ys,
  bool compact,
  double top,
  double bottom,
  double now,
});

/// The gap the prototype keeps between [a] and [b]: 52, 46 next to a
/// pick, 40 between picks; times [scale] at large text.
double _gap(FillRowSpec a, FillRowSpec b, double scale) {
  final picks = [a, b].where((r) => r.kind == FillRowKind.pick).length;
  return scale *
      switch (picks) {
        2 => OnbSize.gapPicks,
        1 => OnbSize.gapOne,
        _ => OnbSize.gapAnchors,
      };
}

/// The gaps and the room at each end: the prototype's, or at large text
/// ([room] given) wide enough for each row's wrapped words.
({List<double> gaps, double top, double bottom}) _spacing(
  List<FillRowSpec> rows,
  double scale,
  List<FillRowRoom>? room,
) {
  final pad = OnbSize.threadPad * scale;
  final gaps = [
    for (var i = 1; i < rows.length; i++)
      math.max(
        _gap(rows[i - 1], rows[i], scale),
        room == null ? 0.0 : room[i - 1].below + room[i].above + OnbSize.nowGap,
      ),
  ];
  return (
    gaps: gaps,
    top: room == null ? pad : math.max(pad, room.first.above),
    bottom: room == null ? pad : math.max(pad, room.last.below),
  );
}

/// The least height the thread needs for [rows] without shrinking: what
/// the step keeps it at large text, scrolling if it must (ED-488).
double fillThreadHeight(
  List<FillRowSpec> rows, {
  double scale = 1,
  List<FillRowRoom>? room,
}) {
  final s = _spacing(rows, scale, room);
  return s.top + s.gaps.fold<double>(0, (a, b) => a + b) + s.bottom;
}

/// Places [rows] (in time order, Wind Down last) on a thread [height]
/// high for a day from [wake] to [wind], with [now] clamped into it.
/// Each row goes at its time, 28 in from either end; rows then keep at
/// least 52 apart (46 next to a pick, 40 between picks), all of those
/// gaps shrunk together when they don't fit; first pushed down, then
/// pulled up, so the last row stays at Wind Down and every row stays
/// inside the thread (ED-488). At large text ([scale], [room]; the
/// prototype has none) the gaps and ends grow with the words.
///
/// ```dart
/// layoutFillThread(rows, wake: 420, wind: 1380, now: 581, height: 400)
///   .ys.last; // 372: Wind Down, 28 from the bottom
/// ```
FillThreadLayout layoutFillThread(
  List<FillRowSpec> rows, {
  required int wake,
  required int wind,
  required int now,
  required double height,
  double scale = 1,
  List<FillRowRoom>? room,
}) {
  final s = _spacing(rows, scale, room);
  final span = math.max(1, height - s.top - s.bottom);
  double y(int m) =>
      s.top + (m.clamp(wake, wind) - wake) / math.max(1, wind - wake) * span;

  final ys = [for (final r in rows) y(r.minute)];
  final need = s.gaps.fold<double>(0, (a, b) => a + b);
  final k = need == 0 ? 1.0 : math.min(1, span / need).toDouble();
  for (var i = 1; i < ys.length; i++) {
    ys[i] = math.max(ys[i], ys[i - 1] + s.gaps[i - 1] * k);
  }
  // Keep the last row at the thread's end (the prototype lets it run
  // past, under the chips; ED-488).
  ys.last = math.min(ys.last, height - s.bottom);
  for (var i = ys.length - 2; i >= 0; i--) {
    ys[i] = math.min(ys[i], ys[i + 1] - s.gaps[i] * k);
  }
  return (ys: ys, compact: k < 1, top: ys.first, bottom: ys.last, now: y(now));
}
