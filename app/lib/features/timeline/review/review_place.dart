import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/review/week_review.dart';
import 'package:dottoday/features/timeline/review/review_state.dart';
import 'package:dottoday/features/timeline/review/week_review_sheet.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_review.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// The Workspace's Review place (ED-099, E-FullA-v2): Day review and Week
/// in review as two halves of one place, side by side when both fit, else
/// one above the other; each steps with ‹ › (days, weeks) and goes no
/// further than the review's own day. Sidebar Review, Day › Review the
/// Day, ⌘K, the Wind Down notification and `/review` land here in Full at
/// the expanded width.
class ReviewPlace extends ConsumerStatefulWidget {
  const ReviewPlace({super.key});

  @override
  ConsumerState<ReviewPlace> createState() => _ReviewPlaceState();
}

/// A leaf: the week shown, stepped apart from the day.
class _ReviewPlaceState extends ConsumerState<ReviewPlace> {
  DateTime? _week;

  @override
  Widget build(BuildContext context) {
    final latest = ref.watch(reviewDateProvider).value;
    final settings = ref.watch(currentProfileProvider).value?.settings;
    if (latest == null || settings == null) return const SizedBox.shrink();
    final picked = ref.watch(reviewPlaceDayProvider);
    final day = picked == null || picked.isAfter(latest) ? latest : picked;
    // A new entry (another day picked) brings its week along.
    ref.listen(reviewPlaceDayProvider, (_, _) => setState(() => _week = null));
    final weekDay = _week ?? day;
    final first = settings.firstDayOfWeek;
    final week = reviewWeek(weekDay, first);
    final lastWeek = reviewWeek(latest, first).first;
    final l10n = context.l10n;
    final place = ref.read(reviewPlaceDayProvider.notifier);
    final dayHalf = _Half(
      title: l10n.reviewTitle,
      subtitle: DateFormat.MMMEd(
        Localizations.localeOf(context).toLanguageTag(),
      ).format(day),
      previous: l10n.spreadPreviousDay,
      next: l10n.spreadNextDay,
      onPrevious: () => place.show(_step(day, -1)),
      onNext: day == latest ? null : () => place.show(_step(day, 1)),
      child: DayReviewBody(key: ValueKey(day), day: day),
    );
    final weekHalf = _Half(
      title: l10n.weekReviewTitle,
      subtitle: weekRangeLabel(context, week, short: true),
      previous: l10n.weekPrevious,
      next: l10n.weekNext,
      onPrevious: () => setState(() => _week = _step(weekDay, -7)),
      onNext: week.first == lastWeek
          ? null
          : () => setState(() => _week = _step(weekDay, 7)),
      child: WeekReviewBody(
        key: ValueKey(week.first),
        today: week.last.isAfter(latest) ? latest : week.last,
        showRange: false,
      ),
    );
    // A Material, so the switches and rows inside show their ink.
    return Material(
      color: DotTheme.of(context).colors.ground,
      child: LayoutBuilder(
        builder: (context, box) {
          const pad = EdgeInsets.all(DotSpace.xl);
          if (box.maxWidth >= DotSize.reviewHalfMin * 2 + DotSpace.xl * 3) {
            return SingleChildScrollView(
              padding: pad,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: DotSpace.xl,
                children: [
                  Expanded(child: dayHalf),
                  Expanded(child: weekHalf),
                ],
              ),
            );
          }
          return ListView(
            padding: pad,
            children: [
              dayHalf,
              const SizedBox(height: DotSpace.xxl),
              weekHalf,
            ],
          );
        },
      ),
    );
  }

  static DateTime _step(DateTime d, int days) =>
      DateTime(d.year, d.month, d.day + days);
}

/// One half: its heading, the date or week under it with ‹ ›, its body.
class _Half extends StatelessWidget {
  const _Half({
    required this.title,
    required this.subtitle,
    required this.previous,
    required this.next,
    required this.onPrevious,
    required this.onNext,
    required this.child,
  });

  final String title;
  final String subtitle;
  final String previous;
  final String next;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(header: true, child: Text(title, style: t.styles.sheetTitle)),
        Row(
          children: [
            Flexible(child: Text(subtitle, style: t.styles.sheetSubtitle)),
            IconButton(
              tooltip: previous,
              onPressed: onPrevious,
              icon: DotIcon(DotGlyphs.chevronLeft, color: c.secondary),
            ),
            IconButton(
              tooltip: next,
              onPressed: onNext,
              icon: DotIcon(
                DotGlyphs.chevronRight,
                color: onNext == null ? c.placeholder : c.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: DotSpace.s),
        child,
      ],
    );
  }
}
