import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/review/week_review.dart';
import 'package:dottoday/features/timeline/review/week_day_dot.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The seven dots with their weekday letter and date (`B-ios-week-review`).
/// Each column is one tap target that opens the day's thread; [selected]
/// is the open one.
class WeekDotsRow extends StatelessWidget {
  const WeekDotsRow({
    required this.review,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final WeekReview review;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    // At large text the count no longer fits inside a dot: it moves under
    // the date instead of being clipped or shrunk (Dynamic Type, R-12).
    final countInside =
        MediaQuery.textScalerOf(context).scale(DotSize.rowIcon) <=
        DotSize.rowIcon * 1.3;
    return LayoutBuilder(
      builder: (context, box) {
        final column = box.maxWidth / review.days.length;
        final max = column < DotSize.weekReviewDotMax
            ? column
            : DotSize.weekReviewDotMax;
        final min = max * DotSize.weekReviewDotMin / DotSize.weekReviewDotMax;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final d in review.days)
              Expanded(
                child: _DayColumn(
                  day: d,
                  diameter: weekDotDiameter(
                    d.plannedMinutes,
                    review.maxPlannedMinutes,
                    min: min,
                    maxSize: max,
                  ),
                  selected: d.date == selected,
                  countInside: countInside,
                  locale: locale,
                  onTap: () => onSelect(d.date),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.day,
    required this.diameter,
    required this.selected,
    required this.countInside,
    required this.locale,
    required this.onTap,
  });

  final WeekReviewDay day;
  final double diameter;
  final bool selected;
  final bool countInside;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final count = l10n.weekReviewDotCount(day.done, day.total);
    final dateStyle = t.styles.rowMeta.copyWith(
      color: selected ? t.colors.text : t.colors.muted,
      fontWeight: selected ? FontWeight.w700 : null,
    );
    return Semantics(
      button: true,
      selected: selected,
      label: l10n.weekReviewDayLabel(
        DateFormat.MMMMEEEEd(locale).format(day.date),
        day.done,
        day.total,
        formatDurationShort(l10n, day.plannedMinutes),
      ),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DotRadii.card),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotTouch.min),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: DotSpace.xs,
            children: [
              WeekDayDot(
                dots: day.snapshot.dots,
                diameter: diameter,
                centre: countInside ? count : null,
                selected: selected,
              ),
              Text(
                DateFormat.EEEEE(locale).format(day.date),
                style: t.styles.rowMeta.copyWith(color: t.colors.muted),
              ),
              Text(DateFormat.d(locale).format(day.date), style: dateStyle),
              if (!countInside) Text(count, style: t.styles.rowMeta),
            ],
          ),
        ),
      ),
    );
  }
}
