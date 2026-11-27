import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/review/week_review.dart';
import 'package:dottoday/features/timeline/review/week_ring.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The seven days of This week (E-R2-24 §1, ED-496): each column the
/// weekday's letter, its ring and "done/total", one tap target that opens
/// the day's tasks; [selected] sits on the accent's tint.
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: WeekSize.columnGap,
      children: [
        for (final d in review.days)
          Expanded(
            child: _DayColumn(
              day: d,
              selected: d.date == selected,
              locale: locale,
              onTap: () => onSelect(d.date),
            ),
          ),
      ],
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.day,
    required this.selected,
    required this.locale,
    required this.onTap,
  });

  final WeekReviewDay day;
  final bool selected;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final l10n = context.l10n;
    final radius = BorderRadius.circular(WeekSize.columnRadius);
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
      child: Material(
        color: selected ? c.accentTint : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: DotTouch.min),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: WeekSize.columnPad),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: WeekSize.columnLines,
                children: [
                  Text(
                    DateFormat.EEEEE(locale).format(day.date),
                    style: WeekType.letter(t.styles, c),
                  ),
                  WeekRing(done: day.done, total: day.total),
                  Text(
                    l10n.weekReviewDotCount(day.done, day.total),
                    textAlign: TextAlign.center,
                    style: WeekType.count(t.styles, c),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
