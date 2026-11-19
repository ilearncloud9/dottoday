import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/month_models.dart';
import 'package:dottoday/shared/dot/week_strip.dart';
import 'package:flutter/material.dart';

/// Compact cell (`A-ios-today-month`, `A-ios-future-month`): the date,
/// accent-filled when selected, over its completion or planned dots.
class CompactMonthCell extends StatelessWidget {
  const CompactMonthCell({
    required this.day,
    this.selected = false,
    this.onTap,
    super.key,
  });

  final MonthDay day;
  final bool selected;
  final VoidCallback? onTap;

  static const double _selection = DotSize.rowDot;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final date = t.styles.monthDate.copyWith(
      color: selected ? c.onAccent : (day.isPast ? c.muted : c.text),
      fontWeight: selected ? FontWeight.w700 : null,
    );
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: day.label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotTouch.android),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: _selection,
                height: _selection,
                alignment: Alignment.center,
                decoration: selected
                    ? BoxDecoration(shape: BoxShape.circle, color: c.accent)
                    : null,
                child: Text(day.date, style: date),
              ),
              SizedBox(height: DotSize.weekDot + DotSpace.xs, child: _dots()),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _dots() {
    if (day.planned.isNotEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: DotSpace.xxs,
        children: [
          for (final color in day.planned.take(3)) _Pip(color: color.color),
        ],
      );
    }
    if (day.repeatsOnly) {
      return const CompletionDot(completion: Completion.none());
    }
    return switch (day.completion) {
      final completion? => CompletionDot(completion: completion),
      null => null,
    };
  }
}

/// One solid planned-task dot.
class _Pip extends StatelessWidget {
  const _Pip({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: DotSize.weekDot,
    height: DotSize.weekDot,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}

/// Expanded cell (E-R2-30, ED-333): a card with the date, the day's first
/// three tasks (done struck, "· not done", "· now"), "+N more" in teal,
/// then "N of M done", or "Light day" when nothing is planned. Today has
/// the teal edge. A day of the month either side is its faded number only.
class ExpandedMonthCell extends StatelessWidget {
  const ExpandedMonthCell({
    required this.day,
    this.onTap,
    this.focusNode,
    super.key,
  });

  final MonthDay day;
  final VoidCallback? onTap;

  /// The card's focus, so the grid's arrow keys reach it.
  final FocusNode? focusNode;

  static const _shown = 3;

  /// E-R2-30: 104 tall at 100 % text; larger text grows the row.
  static const double _minHeight = 104;
  static const _padding = EdgeInsets.symmetric(
    horizontal: DotSpace.s,
    vertical: DotSpace.xs + DotSpace.xxs,
  );

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    if (day.outside) {
      return ExcludeSemantics(
        child: Padding(
          padding: _padding,
          child: Text(
            day.date,
            style: t.styles.monthCellDate.copyWith(color: c.tertiary),
          ),
        ),
      );
    }
    return Semantics(
      button: onTap != null,
      label: day.label,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: c.raised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DotRadii.monthCard),
          side: day.isToday
              ? BorderSide(color: c.accent, width: DotSize.smallDotOutline)
              : BorderSide(color: c.gridDivider, width: DotSpace.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          focusNode: focusNode,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _minHeight),
            child: Padding(padding: _padding, child: _lines(context)),
          ),
        ),
      ),
    );
  }

  Widget _lines(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final l10n = context.l10n;
    final hidden = math.max(0, day.items.length - _shown);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          day.date,
          style: t.styles.monthCellDate.copyWith(
            color: day.isToday ? c.accentInk : null,
          ),
        ),
        for (final item in day.items.take(_shown)) _Item(item: item),
        if (hidden > 0)
          Text(
            l10n.monthMore(hidden),
            style: t.styles.monthItem.copyWith(color: c.accent),
          ),
        if (day.total > 0)
          Padding(
            padding: const EdgeInsets.only(top: DotSpace.xxs),
            child: Text(
              l10n.monthDoneOf(day.done, day.total),
              style: t.styles.monthFooter,
            ),
          )
        else if (day.isLight)
          Padding(
            padding: const EdgeInsets.only(top: DotSpace.xs),
            child: Text(l10n.monthLightDay, style: t.styles.monthFooter),
          ),
      ],
    );
  }
}

/// One task line. E-R2-30 cuts a long one with "…"; here it wraps, so no
/// language loses words (the locale sweep) and the card grows.
class _Item extends StatelessWidget {
  const _Item({required this.item});

  final MonthItem item;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final l10n = context.l10n;
    final text = item.missed
        ? l10n.monthMissedItem(item.title)
        : item.now
        ? l10n.monthNowItem(item.title)
        : item.title;
    return Text(
      text,
      style: t.styles.monthItem.copyWith(
        color: item.done ? c.muted : null,
        decoration: item.done ? TextDecoration.lineThrough : null,
        decorationColor: c.muted,
      ),
    );
  }
}
