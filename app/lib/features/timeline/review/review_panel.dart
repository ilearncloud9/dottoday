import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/review/week_review.dart';
import 'package:dottoday/features/timeline/review/review_state.dart';
import 'package:dottoday/features/timeline/review/week_review_sheet.dart';
import 'package:dottoday/features/timeline/widgets/day_review.dart';
import 'package:dottoday/shared/navigation/landing_title.dart';
import 'package:dottoday/shared/sheets/sheet_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// The one review's content (ED-099, E-Phones-2, E-R2-14): "Day review"
/// over its date and Close, the Day review, and the Week in review row
/// that pushes Week in review in the same place; Back (or the system's)
/// returns. The sheet, the dialog and the tablet pane show it as is;
/// Minimal's Day column passes [column] for its caption and no week.
class ReviewPanel extends ConsumerStatefulWidget {
  const ReviewPanel({
    required this.day,
    required this.onClose,
    this.page = ReviewPage.day,
    this.column = false,
    super.key,
  });

  final DateTime day;
  final ReviewPage page;
  final VoidCallback onClose;

  /// Minimal's Day column (E-Minimal): a caption, no Week in review.
  final bool column;

  @override
  ConsumerState<ReviewPanel> createState() => _ReviewPanelState();
}

/// A leaf: which page shows, and whether Week was pushed over the day.
class _ReviewPanelState extends ConsumerState<ReviewPanel> {
  late var _page = widget.page;
  var _pushed = false;

  void _week() => setState(() {
    _page = ReviewPage.week;
    _pushed = true;
  });

  void _back() => setState(() {
    _page = ReviewPage.day;
    _pushed = false;
  });

  @override
  Widget build(BuildContext context) {
    final week = _page == ReviewPage.week && !widget.column;
    final weekRow = !widget.column && watchOnScreen(ref, FeatureId.weekReview);
    final body = week
        ? WeekReviewBody(
            key: const ValueKey(ReviewPage.week),
            today: widget.day,
            onClose: widget.onClose,
            showRange: false,
          )
        : DayReviewBody(
            key: const ValueKey(ReviewPage.day),
            day: widget.day,
            onDone: widget.onClose,
            onWeek: weekRow ? _week : null,
          );
    return PopScope(
      // Back from a pushed Week returns to the Day review first.
      canPop: !_pushed,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _pushed) _back();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: DotSpace.m),
            child: widget.column ? _caption(context) : _header(context, week),
          ),
          Flexible(child: SingleChildScrollView(child: body)),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, bool week) {
    final l10n = context.l10n;
    final header = SheetHeader(
      title: week ? l10n.weekReviewTitle : l10n.reviewTitle,
      subtitle: week ? _range(context) : _date(context),
      onClose: widget.onClose,
    );
    if (!_pushed) return header;
    final t = DotTheme.of(context);
    return Row(
      children: [
        IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: _back,
          icon: DotIcon(DotGlyphs.chevronLeft, color: t.colors.text),
        ),
        Expanded(child: header),
      ],
    );
  }

  /// "Day review · Tue 3 Nov" and Close (E-Minimal's Day column).
  Widget _caption(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Row(
      spacing: DotSpace.s,
      children: [
        Expanded(
          // Focus lands here when the review opens (ED-248 A).
          child: LandingTitle(
            child: Text(
              l10n.reviewColumnCaption(_date(context)),
              style: t.styles.caption.copyWith(color: t.colors.muted),
            ),
          ),
        ),
        SheetCloseButton(onPressed: widget.onClose),
      ],
    );
  }

  String _date(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.MMMEd(locale).format(widget.day);
  }

  String _range(BuildContext context) {
    final first =
        ref.watch(currentProfileProvider).value?.settings.firstDayOfWeek ?? 1;
    return weekRangeLabel(context, reviewWeek(widget.day, first), short: true);
  }
}
