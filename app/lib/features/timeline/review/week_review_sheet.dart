import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/review/week_review.dart';
import 'package:dottoday/features/timeline/review/week_dots_row.dart';
import 'package:dottoday/features/timeline/review/week_review_actions.dart';
import 'package:dottoday/features/timeline/review/week_review_parts.dart';
import 'package:dottoday/features/timeline/review/week_review_state.dart';
import 'package:dottoday/features/timeline/review/week_share.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// This week's content (11 D1, ED-099; E-R2-24 §1, ED-496): dates, the
/// seven days (tap one for its tasks), the chips, the sentence, the
/// carry-forward and the share image, then "No streaks here — just what
/// happened." It shows wherever the review does (`openReview`): the board's
/// iPhone sheet, and the same look inside each platform's own sheet or
/// panel.
class WeekReviewBody extends ConsumerStatefulWidget {
  const WeekReviewBody({
    required this.today,
    this.onClose,
    this.showRange = true,
    super.key,
  });

  final DateTime today;

  /// False where a header above already names the week.
  final bool showRange;

  /// Closes the sheet before "Place" or "Leave in Inbox" act.
  final VoidCallback? onClose;

  @override
  ConsumerState<WeekReviewBody> createState() => _WeekReviewBodyState();
}

class _WeekReviewBodyState extends ConsumerState<WeekReviewBody> {
  // Leaf view state (CLAUDE.md §4): the open day and the titles switch.
  DateTime? _selected;
  bool _titles = false;
  final _image = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider).value;
    if (profile == null) return const SizedBox.shrink();
    final week = reviewWeek(widget.today, profile.settings.firstDayOfWeek);
    final data = [
      for (final d in week) ref.watch(timelineDataProvider(d)).value,
    ];
    if (data.contains(null)) return const SizedBox.shrink();
    final days = data.nonNulls.toList();
    final review = weekReviewOf(days);
    final unfinished = unfinishedOf(days, widget.today);
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final sentence = weekSentence(context, review);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: WeekSize.gap,
      children: [
        if (widget.showRange)
          Text(
            weekRangeLabel(context, week),
            style: WeekType.range(t.styles, t.colors),
          ),
        _card(context, review, days.first.settings.use24h),
        WeekReviewChips(review: review),
        if (sentence.isNotEmpty)
          DecoratedBox(
            decoration: BoxDecoration(
              color: t.colors.accentTint,
              borderRadius: BorderRadius.circular(WeekSize.sentenceRadius),
            ),
            child: Padding(
              padding: WeekSize.sentencePad,
              child: Text(
                sentence,
                style: WeekType.sentence(t.styles, t.colors),
              ),
            ),
          ),
        if (unfinished.isNotEmpty)
          WeekCarryCard(
            count: unfinished.length,
            onPlace: () {
              final container = ProviderScope.containerOf(context);
              widget.onClose?.call();
              unawaited(
                placeInNextWeek(container, l10n, week: week, tasks: unfinished),
              );
            },
            onInbox: () {
              final container = ProviderScope.containerOf(context);
              final messenger = ScaffoldMessenger.of(context);
              widget.onClose?.call();
              unawaited(leaveInInbox(container, messenger, l10n, unfinished));
            },
          ),
        ..._share(context, review, week),
        Text(
          l10n.weekReviewNoStreaks,
          textAlign: TextAlign.center,
          style: WeekType.closing(t.styles, t.colors),
        ),
      ],
    );
  }

  Widget _card(BuildContext context, WeekReview review, bool? use24h) {
    final t = DotTheme.of(context);
    final open = review.days.where((d) => d.date == _selected).firstOrNull;
    final zone = ref.watch(timelineDataProvider(review.days.first.date)).value;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.raised,
        borderRadius: BorderRadius.circular(WeekSize.cardRadius),
        border: Border.all(color: t.colors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(WeekSize.cardPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: WeekSize.threadTop,
          children: [
            WeekDotsRow(
              review: review,
              selected: _selected,
              onSelect: (d) =>
                  setState(() => _selected = d == _selected ? null : d),
            ),
            if (open != null && zone != null)
              WeekDayThread(
                day: open,
                busiest: identical(open, review.busiest),
                time: (from, to) => context.l10n.threadTimeRange(
                  timeOfUtc(
                    context,
                    zone.day.location,
                    from,
                    use24h: use24hFor(context, use24h),
                  ),
                  timeOfUtc(
                    context,
                    zone.day.location,
                    to,
                    use24h: use24hFor(context, use24h),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// The share image, the titles switch and Share image (no card round
  /// them, as drawn).
  List<Widget> _share(
    BuildContext context,
    WeekReview review,
    List<DateTime> week,
  ) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return [
      WeekShareCard(
        review: review,
        range: weekRangeLabel(context, week, short: true),
        titles: _titles,
        boundary: _image,
      ),
      MergeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: WeekSize.switchRow),
          child: Row(
            spacing: WeekSize.threadGap,
            children: [
              Expanded(
                child: Text(
                  l10n.weekShareTitles,
                  style: WeekType.switchLabel(t.styles, t.colors),
                ),
              ),
              Switch.adaptive(
                value: _titles,
                onChanged: (on) => setState(() => _titles = on),
              ),
            ],
          ),
        ),
      ),
      Builder(
        builder: (button) => FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(WeekSize.shareButton),
            textStyle: WeekType.shareButton(t.styles),
            shape: const StadiumBorder(),
          ),
          onPressed: () =>
              unawaited(shareWeekImage(button, _image, week.first)),
          icon: DotIcon(
            DotGlyphs.share,
            color: t.colors.onAccent,
            size: WeekSize.shareGlyph,
          ),
          label: Text(l10n.weekShareImage),
        ),
      ),
    ];
  }
}

/// "October 18 – October 24" ([short]: "Oct 18 – Oct 24") for [week].
String weekRangeLabel(
  BuildContext context,
  List<DateTime> week, {
  bool short = false,
}) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final f = short ? DateFormat.MMMd(locale) : DateFormat.MMMMd(locale);
  return context.l10n.weekReviewDates(
    f.format(week.first),
    f.format(week.last),
  );
}
