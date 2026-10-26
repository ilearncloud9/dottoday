import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/low_energy.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_actions.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_parts.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/state/today_prompts.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Today in low-energy mode (11 D2, docs/09 M12.2, `B-ios-low-energy`):
/// the next dot with Done / Not today, the "Later" pile, "Move everything
/// optional to tomorrow?" once a day, and "Nudges are off until tomorrow's
/// Wake Up". No counts. In place of the day pager on phones and of the
/// today card in the Mac/web spread.
class LowEnergyView extends ConsumerWidget {
  const LowEnergyView({required this.today, super.key});

  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(timelineDataProvider(today)).value;
    if (data == null) return const SizedBox.shrink();
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    final day = LowEnergyDay.of(data.blocks, now);
    final movable = day.movableAt(now);
    final offered = ref.watch(dismissedPromptsProvider).contains((
      TodayPromptKind.lowEnergy,
      today,
    ));
    final use24h = use24hFor(context, data.settings.use24h);
    String at(DateTime utc) =>
        timeOfUtc(context, data.day.location, utc, use24h: use24h);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        DotSpace.page,
        DotSpace.s,
        DotSpace.page,
        DotSpace.fabClearance,
      ),
      children: [
        if (day.next case final next?)
          _next(context, ref, next, now, at)
        else
          LowEnergyCard(
            child: Text(
              context.l10n.lowEnergyNothing,
              textAlign: TextAlign.center,
              style: DotTheme.of(context).styles.body,
            ),
          ),
        if (day.later.isNotEmpty) ...[
          const SizedBox(height: DotSpace.m),
          LaterPile(tasks: day.later, time: (o) => at(o.startUtc!)),
        ],
        if (movable.isNotEmpty && !offered) ...[
          const SizedBox(height: DotSpace.m),
          ProposeTomorrowCard(onPropose: () => _propose(context, ref, movable)),
        ],
        const SizedBox(height: DotSpace.l),
        const NudgesOffLine(),
      ],
    );
  }

  Widget _next(
    BuildContext context,
    WidgetRef ref,
    Occurrence next,
    DateTime now,
    String Function(DateTime) at,
  ) {
    final l10n = context.l10n;
    final live = !next.startUtc!.isAfter(now);
    final total = next.durationMin * Duration.secondsPerMinute;
    final gone = now.difference(next.startUtc!).inSeconds;
    return NextDotCard(
      task: next,
      progress: live && total > 0 ? gone / total : 0,
      when: live
          ? l10n.lowEnergyUntil(
              at(next.endUtc!),
              formatDurationShort(l10n, next.endUtc!.difference(now).inMinutes),
            )
          : l10n.lowEnergyAt(at(next.startUtc!)),
      onDone: () => unawaited(_done(context, ref, next)),
      onNotToday: () => unawaited(
        notToday(
          ProviderScope.containerOf(context, listen: false),
          ScaffoldMessenger.of(context),
          l10n,
          next,
          today,
        ),
      ),
    );
  }

  Future<void> _done(BuildContext context, WidgetRef ref, Occurrence o) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final undo = ref.read(undoServiceProvider);
    reportUndoable(
      messenger,
      l10n,
      undo,
      await toggleDone(ref, o),
      message: (_) => l10n.snackDone(o.title),
      tokenOf: (t) => t,
    );
  }

  /// Offered once a day: Propose puts the card away whatever comes next.
  void _propose(BuildContext context, WidgetRef ref, List<Occurrence> tasks) {
    ref
        .read(dismissedPromptsProvider.notifier)
        .dismiss(TodayPromptKind.lowEnergy, today);
    unawaited(
      proposeTomorrow(
        ProviderScope.containerOf(context, listen: false),
        context.l10n,
        today: today,
        tasks: tasks,
      ),
    );
  }
}
