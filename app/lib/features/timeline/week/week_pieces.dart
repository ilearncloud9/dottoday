import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';

/// The hour grid's scale (E-FullA-v2 Week: 84 px an hour, a short task
/// a 21 tall pill).
abstract final class WeekScale {
  static const double pxPerMinute = DotSize.gridHour / Duration.minutesPerHour;
  static const double minCard = DotSize.gridPill;

  /// Shorter than this a task is a one-line pill (a 30 min task is a 42
  /// tall block, E-FullA-v2's Dentist).
  static const int pillUnder = 30;

  /// The axis starts half an hour before its first whole hour, so that
  /// hour's label and line clear the day headers (E-FullA-v2: 7 AM 42
  /// below them).
  static const int leadMinutes = 30;
}

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
    required this.freeText,
    this.nowUtc,
  });

  final DateTime date;

  /// The day's timed tasks with their states (from `threadEntries`).
  final List<ThreadTask> tasks;

  /// Start and length of each task, by id.
  final Map<String, ({DateTime startUtc, int minutes})> starts;

  /// The hour axis' top on this date (DST-aware).
  final DateTime axisStartUtc;
  final bool isToday;

  /// Today or later: offers "Drop a task here".
  final bool open;

  /// "12 h" free, for the drop box.
  final String freeText;

  /// Draws the now line (today only).
  final DateTime? nowUtc;
}

/// "Drop a task here · 12 h": tap to add on this day.
class WeekDropBox extends StatelessWidget {
  const WeekDropBox({
    required this.text,
    required this.onTap,
    this.onTint = false,
    super.key,
  });

  final String text;
  final VoidCallback onTap;

  /// On today's tinted column, where muted text falls below 4.5:1.
  final bool onTint;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final label = context.l10n.weekDropHere(text);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: CustomPaint(
          painter: DashedPillPainter(color: t.colors.threadAhead),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: DotTouch.min),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.styles.rowMeta.copyWith(
                  color: onTint ? t.colors.text : null,
                ),
              ),
            ),
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
