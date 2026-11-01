import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/editing/focus_task.dart';
import 'package:dottoday/data/live_activity/live_activity_dismissed.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/reveal/hint_scheduler.dart';
import 'package:dottoday/domain/reveal/hint_signals.dart';
import 'package:dottoday/domain/scheduling/low_energy.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Today's [HintSignals] (docs/14 §5), read from rows Today already loads:
/// today, the three mornings before it (whole days, so today's plan never
/// counts as a habit) and the week behind it. Null while
/// any of it is loading, so a half-known day never picks a hint.
HintSignals? watchHintSignals(WidgetRef ref, DateTime today) {
  final profile = ref.watch(currentProfileProvider).value;
  final data = ref.watch(timelineDataProvider(today)).value;
  final steps = ref.watch(daySubtaskProgressProvider(today)).value;
  if (profile == null || data == null || steps == null) return null;
  final now =
      ref.watch(minuteTickProvider).value ?? ref.watch(clockProvider).nowUtc();
  List<Occurrence>? day(int back) => ref
      .watch(
        timelineDataProvider(
          DateTime(today.year, today.month, today.day - back),
        ),
      )
      .value
      ?.blocks;
  final mornings = [for (var d = routineMornings; d >= 1; d--) day(d)];
  final week = [for (var d = 7; d >= 1; d--) day(d)];
  if (mornings.contains(null) || week.contains(null)) return null;
  final counts = {for (final e in steps.entries) e.key: e.value.total};
  final shape = DayShape.on(
    data.day.location,
    today,
    data.settings.boundaryFor(data.day.weekday),
  );
  return HintSignals(
    daysOfUse: now.difference(profile.createdAt).inDays,
    movedTaskId: movedTaskOf(data.blocks, counts),
    sameMornings: sameMornings([...mornings.nonNulls]),
    longTaskId: longTaskOf(data.blocks, counts),
    // iOS reports a Live Activity the user swiped away (M16).
    liveActivityDismissed:
        ref.watch(liveActivityDismissedProvider).value ?? false,
    overrunsThisWeek: overrunsOf([...week.nonNulls.expand((d) => d)]),
    inFocus: ref.watch(focusTaskProvider) != null,
    inWindDownReview: !now.isBefore(shape.bedUtc),
    lowEnergy: lowEnergyOn(data.settings, now),
  );
}
