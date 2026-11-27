import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/review/week_review.dart';
import 'package:dottoday/features/timeline/review/week_ring.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The share image (11 D1; E-R2-24 §1, ED-496): "NOV 2 – NOV 8", the seven
/// rings with their letters, "dottoday", centred on the page colour; task
/// titles only when [titles] is on (off by default — a title can say more
/// than the user means to share). What the card shows is exactly the
/// image `captureImage` makes from [boundary].
class WeekShareCard extends StatelessWidget {
  const WeekShareCard({
    required this.review,
    required this.range,
    required this.titles,
    required this.boundary,
    super.key,
  });

  final WeekReview review;

  /// "Nov 2 – Nov 8".
  final String range;
  final bool titles;
  final GlobalKey boundary;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return RepaintBoundary(
      key: boundary,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(WeekSize.shareRadius),
          border: Border.all(color: c.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(WeekSize.sharePad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                range.toUpperCase(),
                textAlign: TextAlign.center,
                style: WeekType.shareRange(t.styles, c),
              ),
              const SizedBox(height: WeekSize.shareRingsTop),
              ExcludeSemantics(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final d in review.days)
                      Column(
                        spacing: WeekSize.shareLetterGap,
                        children: [
                          WeekRing(
                            done: d.done,
                            total: d.total,
                            size: WeekSize.shareRing,
                            stroke: WeekSize.shareRingStroke,
                          ),
                          Text(
                            DateFormat.EEEEE(locale).format(d.date),
                            style: WeekType.shareLetter(t.styles, c),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (titles)
                for (final d in review.days)
                  if (d.snapshot.dots.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: DotSpace.s),
                      child: Text(
                        context.l10n.weekShareDayTitles(
                          DateFormat.E(locale).format(d.date),
                          d.snapshot.dots
                              .map((x) => x.title)
                              .join(context.l10n.semanticsSeparator),
                        ),
                        style: WeekType.shareTitles(t.styles, c),
                      ),
                    ),
              const SizedBox(height: WeekSize.shareNameTop),
              Text(
                context.l10n.appTitle.toLowerCase(),
                textAlign: TextAlign.center,
                style: WeekType.shareName(t.styles, c),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
