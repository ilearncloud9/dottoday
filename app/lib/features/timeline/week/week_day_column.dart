import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/layout/week_layout.dart';
import 'package:dottoday/features/timeline/week/week_card.dart';
import 'package:dottoday/features/timeline/week/week_pieces.dart';
import 'package:dottoday/shared/dot/pointer_draggable.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';

/// A day column: cards by time, a dotted spine, today's tint and now line,
/// and a drop target that shows where a dragged task would land (M3e.3).
class WeekDayColumn extends StatefulWidget {
  const WeekDayColumn({
    required this.day,
    required this.axisMinutes,
    required this.find,
    required this.dropLabel,
    required this.onDrop,
    required this.onOpen,
    required this.onAdd,
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

  /// "Drop a task here" tapped: Add on this day.
  final VoidCallback onAdd;

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
        final start = _startAt(d.offset, d.data);
        setState(() => _hover = null);
        if (start != null) widget.onDrop(d.data, start);
      },
      builder: (context, _, _) => SizedBox(
        height: _height,
        child: Stack(children: [..._background(context), ..._cards()]),
      ),
    );
  }

  List<Widget> _background(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final day = widget.day;
    final now = day.nowUtc;
    final hover = _hover;
    return [
      if (day.isToday)
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: c.accentTint,
              borderRadius: BorderRadius.circular(DotRadii.cardLarge),
            ),
          ),
        ),
      Positioned(
        left: DotSpace.l,
        top: 0,
        bottom: 0,
        child: CustomPaint(
          size: Size(DotSpace.hairline * 2, _height),
          painter: WeekSpine(color: c.hairline),
        ),
      ),
      if (now != null) _line(c.accent, _y(now), DotSpace.hairline * 2),
      if (hover != null) ..._preview(context, hover),
    ];
  }

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
  ) {
    final t = DotTheme.of(context);
    final top = _y(hover.start);
    return [
      Positioned(
        left: 0,
        right: 0,
        top: top,
        height: hover.minutes * WeekScale.pxPerMinute,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.colors.accentTint,
            border: Border.all(color: t.colors.accent),
            borderRadius: BorderRadius.circular(DotRadii.card),
          ),
        ),
      ),
      Positioned(
        left: 0,
        right: 0,
        top: top - DotSpace.xl,
        child: Center(
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: t.colors.accent,
              shape: const StadiumBorder(),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DotSpace.s,
                vertical: DotSpace.xxs,
              ),
              child: Text(
                widget.dropLabel(hover.start, hover.minutes),
                style: t.styles.rowMeta.copyWith(color: t.colors.onAccent),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _cards() {
    final day = widget.day;
    final boxes = weekColumnLayout(
      [
        for (final task in day.tasks)
          if (day.starts[task.id] case final s?)
            (id: task.id, startUtc: s.startUtc, minutes: s.minutes),
      ],
      axisStartUtc: day.axisStartUtc,
      pxPerMinute: WeekScale.pxPerMinute,
      minHeight: WeekScale.minCard,
      gap: WeekScale.gap,
    );
    final byId = {for (final task in day.tasks) task.id: task};
    final last = boxes.fold(
      0.0,
      (m, b) => b.top + b.height > m ? b.top + b.height : m,
    );
    return [
      for (final b in boxes)
        Positioned(
          left: DotSpace.xs,
          right: DotSpace.xs,
          top: b.top,
          height: b.height,
          child: _card(byId[b.id]!, b.height),
        ),
      if (day.open && last + DotSpace.xxl * 2 < _height)
        Positioned(
          left: DotSpace.xs,
          right: DotSpace.xs,
          top: last + DotSpace.l,
          child: WeekDropBox(
            text: day.freeText,
            onTap: widget.onAdd,
            onTint: day.isToday,
          ),
        ),
    ];
  }

  Widget _card(ThreadTask task, double height) {
    final card = WeekCard(
      task: task,
      height: height,
      onOpen: () => widget.onOpen(task.id),
    );
    if (!task.movable) return card;
    return HoldOrMouseDraggable<String>(
      data: task.id,
      feedback: SizedBox(
        width: DotSize.readableColumn / 4,
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
