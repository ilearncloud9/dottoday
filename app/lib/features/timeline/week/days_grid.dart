import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/week/week_view.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The hour grid for [days] once they have loaded (M19.2 part 2): Week's
/// seven or 3 days' three. Loading, offline and errors show the screen
/// states under [stateKey] with Try again (docs/09 M3f.9b).
class DaysGrid extends ConsumerWidget {
  const DaysGrid({
    required this.days,
    required this.stateKey,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    required this.onMonth,
    this.cues = true,
    super.key,
  });

  final List<DateTime> days;
  final Key stateKey;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final VoidCallback onMonth;

  /// Week's header and cue chips; 3 days shows the grid alone.
  final bool cues;

  /// Try again: reload what the days need.
  void _retry(WidgetRef ref) {
    ref
      ..invalidate(todayDateProvider)
      ..invalidate(currentProfileProvider);
    for (final d in days) {
      ref.invalidate(timelineDataProvider(d));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = [
      ref.watch(todayDateProvider),
      ref.watch(currentProfileProvider),
      for (final d in days) ref.watch(timelineDataProvider(d)),
    ];
    if (waitFor(stateKey, all, onRetry: () => _retry(ref)) case final w?) {
      return w;
    }
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    return WeekView(
      days: days,
      data: [
        for (final d in days) ref.watch(timelineDataProvider(d)).requireValue,
      ],
      today: ref.watch(todayDateProvider).requireValue,
      nowUtc: now,
      profile: ref.watch(currentProfileProvider).requireValue,
      onPrevious: onPrevious,
      onNext: onNext,
      onToday: onToday,
      onMonth: onMonth,
      cues: cues,
    );
  }
}
