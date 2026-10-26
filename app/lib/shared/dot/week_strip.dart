import 'dart:async';
import 'dart:math' as math;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/pull_handle.dart';
import 'package:dottoday/shared/dot/week_strip_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'package:dottoday/shared/dot/pull_handle.dart';
export 'package:dottoday/shared/dot/week_strip_layout.dart';

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
    this.weekdayNarrow,
    required this.date,
    required this.label,
    required this.completion,
    this.isToday = false,
    this.isPast = false,
  });

  /// "Wed".
  final String weekday;

  /// The locale's one-letter form ("W"), shown when [weekday] would not fit
  /// its column (a narrow phone at the largest text); null keeps [weekday].
  final String? weekdayNarrow;

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
    this.onDropTask,
    this.monthOpen = false,
    this.handle = true,
    super.key,
  }) : assert(days.length == 7, 'a week has 7 days'); // l10n-ignore: assert

  final List<StripDay> days;

  /// Index of the day the pager shows.
  final int selected;
  final ValueChanged<int>? onSelect;

  /// Tap or drag down on the handle (§2.4 "month pull-open").
  final VoidCallback? onPull;

  /// The pull handle under the selected column; off where there is no
  /// month to pull open (the Routines page's day pick, M11.4).
  final bool handle;

  /// A dragged task (its id) was let go on day [int]: phones' "week
  /// overview, read + drag" (PRD F8, R-05). Null = not a drop target.
  final void Function(String id, int index)? onDropTask;

  /// Whether the month is open, for the handle's label.
  final bool monthOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // By the room each column has (docs/10 §5.4): "W" when "Wed" would
        // wrap; a sideways scroll only if even the dates can't fit.
        LayoutBuilder(builder: _row),
        if (handle) PullHandle(open: monthOpen, onPull: onPull),
      ],
    );
  }

  Widget _row(BuildContext context, BoxConstraints box) {
    final styles = DotTheme.of(context).styles;
    final room = box.maxWidth / days.length - 2 * _inset;
    final weekdays = [for (final d in days) d.weekday];
    final narrow = widestLabel(context, weekdays, styles.stripWeekday) > room;
    final need = math.max(
      widestLabel(context, [
        for (final d in days) narrow ? d.weekdayNarrow ?? d.weekday : d.weekday,
      ], styles.stripWeekday),
      widestLabel(context, [for (final d in days) d.date], styles.stripDate),
    );
    final columns = [
      for (final (i, d) in days.indexed) _target(i, d, narrow: narrow),
    ];
    if (need <= room) {
      return Row(children: [for (final c in columns) Expanded(child: c)]);
    }
    return ScrollingWeek(
      columnWidth: need + 2 * _inset,
      selected: selected,
      columns: columns,
    );
  }

  Widget _target(int i, StripDay d, {required bool narrow}) {
    Widget column({bool hovered = false}) => _Column(
      day: d,
      narrow: narrow,
      selected: i == selected,
      hovered: hovered,
      onTap: onSelect == null ? null : () => onSelect!(i),
    );
    final onDrop = onDropTask;
    if (onDrop == null) return column();
    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        unawaited(HapticFeedback.mediumImpact());
        onDrop(details.data, i);
      },
      builder: (context, candidates, _) =>
          column(hovered: candidates.isNotEmpty),
    );
  }
}

/// The selected column's border width.
const _border = DotSpace.hairline * 1.5;

/// What a column's label loses on each side: its margin and the selected
/// column's border.
const _inset = DotSpace.xxs + _border;

class _Column extends StatelessWidget {
  const _Column({
    required this.day,
    required this.narrow,
    required this.selected,
    this.hovered = false,
    this.onTap,
  });

  final StripDay day;

  /// Show [StripDay.weekdayNarrow] (see [weekdaysFit]).
  final bool narrow;
  final bool selected;

  /// A dragged task hovers this day.
  final bool hovered;
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
          decoration: hovered
              ? BoxDecoration(
                  color: c.accentTint,
                  borderRadius: BorderRadius.circular(DotRadii.card),
                )
              : selected
              ? BoxDecoration(
                  color: c.raised,
                  borderRadius: BorderRadius.circular(DotRadii.card),
                  border: Border.all(color: c.outline, width: _border),
                )
              : null,
          child: Column(
            spacing: DotSpace.xxs,
            children: [
              Text(
                narrow ? day.weekdayNarrow ?? day.weekday : day.weekday,
                style: label,
              ),
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
