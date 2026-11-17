import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/inbox_beside.dart';
import 'package:dottoday/shared/dot/task_row.dart';
import 'package:dottoday/shared/dot/thread_axis.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';

/// The Wake Up or Wind Down cap at either end of the thread (E rules
/// §5.2): a sun on a warm disc or a moon on a lilac one, with its time
/// beside it. The thread starts at the sun's centre and ends at the
/// moon's. With [onTap] the dot and the time open the time editor (R-17).
class CapRow extends StatelessWidget {
  const CapRow({
    required this.cap,
    this.size = DotSize.threadCap,
    this.solid,
    this.onTap,
    super.key,
  });

  final ThreadCap cap;

  /// [DotSize.threadCap], or [DotSize.macRowDot] on the spread's side days.
  final double size;

  /// The thread's colour beside the cap when that stretch is behind now
  /// (from `threadSolid`); null: dotted.
  final TaskColor? solid;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final l10n = context.l10n;
    final windDown = cap.windDown;
    final label = windDown
        ? l10n.threadBed(cap.time)
        : l10n.threadWake(cap.time);
    return ThreadRowFrame(
      minHeight: size == DotSize.threadCap ? DotSize.threadRowCap : 0,
      piece: CapPiece(
        below: !windDown,
        color: switch (solid) {
          final s? => t.tasks[s].color,
          null => null,
        },
      ),
      dot: _CapDot(
        glyph: (windDown ? TaskIcon.sleepyMoon : TaskIcon.sun).glyph!,
        fill: windDown ? c.windCap : c.wakeCap,
        ink: windDown ? c.windIcon : c.wakeIcon,
        size: size,
        label: label,
        hint: l10n.capEditHint,
        onTap: onTap,
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
              child: Text(label, style: t.styles.stripWeekday),
            ),
          ),
        ),
      ),
    );
  }
}

/// A cap's disc: [fill] with the [glyph] in [ink] (§5.1: 19 in 34).
class _CapDot extends StatelessWidget {
  const _CapDot({
    required this.glyph,
    required this.fill,
    required this.ink,
    required this.size,
    required this.label,
    required this.hint,
    this.onTap,
  });

  final DotGlyph glyph;
  final Color fill;
  final Color ink;
  final double size;
  final String label;
  final String hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disc = DecoratedBox(
      decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: DotIcon(glyph, color: ink, size: size * 19 / 34, bold: true),
        ),
      ),
    );
    return Semantics(
      button: onTap != null,
      label: label,
      onTapHint: onTap == null ? null : hint,
      onTap: onTap,
      excludeSemantics: true,
      child: onTap == null
          ? disc
          : InkResponse(
              onTap: onTap,
              radius: DotTouch.android / 2,
              child: SizedBox.square(
                dimension: DotTouch.android,
                child: Center(child: disc),
              ),
            ),
    );
  }
}

/// Now on today's thread (E rules §5.3): the bead on the thread, the time
/// in a pill beside it and a hairline to the row's end.
class NowRow extends StatelessWidget {
  const NowRow({required this.now, this.solid, super.key});

  final ThreadNow now;

  /// The thread's colour above the bead (from `threadSolid`).
  final TaskColor? solid;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return Semantics(
      label: context.l10n.timelineNow(now.time),
      excludeSemantics: true,
      child: ThreadRowFrame(
        minHeight: DotSize.threadRowNow,
        piece: NowPiece(
          color: switch (solid) {
            final s? => t.tasks[s].color,
            null => null,
          },
        ),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: c.raised,
                borderRadius: BorderRadius.circular(DotRadii.nowPill),
                border: Border.all(
                  color: c.accent.withValues(alpha: TaskAlpha.nowPill),
                  width: DotSize.nowHalo,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DotSpace.nowPill,
                ),
                child: Text(
                  now.time,
                  // 700 13/18 in the accent (E rules §5.3).
                  style: t.styles.threadMeta.copyWith(
                    color: c.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: DotSize.nowHalo,
                margin: const EdgeInsetsDirectional.only(
                  start: DotSpace.s,
                  end: DotSpace.xl,
                ),
                color: c.accent.withValues(alpha: TaskAlpha.nowLine),
              ),
            ),
          ],
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
    this.solid,
    super.key,
  });

  final ThreadGap gap;

  /// The thread's colour through the gap when it is behind now (from
  /// `threadSolid`); null: dotted.
  final TaskColor? solid;
  final ValueChanged<ThreadGap>? onAdd;
  final GapStyle style;

  /// The day, for the drop box's screen-reader label.
  final String dayLabel;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return ThreadRowFrame(
      minHeight: DotSize.threadRowFree,
      piece: FreePiece(
        color: switch (solid) {
          final s? => t.tasks[s].color,
          null => null,
        },
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DotSpace.xxs),
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
        free: l10n.threadFree(duration),
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
          painter: DashedPillPainter(
            color: c.threadAhead,
            radius: DotRadii.card,
          ),
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

/// "1 h 30 free · add here" (E-Phones Today): the free time in the
/// secondary colour, what to do with it in the accent. The tap area is the
/// 44 pt touch target however short the row draws.
class _AddHere extends StatelessWidget {
  const _AddHere({
    required this.label,
    required this.free,
    required this.semantics,
    required this.style,
    this.onTap,
  });

  final String label;

  /// "1 h 30 free", the start of [label] in every language.
  final String free;
  final String semantics;
  final TextStyle style;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final action = label.startsWith(free) ? label.substring(free.length) : '';
    return Semantics(
      button: true,
      label: semantics,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DotRadii.card),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotTouch.min),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text.rich(
              TextSpan(
                text: action.isEmpty ? label : free,
                children: [
                  if (action.isNotEmpty)
                    TextSpan(
                      text: action,
                      style: TextStyle(color: c.accentInk),
                    ),
                ],
              ),
              style: style,
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
