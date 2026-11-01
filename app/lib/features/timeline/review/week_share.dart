import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/review/week_review.dart';
import 'package:dottoday/features/timeline/review/week_day_dot.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The share image (`B-ios-week-review` bottom card, 11 D1): the seven
/// dots, the dates and the app's name; task titles only when [titles] is
/// on (off by default — a title can say more than the user means to
/// share). What the card shows is exactly the image `captureImage` makes
/// from [boundary].
class WeekShareCard extends StatelessWidget {
  const WeekShareCard({
    required this.review,
    required this.range,
    required this.titles,
    required this.boundary,
    super.key,
  });

  final WeekReview review;

  /// "18 – 24 Oct".
  final String range;
  final bool titles;
  final GlobalKey boundary;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return RepaintBoundary(
      key: boundary,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.colors.surface,
          borderRadius: BorderRadius.circular(DotRadii.card),
          border: Border.all(color: t.colors.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DotSpace.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: DotSpace.m,
            children: [
              _dots(),
              if (titles)
                for (final d in review.days)
                  if (d.snapshot.dots.isNotEmpty)
                    Text(
                      context.l10n.weekShareDayTitles(
                        DateFormat.E(locale).format(d.date),
                        d.snapshot.dots
                            .map((x) => x.title)
                            .join(context.l10n.semanticsSeparator),
                      ),
                      style: t.styles.rowMeta.copyWith(color: t.colors.text),
                    ),
              Row(
                children: [
                  Expanded(
                    child: Text(range.toUpperCase(), style: t.styles.caption),
                  ),
                  Text(
                    context.l10n.appTitle.toLowerCase(),
                    style: t.styles.rowMeta,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dots() => ExcludeSemantics(
    child: LayoutBuilder(
      builder: (context, box) {
        final column = box.maxWidth / review.days.length;
        final max = column < DotSize.weekShareDotMax
            ? column
            : DotSize.weekShareDotMax;
        final min = max * DotSize.weekShareDotMin / DotSize.weekShareDotMax;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (final d in review.days)
              Expanded(
                child: Center(
                  child: WeekDayDot(
                    dots: d.snapshot.dots,
                    dayEnd: d.snapshot.geometry.dayEnd,
                    diameter: weekDotDiameter(
                      d.plannedMinutes,
                      review.maxPlannedMinutes,
                      min: min,
                      maxSize: max,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}
