import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_actions.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_state.dart';
import 'package:dottoday/features/timeline/review/week_review_sheet.dart';
import 'package:dottoday/features/timeline/widgets/copy_day_sheet.dart';
import 'package:dottoday/features/timeline/widgets/day_review.dart';
import 'package:dottoday/features/timeline/widgets/debug_menu.dart';
import 'package:dottoday/features/timeline/widgets/export_day.dart';
import 'package:dottoday/features/timeline/widgets/running_late_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The day's ⋯ (one on every platform, beside the day dot): Running
/// late… and Review the day on today (docs/09 M3f.5), This week (M12.1); Duplicate day… and
/// Copy day as text on any day (M3f.6); Routines… to drop one on the day
/// (M11.4); the debug entries in debug
/// builds. [withLate] is false where Running late has its own button (the
/// Mac/web spread).
class TodayMenu extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final low = watchLowEnergy(ref);
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
          // Low-energy mode (11 D2, M12.2): on until the next Wake Up.
          PopupMenuItem<void>(
            onTap: () => toggleLowEnergy(context, on: !low),
            child: Text(low ? l10n.lowEnergyTurnOff : l10n.lowEnergyMode),
          ),
          // The weekly review on demand (11 D1, M12.1).
          PopupMenuItem<void>(
            onTap: () => unawaited(showWeekReview(context, today)),
            child: Text(l10n.weekReviewTitle),
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
        // Routines (11 C2, M11.4): drop one on this day.
        PopupMenuItem<void>(
          onTap: () => unawaited(
            context.push(
              AppRoutes.settingsPage(SettingsPage.routines),
              extra: date,
            ),
          ),
          child: Text(l10n.routinesMenu),
        ),
        ...debugMenuItems(context),
      ],
    );
  }
}
