import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/router/show_place.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/week/days_grid.dart';
import 'package:dottoday/features/timeline/widgets/selection_layer.dart';
import 'package:dottoday/features/timeline/widgets/today_week_strip.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Week (docs/10 §5.2 W1, `A-mac-week-alt3-board`, M3e.3): the capacity
/// board of the week around the picked day, Mac/web only (phones use the
/// strip and the month). ⌘← / ⌘→ step a week, ⌘T comes back.
class WeekScreen extends ConsumerWidget {
  const WeekScreen({this.date, super.key});

  /// The week around [date] (`/week/<date>`); null = this week (`/week`).
  /// The address is the shown week (ED-097).
  final DateTime? date;

  static const _key = ValueKey('route:week');

  /// Try again (docs/09 M3f.9b): reload what the week needs.
  static void _retry(WidgetRef ref) => ref
    ..invalidate(todayDateProvider)
    ..invalidate(currentProfileProvider);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final base = [
      ref.watch(todayDateProvider),
      ref.watch(currentProfileProvider),
    ];
    if (waitFor(_key, base, onRetry: () => _retry(ref)) case final w?) return w;
    final today = ref.watch(todayDateProvider).requireValue;
    final profile = ref.watch(currentProfileProvider).requireValue;
    final shown = date ?? today;
    final first = weekStart(shown, profile.settings.firstDayOfWeek);
    final days = [
      for (var i = 0; i < DateTime.daysPerWeek; i++)
        DateTime(first.year, first.month, first.day + i),
    ];
    final thisWeek = weekStart(today, profile.settings.firstDayOfWeek);
    void showWeek(DateTime start) => showPlace(
      GoRouter.of(context),
      start == thisWeek ? AppRoutes.week : AppRoutes.weekOf(start),
    );
    void show(int weeks) =>
        showWeek(DateTime(first.year, first.month, first.day + 7 * weeks));
    return Scaffold(
      key: _key,
      body: SafeArea(
        // Picks may span the week's days (E-R2-6).
        child: SelectionLayer(
          today: today,
          child: DaysGrid(
            days: days,
            stateKey: _key,
            onPrevious: () => show(-1),
            onNext: () => show(1),
            onToday: () => showWeek(thisWeek),
            onMonth: () => context.go(AppRoutes.month),
          ),
        ),
      ),
    );
  }
}
