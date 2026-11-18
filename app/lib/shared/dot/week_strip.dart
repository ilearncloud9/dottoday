import 'dart:async';

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/core/utils/text_fit.dart';
import 'package:dottoday/shared/dot/pointer_draggable.dart';
import 'package:dottoday/shared/dot/week_strip_parts.dart';
import 'package:dottoday/shared/haptics/app_haptics.dart';
import 'package:flutter/material.dart';

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
    this.weekdayNarrow,
    this.isToday = false,
  });

  /// "Wed".
  final String weekday;

  /// "W": shown instead of [weekday] when that doesn't fit its column on
  /// one line (large text on a phone), so it never breaks mid-word.
  final String? weekdayNarrow;

  /// "21".
  final String date;

  /// Screen-reader label, e.g. "Wednesday 21 October".
  final String label;
  final bool isToday;
}

/// Seven days (E-Phones): on iPhone a letter over the date, on Android
/// "Mon" over it; the selected day filled. Concept E draws no completion
/// dot here (M19.1); the pull handle under it opens the month where one
/// is shown.
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
    final style = DotTheme.of(context).styles.stripWeekdayAndroid;
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
          AppHaptics.play(context, HapticTick.selection);
          onHover();
        });
      },
      onLeave: (_) {
        _hover?.cancel();
        _hover = null;
      },
      onAcceptWithDetails: (details) {
        // A layout switch mid-drag cancels it (ED-100).
        if (!DragSession.live) return;
        _hover?.cancel();
        _hover = null;
        AppHaptics.play(context, HapticTick.medium);
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
    final android = DotIdiom.of(context) != DotIdiom.cupertino;
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
          constraints: const BoxConstraints(minHeight: DotTouch.android),
          decoration: hovered
              ? BoxDecoration(
                  color: DotTheme.of(context).colors.accentTint,
                  borderRadius: BorderRadius.circular(DotRadii.card),
                )
              : null,
          alignment: Alignment.center,
          child: android ? _android(context) : _iphone(context),
        ),
      ),
    );
  }

  /// iPhone (E-Phones): the weekday's letter over the date in a 34 circle;
  /// today's letter and date teal; the selected day filled, teal on today
  /// and ink elsewhere.
  Widget _iphone(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final filled = selected && !hovered;
    final fill = day.isToday ? c.accent : c.ink;
    final strong = day.isToday || filled;
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: DotSpace.xs,
      children: [
        Text(
          day.weekdayNarrow ?? day.weekday,
          style: t.styles.stripLetter.copyWith(
            color: day.isToday ? c.accent : null,
            fontWeight: day.isToday ? FontWeight.w600 : null,
          ),
        ),
        Container(
          width: DotSize.stripCircle,
          height: DotSize.stripCircle,
          alignment: Alignment.center,
          decoration: filled
              ? BoxDecoration(color: fill, shape: BoxShape.circle)
              : null,
          child: Text(
            day.date,
            style: t.styles.stripDate.copyWith(
              color: filled
                  ? (day.isToday ? c.onAccent : c.surface)
                  : day.isToday
                  ? c.accent
                  : null,
              fontWeight: strong ? FontWeight.w600 : null,
            ),
          ),
        ),
      ],
    );
  }

  /// Android (E-Phones): "Mon" over the date; the selected day in a tonal
  /// 52 × 60 pill, its date bold.
  Widget _android(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final filled = selected && !hovered;
    final on = filled ? c.onTonalAndroid : null;
    return Container(
      constraints: const BoxConstraints(
        minWidth: DotSize.stripPillWidth,
        minHeight: DotSize.stripPillHeight,
      ),
      decoration: filled
          ? BoxDecoration(
              color: c.tonalAndroid,
              borderRadius: BorderRadius.circular(DotRadii.stripPillAndroid),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: DotSpace.xxs,
        children: [
          Text(
            narrow ? day.weekdayNarrow ?? day.weekday : day.weekday,
            style: t.styles.stripWeekdayAndroid.copyWith(
              color: on ?? (day.isToday ? c.accent : null),
            ),
          ),
          Text(
            day.date,
            style: t.styles.stripDateAndroid.copyWith(
              color: on ?? (day.isToday ? c.accent : null),
              fontWeight: filled ? FontWeight.w700 : null,
            ),
          ),
        ],
      ),
    );
  }
}
