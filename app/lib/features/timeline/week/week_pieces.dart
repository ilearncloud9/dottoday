import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';

/// The Week board's scale (`A-mac-week-alt3-board`: 36 px an hour).
abstract final class WeekScale {
  static const double pxPerMinute = .6;
  static const double minCard = 32;
  static const double gap = DotSpace.xs;
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
          painter: DashedPillPainter(color: t.colors.hairline),
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

/// The dotted spine down a day column.
final class WeekSpine extends CustomPainter {
  const WeekSpine({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var y = 0.0; y < size.height; y += DotSpace.s) {
      canvas.drawCircle(Offset(size.width / 2, y), size.width / 2, paint);
    }
  }

  @override
  bool shouldRepaint(WeekSpine old) => old.color != color;
}

/// "Busiest" / "Lightest" under a day's free time.
class WeekTag extends StatelessWidget {
  const WeekTag({required this.text, this.accent = false, super.key});

  final String text;

  /// Tinted when on today's column.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent ? c.accentTint : c.outline,
        borderRadius: BorderRadius.circular(DotRadii.chipAndroid),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DotSpace.xs,
          vertical: DotSpace.xxs,
        ),
        child: Text(
          text,
          style: t.styles.rowMeta.copyWith(color: accent ? c.accentInk : null),
        ),
      ),
    );
  }
}
