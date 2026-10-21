import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/live_row.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/task_row.dart';
import 'package:dottoday/shared/dot/thread_axis.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';

export 'thread_models.dart';

/// Callbacks a [Thread] reports with the task's id.
@immutable
final class ThreadActions {
  const ThreadActions({
    this.onToggleDone,
    this.onOpen,
    this.onLongPress,
    this.onExtend,
    this.onShiftRest,
    this.onAddHere,
  });

  final ValueChanged<String>? onToggleDone;
  final ValueChanged<String>? onOpen;
  final ValueChanged<String>? onLongPress;
  final ValueChanged<String>? onExtend;
  final ValueChanged<String>? onShiftRest;

  /// A future gap was tapped; reports the gap.
  final ValueChanged<ThreadGap>? onAddHere;
}

/// The day as a vertical thread (docs/10 §1, §3 `Thread`): sun cap, task
/// rows, free gaps, moon cap. A `Column`, so callers put it in a scroll
/// view or a sliver; it never scrolls itself.
class Thread extends StatelessWidget {
  const Thread({
    required this.entries,
    this.actions = const ThreadActions(),
    this.dotSize = DotSize.rowDot,
    super.key,
  });

  final List<ThreadEntry> entries;
  final ThreadActions actions;

  /// [DotSize.rowDot], or [DotSize.macRowDot] in the Mac spread's side days.
  final double dotSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (final e in entries) _entry(e)],
    );
  }

  Widget _entry(ThreadEntry e) {
    final a = actions;
    return switch (e) {
      ThreadCap() => _Cap(cap: e),
      ThreadGap() => _Gap(gap: e, onAdd: a.onAddHere),
      ThreadTaskEntry(:final task) when task.state == DotState.live => LiveRow(
        task: task,
        onToggleDone: _bind(a.onToggleDone, task),
        onOpen: _bind(a.onOpen, task),
        onLongPress: _bind(a.onLongPress, task),
        onExtend: _bind(a.onExtend, task),
        onShiftRest: task.overrunMinutes > 0
            ? _bind(a.onShiftRest, task)
            : null,
      ),
      ThreadTaskEntry(:final task) => TaskRow(
        task: task,
        dotSize: dotSize,
        onToggleDone: _bind(a.onToggleDone, task),
        onOpen: _bind(a.onOpen, task),
        onLongPress: _bind(a.onLongPress, task),
      ),
    };
  }

  static VoidCallback? _bind(ValueChanged<String>? f, ThreadTask task) =>
      f == null ? null : () => f(task.id);
}

class _Cap extends StatelessWidget {
  const _Cap({required this.cap});

  final ThreadCap cap;

  static const double _icon = DotSize.navIcon - DotSpace.xs;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final bed = cap.bedtime;
    return ThreadRowFrame(
      piece: CapPiece(below: !bed, iconExtent: _icon + DotSpace.xs),
      dot: DotIcon(
        bed ? DotGlyphs.moon : DotGlyphs.sun,
        color: (bed ? TaskColor.violet : TaskColor.amber).color,
        size: _icon,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: DotSpace.s),
        child: Text(
          bed ? l10n.threadBed(cap.time) : l10n.threadWake(cap.time),
          // Caps and gaps read at the weekday size in `Main` (≈ 13 muted).
          style: t.styles.stripWeekday,
        ),
      ),
    );
  }
}

class _Gap extends StatelessWidget {
  const _Gap({required this.gap, this.onAdd});

  final ThreadGap gap;
  final ValueChanged<ThreadGap>? onAdd;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final duration = formatDurationShort(l10n, gap.minutes);
    final style = t.styles.stripWeekday;
    return ThreadRowFrame(
      piece: FreePiece(nowFraction: gap.nowFraction),
      child: Padding(
        padding: const EdgeInsets.only(bottom: DotSpace.l),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: gap.addable
              ? _AddHere(
                  label: l10n.threadAddHere(duration),
                  semantics: l10n.threadAddHereLabel(duration, gap.startLabel),
                  style: style,
                  onTap: onAdd == null ? null : () => onAdd!(gap),
                )
              : Text(l10n.threadFree(duration), style: style),
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

/// A dashed stadium outline: free-time drop targets and "+ preset".
final class DashedPillPainter extends CustomPainter {
  const DashedPillPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(DotSpace.hairline),
      Radius.circular(size.height / 2),
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
  bool shouldRepaint(DashedPillPainter old) => old.color != color;
}
