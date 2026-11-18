import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_state.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_view.dart';
import 'package:dottoday/features/timeline/widgets/all_day_chips.dart';
import 'package:dottoday/features/timeline/widgets/day_page.dart';
import 'package:dottoday/features/timeline/widgets/spread_header.dart';
import 'package:dottoday/features/timeline/widgets/today_prompt.dart';
import 'package:dottoday/features/timeline/workspace/workspace_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Workspace's Day view at the expanded width (ED-073, ED-333): the
/// shown day alone, its card centred at a readable width. Part 2 of
/// M19.2 draws it on the hour grid; 3 days is [TodaySpread].
class TodayDayWide extends ConsumerWidget {
  const TodayDayWide({required this.shown, required this.today, super.key});

  final DateTime shown;
  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final low = shown == today && watchLowEnergy(ref);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!WorkspaceScope.of(context))
          SpreadHeader(date: shown, today: today, onToday: () {}),
        AllDayChips(date: shown),
        TodayPrompt(date: shown, today: today),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: DotSize.readableColumn,
              ),
              child: low
                  ? LowEnergyView(today: today)
                  : DayPage(key: ValueKey(shown), date: shown, today: today),
            ),
          ),
        ),
      ],
    );
  }
}
