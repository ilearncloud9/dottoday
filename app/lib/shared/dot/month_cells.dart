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

/// Expanded cell (`A-mac-month`): a card with the date, a completion badge,
/// the day's tasks (done struck, "· missed", "· now"), "+N more" and
/// "N of M done" or "Light day".
class ExpandedMonthCell extends StatelessWidget {
  const ExpandedMonthCell({required this.day, this.onTap, super.key});

  final MonthDay day;
  final VoidCallback? onTap;

  static const _shown = 3;
  static const double _minHeight = 150;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final l10n = context.l10n;
    final hidden = math.max(0, day.items.length - _shown);
    final footer = day.isPast && day.total > 0
        ? l10n.monthDoneOf(day.done, day.total)
        : day.isLight
        ? l10n.monthLightDay
        : null;
    return Semantics(
      button: onTap != null,
      label: day.label,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: day.isPast ? c.surface : c.raised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DotRadii.card),
          side: day.isToday
              ? BorderSide(color: c.accent, width: DotSize.smallDotOutline)
              : BorderSide(color: c.outline, width: DotSpace.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _minHeight),
            child: Padding(
              padding: const EdgeInsets.all(DotSpace.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: DotSpace.xs,
                children: [
                  _CellHeader(day: day),
                  for (final item in day.items.take(_shown)) _Item(item: item),
                  if (hidden > 0)
                    Text(l10n.monthMore(hidden), style: t.styles.rowMeta),
                  if (footer != null) ...[
                    const Spacer(),
                    Text(footer, style: t.styles.rowMeta),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CellHeader extends StatelessWidget {
  const _CellHeader({required this.day});

  final MonthDay day;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final date = t.styles.rowTitle.copyWith(fontWeight: FontWeight.w600);
    return Row(
      children: [
        if (day.isToday)
          Container(
            width: DotSize.macRowDot + DotSpace.xxs,
            height: DotSize.macRowDot + DotSpace.xxs,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c.accent),
            child: Text(day.date, style: date.copyWith(color: c.onAccent)),
          )
        else
          Text(
            day.date,
            style: date.copyWith(color: day.isPast ? c.muted : c.text),
          ),
        const Spacer(),
        if (day.isPast || day.isToday)
          _Badge(completion: day.completion, today: day.isToday),
      ],
    );
  }
}

/// Top-right completion badge: success check when all done, success pie
/// when partly, a hairline disc when nothing got done (today: accent pie).
class _Badge extends StatelessWidget {
  const _Badge({required this.completion, required this.today});

  final Completion? completion;
  final bool today;

  static const double _size = DotSize.pickerDot;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final share = completion?.share ?? 0;
    if (share >= 1) {
      return Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: c.success),
        child: DotIcon(
          DotGlyphs.check,
          color: c.raised,
          size: _size,
          active: true,
        ),
      );
    }
    return CustomPaint(
      size: const Size.square(_size),
      painter: _PieBadge(
        share: share,
        fill: today ? c.accent : c.success,
        track: today ? Color.alphaBlend(c.accentTint, c.raised) : c.outline,
      ),
    );
  }
}

final class _PieBadge extends CustomPainter {
  const _PieBadge({
    required this.share,
    required this.fill,
    required this.track,
  });

  final double share;
  final Color fill;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawOval(rect, Paint()..color = track);
    if (share > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * share,
        true,
        Paint()..color = fill,
      );
    }
  }

  @override
  bool shouldRepaint(_PieBadge old) =>
      old.share != share || old.fill != fill || old.track != track;
}

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
    final style = t.styles.body.copyWith(
      color: item.done ? c.muted : (item.now ? c.accentInk : c.text),
      fontWeight: item.now ? FontWeight.w600 : null,
      decoration: item.done ? TextDecoration.lineThrough : null,
      decorationColor: c.muted,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DotSpace.s,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: DotSpace.s),
          child: Container(
            width: DotSize.weekDot,
            height: DotSize.weekDot,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.missed ? null : item.color.color,
              border: item.missed
                  ? Border.all(
                      color: item.color.color,
                      width: DotSize.smallDotOutline / 2,
                    )
                  : null,
            ),
          ),
        ),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }
}
