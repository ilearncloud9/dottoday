import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_state.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_view.dart';
import 'package:dottoday/features/timeline/state/today_selection.dart';
import 'package:dottoday/features/timeline/widgets/all_day_chips.dart';
import 'package:dottoday/features/timeline/widgets/day_menu_chip.dart';
import 'package:dottoday/features/timeline/widgets/day_page.dart';
import 'package:dottoday/features/timeline/widgets/reveal_hint_row.dart';
import 'package:dottoday/features/timeline/widgets/today_header.dart';
import 'package:dottoday/features/timeline/widgets/today_menu.dart';
import 'package:dottoday/features/timeline/widgets/today_month.dart';
import 'package:dottoday/features/timeline/widgets/today_prompt.dart';
import 'package:dottoday/features/timeline/widgets/today_week_strip.dart';
import 'package:dottoday/shared/dot/day_pager.dart';
import 'package:dottoday/shared/dot/week_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How far the pager reaches each side of today (docs/10 §3 `DayPager`).
const pagerReachDays = 365;

/// Phones and medium widths: header, week strip (or month), all-day
/// chips and the day pager of full-width sheets (`Main`, ADR-0015).
class TodayCompact extends ConsumerWidget {
  const TodayCompact({
    super.key,
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
    // Full on a phone in portrait: Day ▾ floats over the day (E-Phones,
    // ED-093); landscape, tablets and Minimal keep the header's ⋯.
    final chip =
        watchOnScreen(ref, FeatureId.dayMenuExtras) &&
        AppLayout.classOf(context) == WidthClass.compact &&
        !AppLayout.isShort(context);
    final day = _column(context, ref, menu: !chip);
    if (!chip) return day;
    final ios = DotIdiom.of(context) == DotIdiom.cupertino;
    return Stack(
      children: [
        day,
        PositionedDirectional(
          start: ios ? null : DotSpace.page,
          end: ios ? DotSpace.page : null,
          // Above the floating bar, which sits over the system's inset.
          bottom:
              DotSize.androidBar +
              DotSpace.l +
              MediaQuery.viewPaddingOf(context).bottom,
          child: TodayMenu(
            date: shown,
            today: today,
            button: const DayMenuChip(),
          ),
        ),
      ],
    );
  }

  Widget _column(BuildContext context, WidgetRef ref, {required bool menu}) {
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
            menu: menu,
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
          menu: menu,
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
