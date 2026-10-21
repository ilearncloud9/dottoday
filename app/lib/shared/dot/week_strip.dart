import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// How much of a day got done, for the 8 px dots of the strip and month.
@immutable
final class Completion {
  const Completion.none() : share = null;
  const Completion.of(double this.share);

  /// 0–1 share of the day's tasks done; null when the day is still ahead or
  /// has nothing planned (outline dot).
  final double? share;
}

/// One column of a [WeekStrip]: display values from the feature.
@immutable
final class StripDay {
  const StripDay({
    required this.weekday,
    required this.date,
    required this.label,
    required this.completion,
    this.isToday = false,
    this.isPast = false,
  });

  /// "Wed".
  final String weekday;

  /// "21".
  final String date;

  /// Screen-reader label, e.g. "Wednesday 21 October, 2 of 7 done".
  final String label;
  final Completion completion;
  final bool isToday;

  /// Past dates read muted (`Main`).
  final bool isPast;
}

/// Seven days with their completion dots (docs/10 §3 `WeekStrip`, `Main`):
/// filled when done, conic when partly, outline ahead; the selected column
/// is raised and the pull handle under it opens the month.
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    required this.days,
    required this.selected,
    this.onSelect,
    this.onPull,
    this.monthOpen = false,
    super.key,
  }) : assert(days.length == 7, 'a week has 7 days'); // l10n-ignore: assert

  final List<StripDay> days;

  /// Index of the day the pager shows.
  final int selected;
  final ValueChanged<int>? onSelect;

  /// Tap or drag down on the handle (§2.4 "month pull-open").
  final VoidCallback? onPull;

  /// Whether the month is open, for the handle's label.
  final bool monthOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (final (i, d) in days.indexed)
              Expanded(
                child: _Column(
                  day: d,
                  selected: i == selected,
                  onTap: onSelect == null ? null : () => onSelect!(i),
                ),
              ),
          ],
        ),
        PullHandle(open: monthOpen, onPull: onPull),
      ],
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({required this.day, required this.selected, this.onTap});

  final StripDay day;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final label = t.styles.stripWeekday.copyWith(
      color: day.isToday ? c.accentInk : null,
    );
    // Only the weekday turns accent on today; the date stays text, muted
    // for days already gone (`Main`).
    final date = t.styles.stripDate.copyWith(
      color: day.isPast ? c.muted : null,
    );
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: day.label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DotRadii.card),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: DotSpace.xxs),
          padding: const EdgeInsets.symmetric(vertical: DotSpace.s),
          constraints: const BoxConstraints(minHeight: DotTouch.android),
          decoration: selected
              ? BoxDecoration(
                  color: c.raised,
                  borderRadius: BorderRadius.circular(DotRadii.card),
                  border: Border.all(
                    color: c.outline,
                    width: DotSpace.hairline * 1.5,
                  ),
                )
              : null,
          child: Column(
            spacing: DotSpace.xxs,
            children: [
              Text(day.weekday, style: label),
              Text(day.date, style: date),
              CompletionDot(completion: day.completion),
            ],
          ),
        ),
      ),
    );
  }
}

/// The 8 px completion dot (docs/10 §3 `WeekStrip`, `MonthGrid`).
class CompletionDot extends StatelessWidget {
  const CompletionDot({
    required this.completion,
    this.size = DotSize.weekDot,
    super.key,
  });

  final Completion completion;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return CustomPaint(
      size: Size.square(size + DotSpace.xxs),
      painter: _CompletionPainter(
        share: completion.share,
        accent: c.accent,
        track: Color.alphaBlend(c.accentTint, c.raised),
        hairline: c.hairline,
      ),
    );
  }
}

final class _CompletionPainter extends CustomPainter {
  const _CompletionPainter({
    required this.share,
    required this.accent,
    required this.track,
    required this.hairline,
  });

  final double? share;
  final Color accent;
  final Color track;
  final Color hairline;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = DotSize.weekDot / 2;
    final s = share;
    if (s == null) {
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = DotSpace.hairline * 1.5
        ..color = hairline;
      canvas.drawCircle(c, r, ring);
      return;
    }
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(c, r, Paint()..color = s >= 1 ? accent : track);
    if (s > 0 && s < 1) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * s,
        true,
        Paint()..color = accent,
      );
    }
  }

  @override
  bool shouldRepaint(_CompletionPainter old) =>
      old.share != share ||
      old.accent != accent ||
      old.track != track ||
      old.hairline != hairline;
}

/// The grab handle under the strip that pulls the month open (§2.4).
class PullHandle extends StatelessWidget {
  const PullHandle({required this.open, this.onPull, super.key});

  final bool open;
  final VoidCallback? onPull;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final l10n = context.l10n;
    return Semantics(
      button: true,
      expanded: open,
      label: open ? l10n.weekStripHideMonth : l10n.weekStripShowMonth,
      excludeSemantics: true,
      onTap: onPull,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPull,
        onVerticalDragEnd: onPull == null ? null : (_) => onPull!(),
        child: SizedBox(
          // A full 48 dp target although the bar is 5 px (§7.4 wins over
          // the render's tighter gap).
          width: DotTouch.android * 2,
          height: DotTouch.android,
          child: Center(
            child: Container(
              width: DotSize.rowDot,
              height: DotSize.weekDot / 2 + 1,
              decoration: BoxDecoration(
                color: c.outline,
                borderRadius: BorderRadius.circular(DotRadii.pill),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
