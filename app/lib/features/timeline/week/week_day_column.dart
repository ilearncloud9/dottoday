import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/layout/week_layout.dart';
import 'package:dottoday/features/timeline/week/grid_block.dart';
import 'package:dottoday/features/timeline/week/grid_column_pieces.dart';
import 'package:dottoday/features/timeline/week/grid_scale.dart';
import 'package:dottoday/features/timeline/week/grid_thread.dart';
import 'package:dottoday/features/timeline/week/week_pieces.dart';
import 'package:dottoday/shared/dot/pointer_draggable.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';

/// A day column of the hour grid (E-FullA-v2 Week, M19.2 part 2): its
/// hour lines and left divider, today's tint, the thread behind the
/// blocks, the blocks at their times (side by side where they overlap),
/// today's now line and dot, and a drop target that shows where a dragged
/// task would land (M3e.3).
class WeekDayColumn extends StatefulWidget {
  const WeekDayColumn({
    required this.day,
    required this.axisMinutes,
    required this.find,
    required this.dropLabel,
    required this.onDrop,
    required this.onOpen,
    this.onCue,
    this.onMove,
    this.onEmpty,
    super.key,
  });

  final WeekDayView day;
  final int axisMinutes;

  /// A click on the grid's free space: the Workspace puts its inspector
  /// away (ED-391).
  final VoidCallback? onEmpty;

  /// The task being dragged (a week's or the Inbox's).
  final Occurrence? Function(String id) find;

  /// "Sat · 10:00 – 11:30" for a task of [minutes] starting at [startUtc].
  final String Function(DateTime startUtc, int minutes) dropLabel;

  /// Moves task [id] to [startUtc] on this day.
  final void Function(String id, DateTime startUtc) onDrop;
  final ValueChanged<String> onOpen;

  /// Moves task [id] by [minutes] and [days] (Alt+arrows, ED-095 keys).
  final void Function(String id, int minutes, int days)? onMove;

  /// A card's Smallest step or Unstick cue tapped (M10.6, M10.7).
  final ValueChanged<String>? onCue;

  @override
  State<WeekDayColumn> createState() => _WeekDayColumnState();
}

/// A leaf: the hover preview only.
class _WeekDayColumnState extends State<WeekDayColumn> {
  ({DateTime start, int minutes})? _hover;

  GridScale get _scale => GridScale.of(context);

  double get _height => widget.axisMinutes * _scale.pxPerMinute;

  DateTime? _startAt(Offset global, String id) {
    final o = widget.find(id);
    final box = context.findRenderObject() as RenderBox?;
    if (o == null || box == null) return null;
    return weekDropStart(
      y: box.globalToLocal(global).dy,
      axisStartUtc: widget.day.axisStartUtc,
      pxPerMinute: _scale.pxPerMinute,
      axisMinutes: widget.axisMinutes,
      durationMin: o.durationMin,
      snapMinutes: widget.day.snapMinutes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onMove: (d) {
        final start = _startAt(d.offset, d.data);
        final o = widget.find(d.data);
        setState(
          () => _hover = start == null || o == null
              ? null
              : (start: start, minutes: o.durationMin),
        );
      },
      onLeave: (_) => setState(() => _hover = null),
      onAcceptWithDetails: (d) {
        // A layout switch mid-drag cancels it (ED-100).
        if (!DragSession.live) return;
        final start = _startAt(d.offset, d.data);
        setState(() => _hover = null);
        if (start != null) widget.onDrop(d.data, start);
      },
      builder: (context, _, _) => SizedBox(
        height: _height,
        child: Stack(
          children: [..._background(context), ..._cards(), ..._over(context)],
        ),
      ),
    );
  }

  List<Widget> _background(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final day = widget.day;
    return [
      Positioned.fill(
        child: CustomPaint(
          painter: GridLines(
            line: c.gridLine,
            divider: c.gridDivider,
            tint: day.isToday ? c.gridToday : null,
            firstLine: GridScale.leadMinutes * _scale.pxPerMinute,
          ),
        ),
      ),
      // Over the painted lines (a painter takes every hit), under the
      // blocks: a click on free grid.
      if (widget.onEmpty case final empty?)
        Positioned.fill(
          child: ExcludeSemantics(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: empty,
            ),
          ),
        ),
      Positioned(
        left: _scale.threadX,
        top: 0,
        bottom: 0,
        width: DotSize.gridThread,
        child: CustomPaint(painter: _thread(c)),
      ),
    ];
  }

  /// Over the blocks: today's now line and dot, and the drop preview.
  List<Widget> _over(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final now = widget.day.nowUtc;
    final hover = _hover;
    return [
      if (now != null) ..._now(c, _y(now)),
      if (hover != null) ..._preview(context, hover),
    ];
  }

  /// The thread through the blocks' dots (lane 0 of an overlap carries it).
  GridThread _thread(DotColors c) {
    final t = DotTheme.of(context);
    final byId = {for (final task in widget.day.tasks) task.id: task};
    final dots = <GridThreadDot>[];
    var bottom = 0.0;
    for (final b in _boxes()) {
      final task = byId[b.id]!;
      if (b.lane == 0) {
        final pill = task.minutes < _scale.pillUnder;
        final live = task.state == DotState.live;
        dots.add((
          y: b.top + (pill ? b.height / 2 : _scale.ringCentre(live: live)),
          color: t.tasks[task.color].color,
        ));
      }
      if (b.top + b.height > bottom) bottom = b.top + b.height;
    }
    final day = widget.day;
    final now = day.nowUtc;
    return GridThread(
      dots: dots,
      lastBottom: bottom,
      nowY: now != null
          ? _y(now)
          : day.open
          ? double.negativeInfinity
          : double.infinity,
      ahead: c.threadAhead,
    );
  }

  /// Today's stretch of the now line and the dot on its thread.
  List<Widget> _now(DotColors c, double y) => [
    _line(c.nowLineToday, y, DotSpace.hairline * 1.5),
    Positioned(
      left: _scale.threadX + (DotSize.gridThread - DotSize.gridNowDot) / 2,
      top: y - DotSize.gridNowDot / 2,
      width: DotSize.gridNowDot,
      height: DotSize.gridNowDot,
      child: const GridNowDot(),
    ),
  ];

  double _y(DateTime utc) =>
      utc.difference(widget.day.axisStartUtc).inSeconds /
      60 *
      _scale.pxPerMinute;

  Widget _line(Color color, double y, double width) => Positioned(
    left: 0,
    right: 0,
    top: y - width / 2,
    height: width,
    child: ColoredBox(color: color),
  );

  List<Widget> _preview(
    BuildContext context,
    ({DateTime start, int minutes}) hover,
  ) => gridDropPreview(
    context,
    top: _y(hover.start),
    height: hover.minutes * _scale.pxPerMinute,
    label: widget.dropLabel(hover.start, hover.minutes),
  );

  List<WeekCardBox> _boxes() {
    final day = widget.day;
    return weekColumnLayout(
      [
        for (final task in day.tasks)
          if (day.starts[task.id] case final s?)
            (id: task.id, startUtc: s.startUtc, minutes: s.minutes),
      ],
      axisStartUtc: day.axisStartUtc,
      pxPerMinute: _scale.pxPerMinute,
      minHeight: _scale.minCard,
    );
  }

  List<Widget> _cards() {
    final day = widget.day;
    final boxes = _boxes();
    final byId = {for (final task in day.tasks) task.id: task};
    final stacked = _scale.touch;
    return [
      for (final b in boxes)
        Positioned.fill(
          top: b.top,
          bottom: null,
          child: SizedBox(
            height: b.height,
            child: GridLane(
              lane: b.lane,
              lanes: b.lanes,
              stacked: stacked,
              child: _card(
                byId[b.id]!,
                b.height,
                narrow: stacked ? b.lane > 0 : b.lanes > 1,
                over: stacked && b.lane > 0,
              ),
            ),
          ),
        ),
    ];
  }

  Widget _card(
    ThreadTask task,
    double height, {
    required bool narrow,
    required bool over,
  }) => GridBlock(
    task: task,
    height: height,
    narrow: narrow,
    over: over,
    picked: widget.day.pickedId == task.id,
    onOpen: () => widget.onOpen(task.id),
    onCue: switch (widget.onCue) {
      final cue? => () => cue(task.id),
      null => null,
    },
    onMove: switch (widget.onMove) {
      final move? => ({int steps = 0, int days = 0}) => move(
        task.id,
        steps * widget.day.snapMinutes,
        days,
      ),
      null => null,
    },
  );
}
