import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/now/now_view.dart';
import 'package:dottoday/features/timeline/day_menu/day_menu_run.dart';
import 'package:dottoday/features/timeline/now/now_body.dart';
import 'package:dottoday/features/timeline/now/now_date_anchor.dart';
import 'package:dottoday/features/timeline/now/now_inputs.dart';
import 'package:dottoday/features/timeline/now/now_wake_up.dart';
import 'package:dottoday/features/timeline/now/wide/now_stacked.dart';
import 'package:dottoday/features/timeline/now/wide/now_wide.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_state.dart';
import 'package:dottoday/features/timeline/widgets/day_menu_chip.dart';
import 'package:dottoday/features/timeline/widgets/today_menu.dart';
import 'package:dottoday/features/timeline/widgets/today_top_actions.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Minimal's Now on phones (E-PhonesMinimal frames 1, 4, 5; ED-066,
/// ED-106, ED-329; M19.6 part 6b): the date and "Now 10:42 · Wind Down
/// at 11:00 PM", the horizon (a tap opens Today), then what's on now
/// ([NowBody]), and the Day ▾ chip. Expanded, the Mac and web pane
/// ([NowWide]); medium, the Day under Now ([NowStacked]).
class NowScreen extends ConsumerWidget {
  const NowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const key = ValueKey('route:now');
    if (waitFor(key, NowInputs.states(ref), onRetry: () => NowInputs.retry(ref))
        case final w?) {
      return w;
    }
    // The Mac menu bar's Day menu and ⌘K act on today here (ED-093).
    final day = ref.watch(todayDateProvider).value;
    Widget scoped(Widget child) => day == null
        ? child
        : DayActionScope(date: day, today: day, child: child);
    switch (AppLayout.classOf(context)) {
      // The Mac and web pane beside the Day column (E-Minimal, 6c).
      case WidthClass.expanded:
        return scoped(const NowWide());
      // Medium (tablets, a narrow browser): the Day under Now (6e-2).
      case WidthClass.medium:
        return scoped(const NowStacked());
      case WidthClass.compact:
        break;
    }
    final n = NowInputs.watch(context, ref);
    if (n == null) return const Scaffold();
    final (today, now, shape, view, time) = (
      n.today,
      n.nowUtc,
      n.shape,
      n.view,
      n.time,
    );
    final wakeUp = ref.watch(wakeUpCardInNowProvider).value;
    return scoped(
      Scaffold(
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(
                  DotSpace.page,
                  DotSpace.s,
                  DotSpace.page,
                  DotSize.androidBar * 2,
                ),
                children: [
                  _Header(
                    today: today,
                    now: time(now),
                    windDown: time(shape.bedUtc),
                  ),
                  const SizedBox(height: DotSpace.m),
                  // A tap opens Today (E-PhonesMinimal frame 1); a screen
                  // reader swipes along the dots and opens one (ED-248 A).
                  n.horizon(
                    context,
                    onTap: () => context.go(AppRoutes.today),
                    hint: context.l10n.horizonOpensToday,
                    onOpen: (o) => openTask(context, o.id),
                  ),
                  const SizedBox(height: DotSpace.xl),
                  // The morning's Wake Up card until it's answered, unless a
                  // task is already under way (E-R2-26 frame 4).
                  if (wakeUp != null && view is! NowRunning)
                    NowWakeUp(model: wakeUp)
                  else
                    NowBody(
                      view: view,
                      nowUtc: now,
                      windDownUtc: shape.bedUtc,
                      time: time,
                    ),
                ],
              ),
              // Day ▾ above the tab bar's end (ED-124): Minimal's Day menu,
              // the system's own pull-down (native first).
              PositionedDirectional(
                end: DotSpace.page,
                // Above the floating bar, which sits over the system's inset.
                bottom:
                    DotSize.androidBar +
                    DotSpace.l +
                    MediaQuery.viewPaddingOf(context).bottom,
                child: TodayMenu(
                  date: today,
                  today: today,
                  button: const DayMenuChip(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Tue 3 Nov ▾" (Go to date, to that day on Today) and the sync and
/// profile capsule; "Now 10:42 · Wind Down at 11:00 PM" under them.
class _Header extends StatelessWidget {
  const _Header({
    required this.today,
    required this.now,
    required this.windDown,
  });

  final DateTime today;
  final String now;
  final String windDown;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final android = DotIdiom.of(context) == DotIdiom.material;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: NowDateAnchor(
                  today: today,
                  child: TextButton.icon(
                    onPressed: () => NowDateAnchor.open(context, today),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: t.colors.ink,
                    ),
                    iconAlignment: IconAlignment.end,
                    icon: DotIcon(
                      DotGlyphs.chevronDown,
                      color: android ? t.colors.ink : t.colors.accentText,
                      size: DotSize.rowIcon,
                    ),
                    label: Text(
                      DateFormat.MMMEd(locale).format(today),
                      style: android ? t.styles.topBarTitle : t.styles.dayTitle,
                    ),
                  ),
                ),
              ),
            ),
            const TodayTopActions(sync: true),
          ],
        ),
        Text(
          l10n.nowSummary(now, windDown),
          style: t.styles.rowMeta.copyWith(color: t.colors.secondary),
        ),
      ],
    );
  }
}

/// The "Day ▾" chip (E-PhonesMinimal): a raised capsule.
