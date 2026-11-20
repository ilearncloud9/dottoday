import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/features/timeline/brain_dump/brain_dump_sheet.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_actions.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_state.dart';
import 'package:dottoday/features/timeline/one_thing/one_thing_sheet.dart';
import 'package:dottoday/features/timeline/review/week_review_sheet.dart';
import 'package:dottoday/features/timeline/widgets/copy_day_sheet.dart';
import 'package:dottoday/features/timeline/widgets/day_review.dart';
import 'package:dottoday/features/timeline/widgets/debug_menu.dart';
import 'package:dottoday/features/timeline/widgets/export_day.dart';
import 'package:dottoday/features/timeline/widgets/running_late_sheet.dart';
import 'package:dottoday/shared/layout/layout_switch.dart';
import 'package:dottoday/shared/menus/context_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The day's ⋯ (one on every platform, beside the day dot): Running
/// late… and Review the day on today (docs/09 M3f.5), This week (M12.1); Duplicate day… and
/// Copy day as text on any day (M3f.6); Routines… to drop one on the day
/// (M11.4); the debug entries in debug
/// builds. [withLate] is false where Running late has its own button (the
/// Mac/web spread).
///
/// The layout switch comes first in both layouts (docs/14 §2.6, §5): Show
/// less here, Show everything in minimal, whose menu is that, Low-energy
/// day and Settings only (§4).
class TodayMenu extends ConsumerWidget {
  const TodayMenu({
    required this.date,
    required this.today,
    this.withLate = true,
    this.button,
    super.key,
  });

  final DateTime date;
  final DateTime today;
  final bool withLate;

  /// The Workspace toolbar's "Day ▾" in place of ⋯ (owner, M19.2); the
  /// items are the same until M20.3 groups them.
  final Widget? button;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final low = watchLowEnergy(ref);
    final l10n = context.l10n;
    if (!watchOnScreen(ref, FeatureId.dayMenuExtras)) {
      return DotMenuButton<VoidCallback>(
        tooltip: l10n.timelineMenu,
        icon: button == null
            ? DotIcon(DotGlyphs.more, color: t.colors.text)
            : null,
        child: button,
        onSelected: (run) => run(),
        entries: () => [
          ContextMenuEntry(
            value: () => setLayout(context, minimal: false),
            label: l10n.layoutShowEverything,
          ),
          ContextMenuEntry(
            value: () => toggleLowEnergy(context, on: !low),
            label: low ? l10n.lowEnergyTurnOff : l10n.lowEnergyMode,
          ),
          ContextMenuEntry(
            value: () => context.go(AppRoutes.settings),
            label: l10n.navSettings,
          ),
        ],
      );
    }
    return DotMenuButton<VoidCallback>(
      tooltip: l10n.timelineMenu,
      icon: button == null
          ? DotIcon(DotGlyphs.more, color: t.colors.text)
          : null,
      child: button,
      onSelected: (run) => run(),
      entries: () => [
        ContextMenuEntry(
          value: () => setLayout(context, minimal: true),
          label: l10n.layoutShowLess,
        ),
        if (date == today) ...[
          if (withLate)
            ContextMenuEntry(
              value: () => unawaited(showRunningLateSheet(context, today)),
              label: l10n.todayMenuLate,
            ),
          ContextMenuEntry(
            value: () => unawaited(showDayReviewSheet(context, today)),
            label: l10n.todayMenuReview,
          ),
          // Brain dump (11 B4, M12.5): everything on your mind → a plan.
          ContextMenuEntry(
            value: () => unawaited(showBrainDump(context, today)),
            label: l10n.dumpTitle,
          ),
          // Today's one thing (15 §8, owner 2026-11-01): any time of day.
          ContextMenuEntry(
            value: () => unawaited(showOneThingSheet(context)),
            label: l10n.oneThingMenu,
          ),
          // Low-energy mode (11 D2, M12.2): on until the next Wake Up.
          ContextMenuEntry(
            value: () => toggleLowEnergy(context, on: !low),
            label: low ? l10n.lowEnergyTurnOff : l10n.lowEnergyMode,
          ),
          // The weekly review on demand (11 D1, M12.1).
          ContextMenuEntry(
            value: () => unawaited(showWeekReview(context, today)),
            label: l10n.weekReviewTitle,
          ),
        ],
        ContextMenuEntry(
          value: () => unawaited(showDuplicateDaySheet(context, source: date)),
          label: l10n.todayMenuDuplicate,
        ),
        ContextMenuEntry(
          value: () => unawaited(copyDayAsText(context, date)),
          label: l10n.todayMenuCopyText,
        ),
        // Routines (11 C2, M11.4): drop one on this day.
        ContextMenuEntry(
          value: () => unawaited(
            context.push(
              AppRoutes.settingsPage(SettingsPage.routines),
              extra: date,
            ),
          ),
          label: l10n.routinesMenu,
        ),
        ...debugMenuItems(context),
      ],
    );
  }
}
