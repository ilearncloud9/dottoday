import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/state/week_selection.dart';
import 'package:dottoday/features/timeline/week/week_view.dart';
import 'package:dottoday/features/timeline/widgets/today_week_strip.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Week (docs/10 §5.2 W1, `A-mac-week-alt3-board`, M3e.3): the capacity
/// board of the week around the picked day, Mac/web only (phones use the
/// strip and the month). ⌘← / ⌘→ step a week, ⌘T comes back.
class WeekScreen extends ConsumerWidget {
  const WeekScreen({super.key});

  static const _key = ValueKey('route:week');

  /// Try again (docs/09 M3f.9b): reload what the week needs.
  static void _retry(WidgetRef ref, {List<DateTime> days = const []}) {
    ref
      ..invalidate(todayDateProvider)
      ..invalidate(currentProfileProvider);
    for (final d in days) {
      ref.invalidate(timelineDataProvider(d));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final base = [
      ref.watch(todayDateProvider),
      ref.watch(currentProfileProvider),
    ];
    if (waitFor(_key, base, onRetry: () => _retry(ref)) case final w?) return w;
    final today = ref.watch(todayDateProvider).requireValue;
    final profile = ref.watch(currentProfileProvider).requireValue;
    final shown = ref.watch(weekSelectionProvider) ?? today;
    final first = weekStart(shown, profile.settings.firstDayOfWeek);
    final days = [
      for (var i = 0; i < DateTime.daysPerWeek; i++)
        DateTime(first.year, first.month, first.day + i),
    ];
    final dayAsync = [for (final d in days) ref.watch(timelineDataProvider(d))];
    void retryDays() => _retry(ref, days: days);
    if (waitFor(_key, dayAsync, onRetry: retryDays) case final w?) return w;
    final data = [for (final a in dayAsync) a.requireValue];
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    void show(int weeks) => ref
        .read(weekSelectionProvider.notifier)
        .show(DateTime(first.year, first.month, first.day + 7 * weeks));
    final selection = ref.read(weekSelectionProvider.notifier);
    return Scaffold(
      key: _key,
      body: SafeArea(
        child: WeekView(
          days: days,
          data: data,
          today: today,
          nowUtc: now,
          profile: profile,
          onPrevious: () => show(-1),
          onNext: () => show(1),
          onToday: () => selection.show(null),
          onMonth: () => context.go(AppRoutes.month),
        ),
      ),
    );
  }
}
