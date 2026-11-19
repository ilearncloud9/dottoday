import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/layout/week_layout.dart';
import 'package:dottoday/features/timeline/week/grid_column_pieces.dart';
import 'package:dottoday/features/timeline/week/grid_thread.dart';
import 'package:dottoday/features/timeline/week/week_card.dart';
import 'package:dottoday/features/timeline/week/week_pieces.dart';
import 'package:dottoday/shared/dot/pointer_draggable.dart';
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
    super.key,
  });

  final WeekDayView day;
  final int axisMinutes;

  /// The task being dragged (a week's or the Inbox's).
  final Occurrence? Function(String id) find;

  /// "Sat · 10:00 – 11:30" for a task of [minutes] starting at [startUtc].
  final String Function(DateTime startUtc, int minutes) dropLabel;

  /// Moves task [id] to [startUtc] on this day.
  final void Function(String id, DateTime startUtc) onDrop;
  final ValueChanged<String> onOpen;

  /// A card's Smallest step or Unstick cue tapped (M10.6, M10.7).
  final ValueChanged<String>? onCue;

  @override
  State<WeekDayColumn> createState() => _WeekDayColumnState();
}

/// A leaf: the hover preview only.
class _WeekDayColumnState extends State<WeekDayColumn> {
  ({DateTime start, int minutes})? _hover;

  double get _height => widget.axisMinutes * WeekScale.pxPerMinute;

  DateTime? _startAt(Offset global, String id) {
    final o = widget.find(id);
    final box = context.findRenderObject() as RenderBox?;
    if (o == null || box == null) return null;
    return weekDropStart(
      y: box.globalToLocal(global).dy,
      axisStartUtc: widget.day.axisStartUtc,
      pxPerMinute: WeekScale.pxPerMinute,
      axisMinutes: widget.axisMinutes,
      durationMin: o.durationMin,
      snapMinutes: 15,
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
            firstLine: WeekScale.leadMinutes * WeekScale.pxPerMinute,
          ),
        ),
      ),
      Positioned(
        left: DotSize.gridThreadX,
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
        final pill = task.minutes < WeekScale.pillUnder;
        dots.add((
          y: b.top + (pill ? b.height / 2 : _ringCentre),
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

  /// A block's ring centre below its top: 5 in, 32 across.
  static const _ringCentre =
      DotSpace.xs + DotSpace.hairline + DotSize.gridRing / 2;

  /// Today's stretch of the now line and the dot on its thread.
  List<Widget> _now(DotColors c, double y) => [
    _line(c.nowLineToday, y, DotSpace.hairline * 1.5),
    Positioned(
      left: DotSize.gridThreadX + (DotSize.gridThread - DotSize.gridNowDot) / 2,
      top: y - DotSize.gridNowDot / 2,
      width: DotSize.gridNowDot,
      height: DotSize.gridNowDot,
      child: const GridNowDot(),
    ),
  ];

  double _y(DateTime utc) =>
      utc.difference(widget.day.axisStartUtc).inSeconds /
      60 *
      WeekScale.pxPerMinute;

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
    height: hover.minutes * WeekScale.pxPerMinute,
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
      pxPerMinute: WeekScale.pxPerMinute,
      minHeight: WeekScale.minCard,
    );
  }

  List<Widget> _cards() {
    final day = widget.day;
    final boxes = _boxes();
    final byId = {for (final task in day.tasks) task.id: task};
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
              child: _card(byId[b.id]!, b.height, narrow: b.lanes > 1),
            ),
          ),
        ),
    ];
  }

  Widget _card(ThreadTask task, double height, {required bool narrow}) {
    final card = WeekCard(
      task: task,
      height: height,
      narrow: narrow,
      onOpen: () => widget.onOpen(task.id),
      onCue: switch (widget.onCue) {
        final cue? => () => cue(task.id),
        null => null,
      },
    );
    if (!task.movable) return card;
    return HoldOrMouseDraggable<String>(
      data: task.id,
      feedback: SizedBox(
        width: DotSize.gridColumn - DotSize.gridInset * 2,
        height: height,
        child: card,
      ),
      childWhenDragging: Opacity(opacity: TaskAlpha.done, child: card),
      callbacks: DragCallbacks(
        onDragStarted: () {},
        onDragUpdate: (_) {},
        onDragEnd: (_) {},
      ),
      child: card,
    );
  }
}
