import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/router/show_place.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/state/today_selection.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_gate.dart';
import 'package:dottoday/features/timeline/widgets/selection_layer.dart';
import 'package:dottoday/features/timeline/widgets/today_compact.dart';
import 'package:dottoday/features/timeline/widgets/today_day_wide.dart';
import 'package:dottoday/features/timeline/widgets/today_keys.dart';
import 'package:dottoday/features/timeline/widgets/today_prompt.dart';
import 'package:dottoday/features/timeline/widgets/today_three_days.dart';
import 'package:dottoday/features/timeline/workspace/workspace_scope.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Today (docs/10 §5.2 T1, `Main`): greeting header with the day dot, the
/// week strip and its month pull-open, all-day chips, and the day pager;
/// at the expanded width the three-day spread (T5, M3e.1), except in the
/// minimal layout (docs/14 §3).
/// [date] opens another day (`/day/:date`); otherwise it follows today.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({this.date, this.threeDays = false, super.key});

  final DateTime? date;

  /// The Workspace's 3 days view (`/3-days/<date>`, ED-333); off, Day.
  /// Only the expanded width tells them apart; phones show their Today.
  final bool threeDays;

  /// What Today needs before it can draw (docs/09 M3f.9b).
  static List<AsyncValue<Object?>> _inputs(WidgetRef ref) => [
    ref.watch(todayDateProvider),
    ref.watch(currentProfileProvider),
  ];

  static void _retry(WidgetRef ref) => ref
    ..invalidate(todayDateProvider)
    ..invalidate(currentProfileProvider);

  /// [date] when the pager reaches it (±[pagerReachDays] from [today]);
  /// a link further out opens today rather than a page the pager lacks.
  static DateTime? _reachable(DateTime? date, DateTime today) {
    if (date == null) return null;
    final days = DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime.utc(today.year, today.month, today.day)).inDays;
    return days.abs() <= pagerReachDays ? date : null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(todaySelectionProvider);
    final key = ValueKey(
      date == null
          ? 'route:today'
          : 'route:${threeDays ? '3-days' : 'day'}:${formatRouteDate(date!)}',
    );
    if (waitFor(key, _inputs(ref), onRetry: () => _retry(ref)) case final w?) {
      return w;
    }
    final today = ref.watch(todayDateProvider).requireValue;
    final profile = ref.watch(currentProfileProvider).requireValue;
    final shown = _reachable(date, today) ?? today;
    final month = view.month ?? DateTime(shown.year, shown.month);
    // The address is the shown day (ED-097): today follows midnight.
    void select(DateTime d) {
      ref.read(todaySelectionProvider.notifier).followDay();
      // 3 days keeps its view as it steps (ED-333).
      showPlace(
        GoRouter.of(context),
        threeDays
            ? AppRoutes.threeDays(d)
            : d == today
            ? AppRoutes.today
            : AppRoutes.day(d),
      );
    }

    // Minimal (docs/14 §3): Today alone at every width, no spread.
    final spread = !watchSimplified(ref, FeatureId.spread);
    final screen = TodayKeys(
      shown: shown,
      today: today,
      onSelect: select,
      child: Scaffold(
        key: key,
        // Today has no text field; a keyboard over it belongs to a sheet
        // (Add, Type a time) that lifts itself. Resizing would squeeze the
        // day card behind it to nothing (found after Wind Down, M5.0).
        resizeToAvoidBottomInset: false,
        // The day sheet runs to the bottom edge, under the floating tab
        // bar (ADR-0015); its list insets itself by the bar's padding.
        body: SafeArea(
          bottom: false,
          child: SelectionLayer(
            today: today,
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, box) =>
                      spread &&
                          // Inside the Workspace its views stay the grid
                          // beside the Plan panel and the inspector.
                          (WorkspaceScope.of(context) ||
                              AppLayout.classOf(context, width: box.maxWidth) ==
                                  WidthClass.expanded)
                      // The Workspace's views (ED-073, ED-333): 3 days on
                      // the hour grid; Day the shown day alone.
                      ? threeDays
                            ? TodayThreeDays(
                                shown: shown,
                                today: today,
                                onSelect: select,
                              )
                            : TodayDayWide(shown: shown, today: today)
                      : _landscape(
                          context,
                          TodayCompact(
                            shown: shown,
                            today: today,
                            month: month,
                            firstDayOfWeek: profile.settings.firstDayOfWeek,
                            onSelect: select,
                          ),
                        ),
                ),
                // "Need more time?" and "Calendar changed" float at the
                // foot, above the tab bar (E-R2-26 §1, ED-329).
                if (shown == today)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SafeArea(
                      top: false,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: DotSize.readableColumn,
                        ),
                        child: TodayFloatPrompt(today: today),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    // Today itself opens the Wake Up card once a day (docs/15 §5).
    return date == null ? WakeUpCardGate(child: screen) : screen;
  }
}

/// A phone in landscape (H1, ED-347): the day in a column as wide as a
/// readable list, centred between the safe areas, never the Workspace.
Widget _landscape(BuildContext context, Widget day) =>
    AppLayout.isShort(context)
    ? Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DotSize.readableColumn),
          child: day,
        ),
      )
    : day;
