import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/router/show_place.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_state.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_view.dart';
import 'package:dottoday/features/timeline/state/task_selection.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/state/today_selection.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_gate.dart';
import 'package:dottoday/features/timeline/widgets/all_day_chips.dart';
import 'package:dottoday/features/timeline/widgets/day_page.dart';
import 'package:dottoday/features/timeline/widgets/reveal_hint_row.dart';
import 'package:dottoday/features/timeline/widgets/selection_bar.dart';
import 'package:dottoday/features/timeline/widgets/today_day_wide.dart';
import 'package:dottoday/features/timeline/widgets/today_header.dart';
import 'package:dottoday/features/timeline/widgets/today_keys.dart';
import 'package:dottoday/features/timeline/widgets/today_month.dart';
import 'package:dottoday/features/timeline/widgets/today_prompt.dart';
import 'package:dottoday/features/timeline/widgets/today_three_days.dart';
import 'package:dottoday/features/timeline/widgets/today_week_strip.dart';
import 'package:dottoday/shared/dot/day_pager.dart';
import 'package:dottoday/shared/dot/week_strip.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// How far the pager reaches each side of today (docs/10 §3 `DayPager`).
const pagerReachDays = 365;

/// Today (docs/10 §5.2 T1, `Main`): greeting header with the day dot, the
/// week strip and its month pull-open, all-day chips, and the day pager;
/// at the expanded width the three-day spread (T5, M3e.1), except in the
/// minimal layout (docs/14 §3).
/// [date] opens another day (`/day/:date`); otherwise it follows today.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({this.date, this.threeDays = false, super.key});

  final DateTime? date;

  /// The Workspace's 3 days view (`/3-days/<date>`, ED-333); off, Day.
  /// Only the expanded width tells them apart; phones show their Today.
  final bool threeDays;

  /// What Today needs before it can draw (docs/09 M3f.9b).
  static List<AsyncValue<Object?>> _inputs(WidgetRef ref) => [
    ref.watch(todayDateProvider),
    ref.watch(currentProfileProvider),
  ];

  static void _retry(WidgetRef ref) => ref
    ..invalidate(todayDateProvider)
    ..invalidate(currentProfileProvider);

  /// [date] when the pager reaches it (±[pagerReachDays] from [today]);
  /// a link further out opens today rather than a page the pager lacks.
  static DateTime? _reachable(DateTime? date, DateTime today) {
    if (date == null) return null;
    final days = DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime.utc(today.year, today.month, today.day)).inDays;
    return days.abs() <= pagerReachDays ? date : null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(todaySelectionProvider);
    final key = ValueKey(
      date == null
          ? 'route:today'
          : 'route:${threeDays ? '3-days' : 'day'}:${formatRouteDate(date!)}',
    );
    if (waitFor(key, _inputs(ref), onRetry: () => _retry(ref)) case final w?) {
      return w;
    }
    final today = ref.watch(todayDateProvider).requireValue;
    final profile = ref.watch(currentProfileProvider).requireValue;
    final shown = _reachable(date, today) ?? today;
    final month = view.month ?? DateTime(shown.year, shown.month);
    // The address is the shown day (ED-097): today follows midnight.
    void select(DateTime d) {
      ref.read(todaySelectionProvider.notifier).followDay();
      // 3 days keeps its view as it steps (ED-333).
      showPlace(
        GoRouter.of(context),
        threeDays
            ? AppRoutes.threeDays(d)
            : d == today
            ? AppRoutes.today
            : AppRoutes.day(d),
      );
    }

    ref.listen(
      taskSelectionProvider,
      (before, now) => announceSelection(context, before, now),
    );
    final selecting = ref.watch(
      taskSelectionProvider.select((p) => p.ids.isNotEmpty),
    );
    // Minimal (docs/14 §3): Today alone at every width, no spread.
    final spread = !watchSimplified(ref, FeatureId.spread);
    final screen = PopScope(
      // Back ends selecting before it leaves the screen (R-05).
      canPop: !selecting,
      onPopInvokedWithResult: (popped, _) {
        if (!popped) ref.read(taskSelectionProvider.notifier).clear();
      },
      child: TodayKeys(
        shown: shown,
        today: today,
        onSelect: select,
        child: Scaffold(
          key: key,
          // Today has no text field; a keyboard over it belongs to a sheet
          // (Add, Type a time) that lifts itself. Resizing would squeeze the
          // day card behind it to nothing (found after Wind Down, M5.0).
          resizeToAvoidBottomInset: false,
          // The day sheet runs to the bottom edge, under the floating tab
          // bar (ADR-0015); its list insets itself by the bar's padding.
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, box) =>
                      spread &&
                          AppLayout.classOf(context, width: box.maxWidth) ==
                              WidthClass.expanded
                      // The Workspace's views (ED-073, ED-333): 3 days on
                      // the hour grid; Day the shown day alone.
                      ? threeDays
                            ? TodayThreeDays(
                                shown: shown,
                                today: today,
                                onSelect: select,
                              )
                            : TodayDayWide(shown: shown, today: today)
                      : _landscape(
                          context,
                          _TodayCompact(
                            shown: shown,
                            today: today,
                            month: month,
                            firstDayOfWeek: profile.settings.firstDayOfWeek,
                            onSelect: select,
                          ),
                        ),
                ),
                if (selecting)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SafeArea(
                      top: false,
                      child: SelectionBar(today: today),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    // Today itself opens the Wake Up card once a day (docs/15 §5).
    return date == null ? WakeUpCardGate(child: screen) : screen;
  }
}

/// A phone in landscape (H1, ED-347): the day in a column as wide as a
/// readable list, centred between the safe areas, never the Workspace.
Widget _landscape(BuildContext context, Widget day) =>
    AppLayout.isShort(context)
    ? Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DotSize.readableColumn),
          child: day,
        ),
      )
    : day;

/// Phones and medium widths: header, week strip (or month), all-day
/// chips and the day pager of full-width sheets (`Main`, ADR-0015).
class _TodayCompact extends ConsumerWidget {
  const _TodayCompact({
    required this.shown,
    required this.today,
    required this.month,
    required this.firstDayOfWeek,
    required this.onSelect,
  });

  final DateTime shown;
  final DateTime today;
  final DateTime month;
  final int firstDayOfWeek;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(todaySelectionProvider);
    final base = _day(today, -pagerReachDays);
    // Low-energy mode (11 D2, M12.2): the header and today's next dot,
    // in place of the strip and the pager.
    if (watchLowEnergy(ref)) {
      return Column(
        children: [
          TodayHeader(
            date: today,
            today: today,
            monthOpen: false,
            month: DateTime(today.year, today.month),
            onToday: () => onSelect(today),
          ),
          Expanded(child: LowEnergyView(today: today)),
        ],
      );
    }
    return Column(
      children: [
        TodayHeader(
          date: shown,
          today: today,
          monthOpen: view.monthOpen,
          month: month,
          onToday: () => onSelect(today),
        ),
        _MonthOrStrip(
          open: view.monthOpen,
          month: TodayMonth(
            month: month,
            shown: shown,
            today: today,
            onSelect: onSelect,
            onMonth: ref.read(todaySelectionProvider.notifier).showMonth,
          ),
          // Phone landscape folds the strip into the title row (ED-347):
          // the title opens the month there.
          strip: AppLayout.isShort(context)
              ? const SizedBox.shrink()
              : TodayWeekStrip(
                  shown: shown,
                  today: today,
                  firstDayOfWeek: firstDayOfWeek,
                  monthOpen: view.monthOpen,
                  onSelect: onSelect,
                ),
        ),
        AllDayChips(date: shown),
        TodayPrompt(
          date: shown,
          today: today,
          hint: RevealHintRow(today: today),
        ),
        const SizedBox(height: DotSpace.xs),
        Expanded(
          // A medium-width window keeps the sheet at a readable width
          // rather than stretching rows across it (ADR-0015).
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: DotSize.readableColumn,
              ),
              child: DayPager(
                itemCount: pagerReachDays * 2 + 1,
                initialIndex: _index(base, shown),
                onChanged: (i) => onSelect(_day(base, i)),
                itemBuilder: (context, i) =>
                    DayPage(date: _day(base, i), today: today, page: true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Calendar day [i] pages after [base]; DateTime arithmetic on local
  /// year/month/day so DST never shifts it.
  static DateTime _day(DateTime base, int i) =>
      DateTime(base.year, base.month, base.day + i);

  /// Whole days from [base] to [d], counted on UTC dates so a 23 h DST day
  /// still counts as one.
  static int _index(DateTime base, DateTime d) => DateTime.utc(
    d.year,
    d.month,
    d.day,
  ).difference(DateTime.utc(base.year, base.month, base.day)).inDays;
}

/// The week strip, or the month pulled open in its place with the handle
/// under it (`A-ios-today-month`). The swap springs open over the motion
/// token's slow duration, and is instant under reduced motion (§2.4).
class _MonthOrStrip extends ConsumerWidget {
  const _MonthOrStrip({
    required this.open,
    required this.month,
    required this.strip,
  });

  final bool open;
  final Widget month;
  final Widget strip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final motion = DotTheme.of(context).motion;
    final child = open
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              month,
              PullHandle(
                open: true,
                onPull: ref.read(todaySelectionProvider.notifier).toggleMonth,
              ),
            ],
          )
        : strip;
    // AnimatedSize with a zero duration re-dirties its own layout and
    // asserts, so reduced motion skips it rather than zeroing it.
    if (motion.isReduced) return child;
    return AnimatedSize(
      duration: motion.slow,
      curve: motion.spring,
      alignment: Alignment.topCenter,
      child: child,
    );
  }
}
