import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/thread_picker_pieces.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The When picker's day bar (E-Phones-2 "Move (the When picker)",
/// ED-099): the day from [fromMinute] (Wake Up) to [toMinute] (Wind Down)
/// as a dashed line, the day's other tasks as pills in their colours, and
/// a ring at [startMinute] that a drag or tap moves, snapped to
/// [snapMinutes]. Arrow keys move it a step; a screen reader hears a
/// slider whose value is [rangeText]. Hours ([hourText]) under it.
class DayBar extends StatefulWidget {
  const DayBar({
    required this.blocks,
    required this.fromMinute,
    required this.toMinute,
    required this.startMinute,
    required this.durationMin,
    required this.snapMinutes,
    required this.rangeText,
    required this.hourText,
    required this.onChanged,
    super.key,
  });

  final List<PickerBlock> blocks;
  final int fromMinute;
  final int toMinute;
  final int startMinute;
  final int durationMin;
  final int snapMinutes;
  final String Function(int startMinute) rangeText;

  /// "7 AM" for a minute of the day.
  final String Function(int minute) hourText;
  final ValueChanged<int> onChanged;

  @override
  State<DayBar> createState() => _DayBarState();
}

/// A leaf: only its focus, for the arrow keys.
class _DayBarState extends State<DayBar> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  int get _last => (widget.toMinute - widget.durationMin).clamp(
    widget.fromMinute,
    widget.toMinute,
  );

  int _snap(num minute) {
    final step = widget.snapMinutes;
    return ((minute / step).round() * step).clamp(widget.fromMinute, _last);
  }

  void _step(int by) =>
      widget.onChanged(_snap(widget.startMinute + by * widget.snapMinutes));

  void _at(double dx, double width) {
    final span = widget.toMinute - widget.fromMinute;
    final m = widget.fromMinute + dx / width * span - widget.durationMin / 2;
    final next = _snap(m);
    if (next != widget.startMinute) widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final value = widget.rangeText(widget.startMinute);
    final bar = LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        double x(double dx) => rtl ? w - dx : dx;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) {
            _focus.requestFocus();
            _at(x(d.localPosition.dx), w);
          },
          onHorizontalDragUpdate: (d) => _at(x(d.localPosition.dx), w),
          child: SizedBox(
            height: DotSize.dayBar,
            width: w,
            child: CustomPaint(
              painter: _DayBarPainter(
                blocks: widget.blocks,
                from: widget.fromMinute,
                to: widget.toMinute,
                start: widget.startMinute,
                rtl: rtl,
                line: t.colors.threadAhead,
                ring: t.colors.accent,
                fill: t.colors.card,
                colors: (c) => t.tasks[c].color,
                focused: _focus.hasFocus,
                halo: t.colors.tonal,
              ),
            ),
          ),
        );
      },
    );
    return Focus(
      focusNode: _focus,
      onFocusChange: (_) => setState(() {}),
      onKeyEvent: (_, event) {
        if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
          return KeyEventResult.ignored;
        }
        final k = event.logicalKey;
        final ahead = rtl
            ? LogicalKeyboardKey.arrowLeft
            : LogicalKeyboardKey.arrowRight;
        final back = rtl
            ? LogicalKeyboardKey.arrowRight
            : LogicalKeyboardKey.arrowLeft;
        final by = k == ahead
            ? 1
            : k == back
            ? -1
            : 0;
        if (by == 0) return KeyEventResult.ignored;
        _step(by);
        return KeyEventResult.handled;
      },
      child: Semantics(
        slider: true,
        label: l10n.whenBarLabel,
        value: value,
        increasedValue: widget.rangeText(
          _snap(widget.startMinute + widget.snapMinutes),
        ),
        decreasedValue: widget.rangeText(
          _snap(widget.startMinute - widget.snapMinutes),
        ),
        onIncrease: () => _step(1),
        onDecrease: () => _step(-1),
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [bar, _hours(t)],
          ),
        ),
      ),
    );
  }

  /// Wake Up, noon, five and Wind Down's hours, where they fall.
  Widget _hours(DotTheme t) {
    final from = widget.fromMinute;
    final to = widget.toMinute;
    final marks = <int>{
      (from / 60).ceil() * 60,
      if (from < 12 * 60 && to > 12 * 60) 12 * 60,
      if (from < 17 * 60 && to > 17 * 60) 17 * 60,
      (to / 60).floor() * 60,
    }.toList()..sort();
    final style = t.styles.rowMeta.copyWith(
      color: t.colors.secondary,
      fontWeight: FontWeight.w600,
    );
    return LayoutBuilder(
      builder: (context, box) {
        final span = to - from;
        return SizedBox(
          height: DotSpace.l + DotSpace.xs,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (final (i, m) in marks.indexed)
                PositionedDirectional(
                  start: i == marks.length - 1
                      ? null
                      : ((m - from) / span * box.maxWidth).clamp(
                          0,
                          box.maxWidth,
                        ),
                  end: i == marks.length - 1 ? 0 : null,
                  top: 0,
                  child: Text(widget.hourText(m), style: style),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DayBarPainter extends CustomPainter {
  const _DayBarPainter({
    required this.blocks,
    required this.from,
    required this.to,
    required this.start,
    required this.rtl,
    required this.line,
    required this.ring,
    required this.fill,
    required this.colors,
    required this.focused,
    required this.halo,
  });

  final List<PickerBlock> blocks;
  final int from;
  final int to;
  final int start;
  final bool rtl;
  final Color line;
  final Color ring;
  final Color fill;
  final Color Function(TaskColor) colors;
  final bool focused;
  final Color halo;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    const r = DotSize.dayBarRing / 2;
    final span = (to - from).toDouble();
    double x(num m) {
      final p = r + (m - from) / span * (size.width - 2 * r);
      return rtl ? size.width - p : p;
    }

    final dash = Paint()
      ..color = line
      ..strokeWidth = DotSpace.xxs
      ..strokeCap = StrokeCap.round;
    for (var px = r; px < size.width - r; px += DotSpace.s) {
      canvas.drawLine(Offset(px, y), Offset(px + DotSpace.xs, y), dash);
    }
    for (final b in blocks) {
      final a = x(b.startMinute.clamp(from, to));
      final e = x(b.endMinute.clamp(from, to));
      if ((a - e).abs() < 1) continue;
      final rect = Rect.fromLTRB(
        a < e ? a : e,
        y - DotSize.dayBarBlock / 2,
        a < e ? e : a,
        y + DotSize.dayBarBlock / 2,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(DotRadii.pill)),
        Paint()..color = colors(b.color),
      );
    }
    final c = Offset(x(start), y);
    if (focused) {
      canvas.drawCircle(c, r + DotSize.dayBarRingStroke, Paint()..color = halo);
    }
    canvas
      ..drawCircle(c, r, Paint()..color = fill)
      ..drawCircle(
        c,
        r - DotSize.dayBarRingStroke / 2,
        Paint()
          ..color = ring
          ..style = PaintingStyle.stroke
          ..strokeWidth = DotSize.dayBarRingStroke,
      );
  }

  @override
  bool shouldRepaint(_DayBarPainter old) =>
      old.start != start ||
      old.blocks != blocks ||
      old.focused != focused ||
      old.from != from ||
      old.to != to ||
      old.ring != ring;
}
