import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:flutter/material.dart';

// The Wake Up card as your thread (E-R2-19-B "The thread wakes up",
// ED-314; its other states and widths, ED-456): the greeting, the day's
// line from Wake Up down (Wake Up's sun, the first dot big with its first
// step, the next dots), the day's chips and the late start's offer.

/// "Good morning. Thursday 13 November." with ×, and "9 planned · ends
/// 11:00 PM" (or "Nothing planned yet") under it.
class WakeUpCardHeader extends StatelessWidget {
  const WakeUpCardHeader({
    required this.title,
    required this.meta,
    this.onClose,
    super.key,
  });

  final String title;
  final String? meta;

  /// × puts the card away; none where the card is folded into Now.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(title, style: t.styles.monthTitle),
              ),
            ),
            if (onClose case final close?)
              IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: close,
                icon: DotIcon(DotGlyphs.close, color: t.colors.secondary),
              ),
          ],
        ),
        if (meta case final m?) Text(m, style: t.styles.gridDayMetaTouch),
      ],
    );
  }
}

/// One row of the card's thread: the time, the mark on the line, and the
/// title with what's under it.
class WakeUpThreadRow extends StatelessWidget {
  const WakeUpThreadRow({
    required this.time,
    required this.mark,
    required this.title,
    this.sub,
    this.moved,
    this.step,
    this.onTap,
    this.semanticLabel,
    super.key,
  });

  final String time;
  final Widget mark;
  final String title;
  final String? sub;

  /// "→ 7:10 AM": where a late start would move it (E-R2-19-B frame 4).
  final String? moved;

  /// The first dot's first step, in its tinted box.
  final Widget? step;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final amber = t.tasks[TaskColor.amber].ink;
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DotSpace.m,
      children: [
        SizedBox(
          width: DotSize.wakeCardTime,
          child: Padding(
            padding: const EdgeInsets.only(top: DotSpace.s),
            child: Text(
              time,
              textAlign: TextAlign.end,
              style: t.styles.gridHourTouch,
            ),
          ),
        ),
        SizedBox(
          width: DotSize.wakeCardMark,
          child: Center(child: mark),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: DotSpace.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.styles.gridTitleTouch),
                if (sub case final s?) Text(s, style: t.styles.gridMetaTouch),
                if (moved case final m?)
                  Text(m, style: t.styles.gridDayMeta.copyWith(color: amber)),
                if (step case final s?)
                  Padding(
                    padding: const EdgeInsets.only(top: DotSpace.s),
                    child: s,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
    if (onTap == null) return row;
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DotRadii.card),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotTouch.min),
          child: row,
        ),
      ),
    );
  }
}

/// The line the card's rows sit on: from Wake Up's amber into the day's
/// hairline, dashed past the last row when the day goes on unseen (an empty
/// day, low energy, Minimal).
class WakeUpThread extends StatelessWidget {
  const WakeUpThread({required this.rows, this.openEnd = false, super.key});

  final List<Widget> rows;
  final bool openEnd;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final start = t.tasks[TaskColor.amber].color;
    return CustomPaint(
      painter: _ThreadLine(
        x: DotSize.wakeCardTime + DotSpace.m + DotSize.wakeCardMark / 2,
        top: DotSize.wakeCardSun / 2,
        from: start,
        to: t.colors.hairline,
        dashed: openEnd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DotSize.wakeCardGap,
        children: [
          ...rows,
          if (openEnd) const SizedBox(height: DotSpace.l),
        ],
      ),
    );
  }
}

class _ThreadLine extends CustomPainter {
  const _ThreadLine({
    required this.x,
    required this.top,
    required this.from,
    required this.to,
    required this.dashed,
  });

  final double x;
  final double top;
  final Color from;
  final Color to;
  final bool dashed;

  /// Where the amber has given way to the line's own colour.
  static const _fade = 0.18;

  @override
  void paint(Canvas canvas, Size size) {
    final end = dashed ? size.height : size.height - DotSpace.xl;
    if (end <= top) return;
    final paint = Paint()
      ..strokeWidth = DotSize.wakeCardLine
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [from, to],
        stops: const [0, _fade],
      ).createShader(Rect.fromLTRB(x, top, x + 1, end));
    if (!dashed) {
      canvas.drawLine(Offset(x, top), Offset(x, end), paint);
      return;
    }
    for (var y = top; y < end; y += DotSpace.m) {
      canvas.drawLine(
        Offset(x, y),
        Offset(x, (y + DotSpace.s - DotSpace.xxs).clamp(top, end)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ThreadLine old) =>
      old.x != x ||
      old.top != top ||
      old.from != from ||
      old.to != to ||
      old.dashed != dashed;
}

/// Wake Up's mark: the sun on amber.
class WakeUpSun extends StatelessWidget {
  const WakeUpSun({super.key});

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final amber = t.tasks[TaskColor.amber].color;
    return Container(
      width: DotSize.wakeCardSun,
      height: DotSize.wakeCardSun,
      decoration: BoxDecoration(color: amber, shape: BoxShape.circle),
      child: Center(
        child: DotIcon(DotGlyphs.sunrise, color: t.colors.onAccent),
      ),
    );
  }
}

/// A task's dot on the card's line: [first] is the big one.
Widget wakeUpTaskDot(ThreadTask task, {bool first = false}) => TaskDot(
  color: task.color,
  icon: task.icon,
  state: DotState.upcoming,
  label: task.title,
  oneThing: task.oneThing,
  size: first ? DotSize.wakeCardFirst : DotSize.wakeCardDot,
);

/// The first dot's first step, in a box tinted its colour.
class WakeUpStep extends StatelessWidget {
  const WakeUpStep({required this.text, required this.color, super.key});

  final String text;
  final TaskColor color;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final ink = t.tasks[color].color;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DotSpace.s + DotSpace.xxs,
        vertical: DotSpace.s,
      ),
      decoration: BoxDecoration(
        color: ink.withValues(
          alpha: t.colors.isDark ? TaskAlpha.tintDark : TaskAlpha.tintLight,
        ),
        borderRadius: BorderRadius.circular(DotRadii.dayTile),
      ),
      child: Row(
        spacing: DotSpace.s,
        children: [
          Container(
            width: DotSize.formCheck + DotSpace.xxs,
            height: DotSize.formCheck + DotSpace.xxs,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ink, width: DotSpace.xxs),
            ),
          ),
          Expanded(child: Text(text, style: t.styles.smallChip)),
        ],
      ),
    );
  }
}

/// The day's chips: "2 events today", "3 in Inbox", "Low-energy · on".
class WakeUpChips extends StatelessWidget {
  const WakeUpChips({required this.chips, super.key});

  final List<(DotGlyph, String)> chips;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Wrap(
      spacing: DotSpace.s,
      runSpacing: DotSpace.s,
      children: [
        for (final (glyph, text) in chips)
          Container(
            constraints: const BoxConstraints(minHeight: DotSize.capsuleAvatar),
            padding: const EdgeInsets.symmetric(horizontal: DotSpace.m),
            decoration: BoxDecoration(
              color: t.colors.chip,
              borderRadius: BorderRadius.circular(DotRadii.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: DotSpace.xs + DotSpace.xxs,
              children: [
                DotIcon(glyph, color: t.colors.ink, size: DotSize.navIcon),
                Flexible(child: Text(text, style: t.styles.smallChip)),
              ],
            ),
          ),
      ],
    );
  }
}

/// "This moves what's left; nothing changes until you accept." and
/// Shift the rest? (E-R2-19-B frame 4): an offer, never a reproach.
class WakeUpShiftRow extends StatelessWidget {
  const WakeUpShiftRow({required this.onShift, super.key});

  final VoidCallback onShift;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final amber = t.tasks[TaskColor.amber];
    return Row(
      spacing: DotSpace.s + DotSpace.xxs,
      children: [
        Expanded(
          child: Text(l10n.wakeUpDiscoveryShift, style: t.styles.gridMetaTouch),
        ),
        FilledButton(
          onPressed: onShift,
          style: FilledButton.styleFrom(
            backgroundColor: amber.color.withValues(
              alpha: t.colors.isDark ? TaskAlpha.tintDark : TaskAlpha.tintLight,
            ),
            foregroundColor: amber.ink,
            minimumSize: const Size(0, DotTouch.min),
            textStyle: t.styles.chip,
          ),
          child: Text(l10n.wakeUpCardShift),
        ),
      ],
    );
  }
}

/// Today's one thing when it waits in the Inbox (docs/15 §8), on the line.
class WakeUpOneThing extends StatelessWidget {
  const WakeUpOneThing({
    required this.occurrence,
    required this.onOpen,
    super.key,
  });

  final Occurrence occurrence;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final o = occurrence;
    return WakeUpThreadRow(
      time: '',
      mark: TaskDot(
        color: TaskColor.fromKey(o.colorKey),
        icon: TaskIcon.fromKey(o.iconKey),
        state: DotState.upcoming,
        label: o.title,
        oneThing: true,
        size: DotSize.wakeCardDot,
      ),
      title: o.title,
      sub: l10n.oneThingMetaJoin(l10n.oneThingInInbox),
      onTap: onOpen,
      semanticLabel: l10n.rowOneThing(
        l10n.rowLabel(o.title, l10n.oneThingInInbox),
      ),
    );
  }
}
