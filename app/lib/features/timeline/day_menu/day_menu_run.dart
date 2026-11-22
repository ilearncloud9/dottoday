import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/shortcuts/day_action.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/low_energy.dart';
import 'package:dottoday/features/timeline/brain_dump/brain_dump_sheet.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_actions.dart';
import 'package:dottoday/features/timeline/one_thing/one_thing_sheet.dart';
import 'package:dottoday/features/timeline/review/review_presenter.dart';
import 'package:dottoday/features/timeline/review/review_state.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/state/reality_thread.dart';
import 'package:dottoday/features/timeline/state/rebalance_flow.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/copy_day_sheet.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/features/timeline/widgets/export_day.dart';
import 'package:dottoday/features/timeline/widgets/running_late_sheet.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/layout/layout_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Runs the Day menu's [action] (ED-093) for the shown [date]; Time's
/// actions act on [today]. One implementation for the Day ▾ button, the
/// Mac menu bar's Day menu and ⌘K ([DayActionScope]).
Future<void> runDayAction(
  BuildContext context,
  WidgetRef ref,
  DayAction action, {
  required DateTime date,
  required DateTime today,
}) async {
  switch (action) {
    case DayAction.extend5 || DayAction.extend15 || DayAction.extend30:
      return _extend(context, ref, today, _minutes[action]!);
    case DayAction.thenShiftRest:
      return _thenShift(context, ref, today);
    case DayAction.shiftRestFromHere:
      return showRunningLateSheet(context, today);
    case DayAction.rebalance:
      return _rebalance(context, ref, today);
    case DayAction.brainDump:
      return showBrainDump(context, date);
    case DayAction.dropRoutine:
      // Routines (11 C2, M11.4), dropping on the shown day.
      return context.push<void>(
        AppRoutes.settingsPage(SettingsPage.routines),
        extra: date,
      );
    case DayAction.oneThing:
      return showOneThingSheet(context);
    case DayAction.duplicate:
      return showDuplicateDaySheet(context, source: date);
    case DayAction.copyText:
      return copyDayAsText(context, date);
    case DayAction.reviewDay:
      return openReview(context, day: date);
    case DayAction.weekReview:
      return openReview(context, day: today, page: ReviewPage.week);
    case DayAction.goToDate:
      Actions.maybeInvoke(context, const AppCommandIntent(AppCommand.goToDate));
    case DayAction.lowEnergy:
      toggleLowEnergy(context, on: !lowEnergyNow(ref));
    case DayAction.planReality:
      final reality = ref.read(realityModeProvider.notifier);
      reality.set(on: !ref.read(realityModeProvider));
    case DayAction.showLess:
      setLayout(context, minimal: true);
    case DayAction.showEverything:
      setLayout(context, minimal: false);
    case DayAction.settings:
      context.go(AppRoutes.settings);
  }
}

const _minutes = {
  DayAction.extend5: 5,
  DayAction.extend15: 15,
  DayAction.extend30: 30,
};

/// Whether low-energy mode is on now, read once (a menu choice).
bool lowEnergyNow(WidgetRef ref) {
  final settings = ref.read(currentProfileProvider).value?.settings;
  return settings != null &&
      lowEnergyOn(settings, ref.read(clockProvider).nowUtc());
}

/// The task on now on [today], if any.
Occurrence? liveTaskOn(WidgetRef ref, DateTime today) {
  final day = ref.read(timelineDataProvider(today)).value;
  if (day == null) return null;
  final now = ref.read(clockProvider).nowUtc();
  for (final o in day.blocks) {
    final start = o.startUtc;
    if (o.status != OccurrenceStatus.planned || start == null) continue;
    if (!start.isAfter(now) && o.endUtc!.isAfter(now)) return o;
  }
  return null;
}

/// Need more time › +5 / +15 / +30: the task on now gets longer, with
/// Undo (as Now's button, ED-163).
Future<void> _extend(
  BuildContext context,
  WidgetRef ref,
  DateTime today,
  int minutes,
) async {
  final live = liveTaskOn(ref, today);
  if (live == null) return;
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final undo = ref.read(undoServiceProvider);
  reportUndoable(
    messenger,
    l10n,
    undo,
    await extendTask(ref, live, minutes: minutes),
    message: (_) => l10n.runningLateBy(minutes),
    tokenOf: (token) => token,
  );
}

/// Need more time › Then shift the rest: what overlaps the task on now
/// moves after it (R-04), as Now's Shift the rest.
Future<void> _thenShift(
  BuildContext context,
  WidgetRef ref,
  DateTime today,
) async {
  final live = liveTaskOn(ref, today);
  final day = ref.read(timelineDataProvider(today)).value;
  if (live == null || day == null) return;
  final overrun = overrunOf(live, day.blocks);
  if (overrun <= 0) return;
  if (rebalanceShiftRest(context, day.blocks, live, overrun)) return;
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final undo = ref.read(undoServiceProvider);
  reportUndoable(
    messenger,
    l10n,
    undo,
    await shiftRest(ref, day: day.blocks, live: live, overrunMinutes: overrun),
    message: (v) => l10n.snackShifted(v.$2.movedIds.length),
    tokenOf: (v) => v.$1,
  );
}

/// Rebalance…: a plan for the rest of today while the task on now runs
/// into the next one (11 C1, R2-35); nothing moves before Accept.
Future<void> _rebalance(
  BuildContext context,
  WidgetRef ref,
  DateTime today,
) async {
  final live = liveTaskOn(ref, today);
  final day = ref.read(timelineDataProvider(today)).value;
  if (live == null || day == null) return;
  final overrun = overrunOf(live, day.blocks);
  if (overrun <= 0) return;
  final l10n = context.l10n;
  await openRebalance(
    ProviderScope.containerOf(context, listen: false),
    l10n,
    today: today,
    fromUtc: ref.read(clockProvider).nowUtc(),
    deltaMin: overrun,
    subtitle: l10n.rebalanceRunsOver(
      live.title,
      formatDurationShort(l10n, overrun),
    ),
  );
}

/// Runs the Mac menu bar's Day menu (and ⌘K's) for the day on screen.
class DayActionScope extends ConsumerWidget {
  const DayActionScope({
    required this.date,
    required this.today,
    required this.child,
    super.key,
  });

  final DateTime date;
  final DateTime today;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Actions(
    actions: {
      DayActionIntent: CallbackAction<DayActionIntent>(
        onInvoke: (i) => unawaited(
          runDayAction(context, ref, i.action, date: date, today: today),
        ),
      ),
    },
    child: child,
  );
}
