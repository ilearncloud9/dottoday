import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/shortcuts/day_action.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/features/timeline/day_menu/day_menu_entries.dart';
import 'package:dottoday/features/timeline/day_menu/day_menu_run.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_state.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/state/reality_thread.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/debug_menu.dart';
import 'package:dottoday/shared/menus/context_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Day menu (ED-093, G2-9; tablets ED-254): Full's Time · Plan · Day ·
/// Layout on every platform, Minimal's three items on phones and compact
/// windows, E-Minimal's list from medium width. Each platform's own menu
/// (native first): the iPhone's and iPad's pull-down, the Mac's NSMenu,
/// Material's on Android, the web's popover with the minutes as chips.
/// [button] is the Day ▾ it opens from; without one, a ⋯.
class TodayMenu extends ConsumerWidget {
  const TodayMenu({
    required this.date,
    required this.today,
    this.button,
    super.key,
  });

  final DateTime date;
  final DateTime today;
  final Widget? button;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final kind = !watchOnScreen(ref, FeatureId.dayMenuExtras)
        ? (AppLayout.classOf(context) == WidthClass.compact
              ? DayMenuKind.minimalShort
              : DayMenuKind.minimalWide)
        : DayMenuKind.full;
    final state = _state(context, ref);
    VoidCallback act(DayAction a) =>
        () =>
            unawaited(runDayAction(context, ref, a, date: date, today: today));
    return DotMenuButton<VoidCallback>(
      tooltip: l10n.timelineMenu,
      icon: button == null
          ? DotIcon(DotGlyphs.more, color: t.colors.ink)
          : null,
      child: button,
      onSelected: (run) => run(),
      entries: () => [
        ...dayMenuEntries(l10n, kind, state, act),
        if (kind == DayMenuKind.full) ...debugMenuItems(context),
      ],
    );
  }

  /// What the menu shows now: whether a task is on, runs over, and the
  /// low-energy and Plan / Reality switches.
  DayMenuState _state(BuildContext context, WidgetRef ref) {
    final blocks =
        ref.watch(timelineDataProvider(today)).value?.blocks ?? const [];
    final shown = date == today
        ? blocks
        : ref.watch(timelineDataProvider(date)).value?.blocks ?? const [];
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    final live = _live(blocks, now);
    return DayMenuState(
      isToday: date == today,
      live: live != null,
      runsOver: live != null && overrunOf(live, blocks) > 0,
      lowEnergy: watchLowEnergy(ref),
      reality: ref.watch(realityModeProvider),
      realityOffered:
          watchOnScreen(ref, FeatureId.realityThread) && hasActuals(shown),
      mac: macApp(context),
      web: webChrome(context),
    );
  }

  static Occurrence? _live(List<Occurrence> blocks, DateTime now) {
    for (final o in blocks) {
      final start = o.startUtc;
      if (o.status != OccurrenceStatus.planned || start == null) continue;
      if (!start.isAfter(now) && o.endUtc!.isAfter(now)) return o;
    }
    return null;
  }
}
