import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_state.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_view.dart';
import 'package:dottoday/features/timeline/week/days_grid.dart';
import 'package:dottoday/features/timeline/widgets/all_day_chips.dart';
import 'package:dottoday/features/timeline/widgets/spread_header.dart';
import 'package:dottoday/features/timeline/widgets/today_prompt.dart';
import 'package:dottoday/features/timeline/workspace/workspace_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 3 days at the expanded width (E-R2-30, ED-333; M19.2 part 2): the day
/// before, [shown] and the day after on the hour grid, as Week draws them.
/// ‹ › (and ⌘← ⌘→) step a day; tasks drag between the days. In low-energy
/// mode (M12.2) today shows its next dot alone.
class TodayThreeDays extends ConsumerWidget {
  const TodayThreeDays({
    required this.shown,
    required this.today,
    required this.onSelect,
    super.key,
  });

  final DateTime shown;
  final DateTime today;
  final ValueChanged<DateTime> onSelect;

  DateTime _plus(int days) =>
      DateTime(shown.year, shown.month, shown.day + days);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final low = shown == today && watchLowEnergy(ref);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The Workspace's toolbar carries the date and the Day menu.
        if (!WorkspaceScope.of(context))
          SpreadHeader(
            date: shown,
            today: today,
            onToday: () => onSelect(today),
          ),
        AllDayChips(date: shown),
        TodayPrompt(date: shown, today: today),
        Expanded(
          child: low
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: DotSize.readableColumn,
                    ),
                    child: LowEnergyView(today: today),
                  ),
                )
              : DaysGrid(
                  days: [_plus(-1), shown, _plus(1)],
                  stateKey: ValueKey(shown),
                  cues: false,
                  onPrevious: () => onSelect(_plus(-1)),
                  onNext: () => onSelect(_plus(1)),
                  onToday: () => onSelect(today),
                  onMonth: () => context.go(AppRoutes.month),
                ),
        ),
      ],
    );
  }
}
