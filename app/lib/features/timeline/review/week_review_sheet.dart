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
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// "This week" (11 D1, docs/09 M12.1, `B-ios-week-review`): a sheet on
/// phones and a popover from the medium width, like the Day review (the
/// right-hand panel belongs to the proposal "Place" opens). From Today's ⋯
/// at any time, and at Bedtime on the week's last day.
Future<void> showWeekReview(BuildContext context, DateTime today) =>
    showAppSheet<void>(
      context: context,
      title: context.l10n.weekReviewTitle,
      builder: (sheet) => WeekReviewBody(
        today: today,
        onClose: () => Navigator.of(sheet).pop(),
      ),
    );

/// The review's content: dates, the seven dots (tap one for its thread),
/// the chips, the sentence, the carry-forward and the share image, then
/// "No streaks here — just what happened."
class WeekReviewBody extends ConsumerStatefulWidget {
  const WeekReviewBody({required this.today, this.onClose, super.key});

  final DateTime today;

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
    final range = _range(context, week);
    final sentence = weekSentence(context, review);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.l,
      children: [
        Text(range, style: t.styles.body.copyWith(color: t.colors.muted)),
        _card(context, review, days.first.settings.use24h),
        WeekReviewChips(review: review),
        if (sentence.isNotEmpty)
          DecoratedBox(
            decoration: BoxDecoration(
              color: t.colors.muted.withValues(
                alpha: t.colors.isDark
                    ? TaskAlpha.tintDark
                    : TaskAlpha.tintLight,
              ),
              borderRadius: BorderRadius.circular(DotRadii.card),
            ),
            child: Padding(
              padding: const EdgeInsets.all(DotSpace.l),
              child: Text(sentence, style: t.styles.body),
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
        _share(context, review, week),
        Text(
          l10n.weekReviewNoStreaks,
          textAlign: TextAlign.center,
          style: t.styles.rowMeta,
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
        borderRadius: BorderRadius.circular(DotRadii.cardLarge),
        border: Border.all(color: t.colors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DotSpace.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DotSpace.m,
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

  Widget _share(BuildContext context, WeekReview review, List<DateTime> week) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DotRadii.cardLarge),
        border: Border.all(color: t.colors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DotSpace.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DotSpace.s,
          children: [
            WeekShareCard(
              review: review,
              range: _range(context, week, short: true),
              titles: _titles,
              boundary: _image,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.weekShareTitles, style: t.styles.body),
              value: _titles,
              onChanged: (on) => setState(() => _titles = on),
            ),
            Builder(
              builder: (button) => FilledButton.icon(
                onPressed: () =>
                    unawaited(shareWeekImage(button, _image, week.first)),
                icon: DotIcon(
                  DotGlyphs.share,
                  color: t.colors.onAccent,
                  size: DotSize.rowIcon,
                ),
                label: Text(l10n.weekShareImage),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "Oct 18 – Oct 24".
  static String _range(
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
}
