import 'dart:async';

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/core/utils/text_fit.dart';
import 'package:dottoday/shared/dot/week_strip_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'week_strip_parts.dart';

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
    this.completion,
    this.weekdayNarrow,
    this.isToday = false,
    this.isPast = false,
  });

  /// "Wed".
  final String weekday;

  /// "W": shown instead of [weekday] when that doesn't fit its column on
  /// one line (large text on a phone), so it never breaks mid-word.
  final String? weekdayNarrow;

  /// "21".
  final String date;

  /// Screen-reader label, e.g. "Wednesday 21 October, 2 of 7 done".
  final String label;

  /// The day's completion dot; null draws none (minimal mode, docs/14 §3:
  /// a done ratio is a number that judges).
  final Completion? completion;
  final bool isToday;

  /// Past dates read muted (`Main`).
  final bool isPast;
}

/// Seven days with their completion dots (docs/10 §3 `WeekStrip`, `Main`):
/// filled when done, conic when partly, outline ahead; the selected column
/// is filled (ADR-0015) and the pull handle under it opens the month.
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
    final style = DotTheme.of(context).styles.stripWeekday;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, box) {
            // One form for the whole week: if any day's "Wed" doesn't fit
            // its column on one line (large text on a phone: "We / d"),
            // every day shows its narrow form, never a mix.
            final width = box.maxWidth / days.length - 2 * DotSpace.xxs;
            final narrow = days.any(
              (d) => !textFitsOneLine(context, d.weekday, style, width),
            );
            return Row(
              children: [
                for (final (i, d) in days.indexed)
                  Expanded(child: _target(i, d, narrow: narrow)),
              ],
            );
          },
        ),
        if (handle) PullHandle(open: monthOpen, onPull: onPull),
      ],
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
    return _DayDropTarget(
      onDrop: (id) => onDrop(id, i),
      // Held over a day, the strip pages there so the task can land at a
      // time on it (Structured's hover, ADR-0015); let go at once, it
      // keeps its time (PRD F8).
      onHover: i == selected || onSelect == null ? null : () => onSelect!(i),
      builder: (hovered) => column(hovered: hovered),
    );
  }
}

/// A week-strip day that takes a dropped task, and pages to its day when
/// one is held over it for [DotTouch.hoverSwitch].
class _DayDropTarget extends StatefulWidget {
  const _DayDropTarget({
    required this.onDrop,
    required this.builder,
    this.onHover,
  });

  final ValueChanged<String> onDrop;
  final VoidCallback? onHover;
  final Widget Function(bool hovered) builder;

  @override
  State<_DayDropTarget> createState() => _DayDropTargetState();
}

class _DayDropTargetState extends State<_DayDropTarget> {
  Timer? _hover;

  @override
  void dispose() {
    _hover?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onMove: (_) {
        final onHover = widget.onHover;
        if (onHover == null || _hover != null) return;
        _hover = Timer(DotTouch.hoverSwitch, () {
          unawaited(HapticFeedback.selectionClick());
          onHover();
        });
      },
      onLeave: (_) {
        _hover?.cancel();
        _hover = null;
      },
      onAcceptWithDetails: (details) {
        _hover?.cancel();
        _hover = null;
        unawaited(HapticFeedback.mediumImpact());
        widget.onDrop(details.data);
      },
      builder: (context, candidates, _) =>
          widget.builder(candidates.isNotEmpty),
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({
    required this.day,
    required this.narrow,
    required this.selected,
    this.hovered = false,
    this.onTap,
  });

  final StripDay day;

  /// Show [StripDay.weekdayNarrow] (the whole week does, or none).
  final bool narrow;
  final bool selected;

  /// A dragged task hovers this day.
  final bool hovered;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    // The selected day is filled in the text colour, its labels in the
    // surface colour (ADR-0015, as Structured's selected date).
    final on = selected && !hovered ? c.raised : null;
    final label = t.styles.stripWeekday.copyWith(
      color: on ?? (day.isToday ? c.accentInk : null),
    );
    // Only the weekday turns accent on today; the date stays text, muted
    // for days already gone (`Main`).
    final date = t.styles.stripDate.copyWith(
      color: on ?? (day.isPast ? c.muted : null),
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
          padding: const EdgeInsets.symmetric(vertical: DotSpace.xs),
          constraints: const BoxConstraints(minHeight: DotTouch.android),
          decoration: hovered
              ? BoxDecoration(
                  color: c.accentTint,
                  borderRadius: BorderRadius.circular(DotRadii.card),
                )
              : selected
              ? BoxDecoration(
                  color: c.text,
                  borderRadius: BorderRadius.circular(DotRadii.card),
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
              if (day.completion case final c?) CompletionDot(completion: c),
            ],
          ),
        ),
      ),
    );
  }
}
