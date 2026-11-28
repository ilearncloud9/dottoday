import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/review/week_review.dart';
import 'package:dottoday/features/timeline/review/week_review_sheet.dart';
import 'package:dottoday/features/timeline/review/week_review_state.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Day review's card (E-Phones-2): "3 of 9 done", the question, Move
/// across the card's width, then what stays and why.
class ReviewCountCard extends StatelessWidget {
  const ReviewCountCard({
    required this.count,
    required this.ask,
    this.move,
    this.staying,
    super.key,
  });

  final String count;
  final String ask;
  final Widget? move;
  final Widget? staying;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(count, style: t.styles.emptyTitle),
          ),
          const SizedBox(height: DotSpace.xs),
          Text(ask, style: t.styles.rowTitle),
          if (move case final move?) ...[
            const SizedBox(height: DotSpace.m),
            move,
          ],
          if (staying case final staying?) ...[
            const SizedBox(height: DotSpace.m),
            staying,
          ],
        ],
      ),
    );
  }
}

/// "Week in review" over "2 – 8 Nov · 9 of 16 done so far" and ›: pushes
/// Week in review where the Day review is (ED-099, E-Phones-2).
class ReviewWeekRow extends ConsumerWidget {
  const ReviewWeekRow({required this.day, required this.onTap, super.key});

  final DateTime day;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final first =
        ref.watch(currentProfileProvider).value?.settings.firstDayOfWeek ?? 1;
    final week = reviewWeek(day, first);
    final data = [
      for (final d in week) ref.watch(timelineDataProvider(d)).value,
    ];
    if (data.contains(null)) return const SizedBox.shrink();
    final days = weekReviewOf(data.nonNulls.toList()).days;
    final done = days.fold(0, (n, d) => n + d.done);
    final total = days.fold(0, (n, d) => n + d.total);
    final detail = l10n.reviewWeekRowDetail(
      weekRangeLabel(context, week, short: true),
      done,
      total,
    );
    return _Card(
      onTap: onTap,
      label: l10n.statusHintJoin(l10n.weekReviewTitle, detail),
      child: Row(
        spacing: DotSpace.m,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.weekReviewTitle, style: t.styles.rowTitle),
                Text(detail, style: t.styles.rowMeta),
              ],
            ),
          ),
          ExcludeSemantics(
            child: DotIcon(
              DotGlyphs.chevronRight,
              color: t.colors.secondary,
              size: DotSize.rowIcon,
            ),
          ),
        ],
      ),
    );
  }
}

/// A raised card with a hairline, tappable when [onTap] is set.
class _Card extends StatelessWidget {
  const _Card({required this.child, this.onTap, this.label});

  final Widget child;
  final VoidCallback? onTap;

  /// The row's one reading as a button (screen readers).
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    const radius = BorderRadius.all(Radius.circular(DotRadii.cardLarge));
    final card = Material(
      color: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: c.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(DotSpace.l), child: child),
      ),
    );
    if (label == null) return card;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: card,
    );
  }
}
