import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/inbox_beside.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/task_row.dart';
import 'package:dottoday/shared/dot/thread_axis.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';

/// The Wake Up or Wind Down cap at either end of the thread: a [TaskDot]
/// like every task's (sun, sleepy moon), with its time beside it. With
/// [onTap] the dot and the time open the time editor (R-17).
class CapRow extends StatelessWidget {
  const CapRow({
    required this.cap,
    this.size = DotSize.threadDot,
    this.onTap,
    super.key,
  });

  final ThreadCap cap;

  /// The row dots' size on this thread ([DotSize.threadDot], or
  /// [DotSize.macRowDot] on the spread's side days).
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final windDown = cap.windDown;
    final label = windDown
        ? l10n.threadBed(cap.time)
        : l10n.threadWake(cap.time);
    return ThreadRowFrame(
      piece: CapPiece(below: !windDown, iconExtent: size),
      dot: TaskDot(
        color: windDown ? TaskColor.violet : TaskColor.amber,
        icon: windDown ? TaskIcon.sleepyMoon : TaskIcon.sun,
        state: DotState.upcoming,
        label: label,
        size: size,
        onTap: onTap,
        tapHint: l10n.capEditHint,
      ),
      // The dot carries the label and the tap for screen readers.
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          canRequestFocus: false,
          borderRadius: BorderRadius.circular(DotRadii.card),
          child: SizedBox(
            height: size,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              // Caps and gaps read at the weekday size in `Main` (≈ 13 muted).
              child: Text(label, style: t.styles.stripWeekday),
            ),
          ),
        ),
      ),
    );
  }
}

/// How a future gap reads (docs/10 §3 `Thread`).
enum GapStyle {
  /// "+ 1 h free · add here" (`Main`); on the wide Mac/web card "+ 1 h
  /// free · drop an inbox task here" (`A-mac-today-alt1-spread`).
  pill,

  /// "1 h 30 free", as in the spread's side days.
  plain,

  /// The dashed "+ drop here to plan" box closing a future side day.
  dropBox,
}

/// Free time between tasks; future gaps offer "add here".
class GapRow extends StatelessWidget {
  const GapRow({
    required this.gap,
    this.onAdd,
    this.style = GapStyle.pill,
    this.dayLabel = '',
    super.key,
  });

  final ThreadGap gap;
  final ValueChanged<ThreadGap>? onAdd;
  final GapStyle style;

  /// The day, for the drop box's screen-reader label.
  final String dayLabel;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return ThreadRowFrame(
      piece: FreePiece(nowFraction: gap.nowFraction),
      child: Padding(
        padding: const EdgeInsets.only(bottom: DotSpace.l),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: _label(context, t.styles.stripWeekday),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, TextStyle text) {
    final l10n = context.l10n;
    final duration = formatDurationShort(l10n, gap.minutes);
    if (!gap.labelled) return const SizedBox(height: DotSpace.s);
    final plain = Text(l10n.threadFree(duration), style: text);
    if (!gap.addable) return plain;
    final tap = onAdd == null ? null : () => onAdd!(gap);
    return switch (style) {
      GapStyle.plain => plain,
      GapStyle.dropBox => _DropBox(
        label: l10n.spreadDropToPlan,
        semantics: l10n.spreadDropToPlanLabel(dayLabel),
        style: text,
        onTap: tap,
      ),
      GapStyle.pill => _AddHere(
        // Wide screens plan from the Inbox sidebar by dragging (M3e.2).
        label: switch (gap.fits) {
          final title? => l10n.threadFreeFits(duration, title),
          null when InboxBeside.of(context) => l10n.threadDropInbox(duration),
          null => l10n.threadAddHere(duration),
        },
        semantics: l10n.threadAddHereLabel(duration, gap.startLabel),
        style: text,
        onTap: tap,
      ),
    };
  }
}

/// "+ drop here to plan" (`A-mac-today-alt1-spread`, tomorrow's column).
class _DropBox extends StatelessWidget {
  const _DropBox({
    required this.label,
    required this.semantics,
    required this.style,
    this.onTap,
  });

  final String label;
  final String semantics;
  final TextStyle style;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return Semantics(
      button: true,
      label: semantics,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DotRadii.card),
        child: CustomPaint(
          painter: DashedPillPainter(color: c.hairline, radius: DotRadii.card),
          child: Padding(
            padding: const EdgeInsets.all(DotSpace.l),
            child: Column(
              spacing: DotSpace.xs,
              children: [
                DotIcon(DotGlyphs.add, color: c.muted, size: DotSize.rowIcon),
                Text(label, style: style, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The dashed "+ 1 h free · add here" pill (`Main`).
class _AddHere extends StatelessWidget {
  const _AddHere({
    required this.label,
    required this.semantics,
    required this.style,
    this.onTap,
  });

  final String label;
  final String semantics;
  final TextStyle style;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return Semantics(
      button: true,
      label: semantics,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: CustomPaint(
          painter: DashedPillPainter(color: c.hairline),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: DotTouch.android),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DotSpace.l),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: DotSpace.s,
                children: [
                  DotIcon(DotGlyphs.add, color: c.muted, size: DotSize.rowIcon),
                  Flexible(child: Text(label, style: style)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A dashed stadium outline: free-time drop targets and "+ preset"; with
/// [radius], a dashed rounded box ("drop here to plan").
final class DashedPillPainter extends CustomPainter {
  const DashedPillPainter({required this.color, this.radius});

  final Color color;
  final double? radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(DotSpace.hairline),
      Radius.circular(radius ?? size.height / 2),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = DotSpace.hairline * 1.5
      ..color = color;
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      const dash = DotSpace.xs + DotSpace.xxs;
      for (var d = 0.0; d < metric.length; d += dash * 2) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(DashedPillPainter old) =>
      old.color != color || old.radius != radius;
}
