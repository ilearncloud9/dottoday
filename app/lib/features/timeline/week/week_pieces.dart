import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/week/grid_focus.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';

/// One day as the board draws it.
@immutable
final class WeekDayView {
  const WeekDayView({
    required this.date,
    required this.tasks,
    required this.starts,
    required this.axisStartUtc,
    required this.isToday,
    required this.open,
    required this.snapMinutes,
    this.nowUtc,
    this.pickedId,
    this.selected = const {},
  });

  final DateTime date;

  /// The day's timed tasks with their states (from `threadEntries`).
  final List<ThreadTask> tasks;

  /// Start and length of each task, by id.
  final Map<String, ({DateTime startUtc, int minutes})> starts;

  /// The hour axis' top on this date (DST-aware).
  final DateTime axisStartUtc;
  final bool isToday;

  /// The Settings snap step a drag or an Alt+arrow moves by (R-05).
  final int snapMinutes;

  /// Today or later: the thread runs dotted ahead.
  final bool open;

  /// Draws the now line (today only).
  final DateTime? nowUtc;

  /// The task in the Workspace inspector (ED-170 C1): drawn with the ink
  /// edge (E-FullA-v2).
  final String? pickedId;

  /// The tasks picked in multi-select on this day (E-R2-6).
  final Set<String> selected;

  /// [id]'s day and start minute, for the arrow keys between blocks.
  GridSlot? slotOf(String id) => switch (starts[id]) {
    final s? => (
      day: date,
      minute: s.startUtc.difference(axisStartUtc).inMinutes,
    ),
    null => null,
  };
}

/// A picked block's check (E-R2-6): a filled accent badge at its top end,
/// so a pick never rests on the edge's colour alone.
class GridPickBadge extends StatelessWidget {
  const GridPickBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return PositionedDirectional(
      top: DotSpace.s,
      end: DotSpace.s,
      child: IgnorePointer(
        child: Container(
          width: DotSize.gridPickBadge,
          height: DotSize.gridPickBadge,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.accentFill,
          ),
          child: DotIcon(
            DotGlyphs.check,
            color: c.onAccent,
            size: DotSize.rowIcon - DotSpace.xxs,
            active: true,
          ),
        ),
      ),
    );
  }
}

/// The cue line: quiet accent text (11 §D, no warning colour).
class GridCueLine extends StatelessWidget {
  const GridCueLine({super.key, required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      button: true,
      label: text,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DotSpace.s,
            vertical: DotSpace.xxs,
          ),
          // Bold in the accent, two lines on a tall card (E-R2-23 §2).
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.styles.gridTitle.copyWith(color: t.colors.accentText),
          ),
        ),
      ),
    );
  }
}

/// A full-width line across a day column at [y], [width] thick (the
/// hour lines, the now line).
Widget gridLine(Color color, double y, double width) => Positioned(
  left: 0,
  right: 0,
  top: y - width / 2,
  height: width,
  child: ColoredBox(color: color),
);

/// The focus ring (ED-211) around a grid block: 2 px in the focus colour
/// after a 2 px gap in the grid's colour, outside the block.
Widget gridFocusRing(DotColors c, BorderRadius radius, Widget card) {
  const w = DotSize.smallDotOutline;
  BoxDecoration ring(Color color, double out) => BoxDecoration(
    borderRadius: radius.add(BorderRadius.circular(out)),
    border: Border.all(color: color, width: w),
  );
  Widget edge(Color color, double out) => Positioned.fill(
    left: -out,
    top: -out,
    right: -out,
    bottom: -out,
    child: IgnorePointer(child: DecoratedBox(decoration: ring(color, out))),
  );
  return Stack(
    clipBehavior: Clip.none,
    fit: StackFit.passthrough,
    children: [card, edge(c.focus, w * 2), edge(c.canvas, w)],
  );
}
