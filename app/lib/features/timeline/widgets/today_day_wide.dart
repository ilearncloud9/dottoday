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
/// shown day alone, its thread on the hour scale under the day's header
/// (E-FullA-v2 web Day, M19.2 part 2); 3 days is `TodayThreeDays`.
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
          child: low
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: DotSize.readableColumn,
                    ),
                    child: LowEnergyView(today: today),
                  ),
                )
              : ColoredBox(
                  color: DotTheme.of(context).colors.canvas,
                  child: DayPage(
                    key: ValueKey(shown),
                    date: shown,
                    today: today,
                    page: true,
                    hours: true,
                  ),
                ),
        ),
      ],
    );
  }
}
