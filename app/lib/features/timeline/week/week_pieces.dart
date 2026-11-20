import 'package:dottoday/core/theme/dot_theme.dart';
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
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.styles.gridMeta.copyWith(color: t.colors.accentText),
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
