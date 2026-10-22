import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/state/week_selection.dart';
import 'package:dottoday/features/timeline/week/week_view.dart';
import 'package:dottoday/features/timeline/widgets/today_week_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Week (docs/10 §5.2 W1, `A-mac-week-alt3-board`, M3e.3): the capacity
/// board of the week around the picked day, Mac/web only (phones use the
/// strip and the month). ⌘← / ⌘→ step a week, ⌘T comes back.
class WeekScreen extends ConsumerWidget {
  const WeekScreen({super.key});

  static const _key = ValueKey('route:week');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayDateProvider).value;
    final profile = ref.watch(currentProfileProvider).value;
    if (today == null || profile == null) return const Scaffold(key: _key);
    final shown = ref.watch(weekSelectionProvider) ?? today;
    final first = weekStart(shown, profile.settings.firstDayOfWeek);
    final days = [
      for (var i = 0; i < DateTime.daysPerWeek; i++)
        DateTime(first.year, first.month, first.day + i),
    ];
    final data = [
      for (final d in days) ref.watch(timelineDataProvider(d)).value,
    ];
    if (data.any((d) => d == null)) return const Scaffold(key: _key);
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
          data: [for (final d in data) d!],
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
