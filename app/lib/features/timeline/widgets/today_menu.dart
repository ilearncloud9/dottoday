import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/widgets/copy_day_sheet.dart';
import 'package:dottoday/features/timeline/widgets/day_review.dart';
import 'package:dottoday/features/timeline/widgets/debug_menu.dart';
import 'package:dottoday/features/timeline/widgets/export_day.dart';
import 'package:dottoday/features/timeline/widgets/running_late_sheet.dart';
import 'package:flutter/material.dart';

/// The day's ⋯ (one on every platform, beside the day dot): Running
/// late… and Review the day on today (docs/09 M3f.5); Duplicate day… and
/// Copy day as text on any day (M3f.6); the debug entries in debug
/// builds. [withLate] is false where Running late has its own button (the
/// Mac/web spread).
class TodayMenu extends StatelessWidget {
  const TodayMenu({
    required this.date,
    required this.today,
    this.withLate = true,
    super.key,
  });

  final DateTime date;
  final DateTime today;
  final bool withLate;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return PopupMenuButton<void>(
      tooltip: l10n.timelineMenu,
      icon: DotIcon(DotGlyphs.more, color: t.colors.text),
      itemBuilder: (context) => [
        if (date == today) ...[
          if (withLate)
            PopupMenuItem<void>(
              onTap: () => unawaited(showRunningLateSheet(context, today)),
              child: Text(l10n.todayMenuLate),
            ),
          PopupMenuItem<void>(
            onTap: () => unawaited(showDayReviewSheet(context, today)),
            child: Text(l10n.todayMenuReview),
          ),
        ],
        PopupMenuItem<void>(
          onTap: () => unawaited(showDuplicateDaySheet(context, source: date)),
          child: Text(l10n.todayMenuDuplicate),
        ),
        PopupMenuItem<void>(
          onTap: () => unawaited(copyDayAsText(context, date)),
          child: Text(l10n.todayMenuCopyText),
        ),
        ...debugMenuItems(context),
      ],
    );
  }
}
