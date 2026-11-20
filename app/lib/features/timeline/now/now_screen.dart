import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/now/now_view.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/now/now_body.dart';
import 'package:dottoday/features/timeline/now/now_wake_up.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_state.dart';
import 'package:dottoday/features/timeline/widgets/go_to_date.dart';
import 'package:dottoday/features/timeline/widgets/today_menu.dart';
import 'package:dottoday/features/timeline/widgets/today_top_actions.dart';
import 'package:dottoday/shared/dot/day_horizon.dart';
import 'package:dottoday/shared/dot/thread_day.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Minimal's Now on phones (E-PhonesMinimal frames 1, 4, 5; ED-066,
/// ED-106, ED-329; M19.6 part 6b): the date and "Now 10:42 · Wind Down
/// at 11:00 PM", the horizon (a tap opens Today), then what's on now
/// ([NowBody]), and the Day ▾ chip. From the medium width the Now pane
/// beside the Day column is 6c's; until then the day shows there.
class NowScreen extends ConsumerWidget {
  const NowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (AppLayout.classOf(context) != WidthClass.compact) {
      return const TodayScreen();
    }
    final today = ref.watch(todayDateProvider).value;
    final data = today == null
        ? null
        : ref.watch(timelineDataProvider(today)).value;
    if (today == null || data == null) return const Scaffold();
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    final shape = DayShape.on(
      data.day.location,
      data.day.date,
      data.settings.boundaryFor(data.day.weekday),
    );
    final use24h = use24hFor(
      context,
      ref.watch(currentProfileProvider).value?.settings.use24h,
    );
    String time(DateTime utc) =>
        timeOfUtc(context, data.day.location, utc, use24h: use24h);
    final view = nowViewOf(
      blocks: data.blocks,
      nowUtc: now,
      windDownUtc: shape.bedUtc,
    );
    final wakeUp = ref.watch(wakeUpCardInNowProvider).value;
    return Scaffold(
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
                _horizon(
                  context,
                  data.blocks,
                  shape,
                  now,
                  data.day.location,
                  time,
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
              bottom: DotSize.androidBar + DotSpace.l,
              child: TodayMenu(date: today, today: today, button: _DayChip()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _horizon(
    BuildContext context,
    List<Occurrence> blocks,
    DayShape shape,
    DateTime now,
    tz.Location zone,
    String Function(DateTime) time,
  ) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final wake = tz.TZDateTime.from(shape.wakeUtc, zone);
    final bed = tz.TZDateTime.from(shape.bedUtc, zone);
    // The whole hour halfway through the waking day ("3 PM").
    final mid = wake.add(bed.difference(wake) ~/ 2);
    final midHour = tz.TZDateTime(zone, mid.year, mid.month, mid.day, mid.hour);
    String hour(tz.TZDateTime t) => DateFormat.j(locale).format(t);
    return DayHorizon(
      dots: [
        for (final o in blocks)
          if (o.startUtc != null)
            HorizonDot(
              startUtc: o.startUtc!,
              endUtc: o.endUtc!,
              color: TaskColor.fromKey(o.colorKey),
              state: dotStateOf(o, now),
            ),
      ],
      wakeUtc: shape.wakeUtc,
      windDownUtc: shape.bedUtc,
      nowUtc: now,
      labels: (
        wake: hour(wake),
        now: time(now),
        mid: hour(midHour),
        midUtc: midHour.toUtc(),
        windDown: hour(bed),
      ),
      label: l10n.horizonLabel(
        time(shape.wakeUtc),
        time(shape.bedUtc),
        time(now),
      ),
      hint: l10n.horizonOpensToday,
      // A tap opens Today (E-PhonesMinimal frame 1).
      onTap: () => context.go(AppRoutes.today),
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
                child: TextButton.icon(
                  onPressed: () => unawaited(
                    showGoToDate(
                      context,
                      shown: today,
                      today: today,
                      onSelect: (d) => context.go(AppRoutes.day(d)),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: t.colors.text,
                  ),
                  iconAlignment: IconAlignment.end,
                  icon: DotIcon(
                    DotGlyphs.chevronDown,
                    color: android ? t.colors.text : t.colors.accentInk,
                    size: DotSize.rowIcon,
                  ),
                  label: Text(
                    DateFormat.MMMEd(locale).format(today),
                    style: android ? t.styles.topBarTitle : t.styles.dayTitle,
                  ),
                ),
              ),
            ),
            const TodayTopActions(sync: true),
          ],
        ),
        Text(
          l10n.nowSummary(now, windDown),
          style: t.styles.rowMeta.copyWith(color: t.colors.muted),
        ),
      ],
    );
  }
}

/// The "Day ▾" chip (E-PhonesMinimal): a raised capsule.
class _DayChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: DotTouch.android),
      padding: const EdgeInsets.symmetric(horizontal: DotSpace.l),
      decoration: BoxDecoration(
        color: t.colors.raised,
        borderRadius: BorderRadius.circular(DotRadii.pill),
        boxShadow: DotElevation.capsule(t.colors),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: DotSpace.xs,
        children: [
          Text(context.l10n.workspaceDay, style: t.styles.button),
          DotIcon(
            DotGlyphs.chevronDown,
            color: t.colors.text,
            size: DotSize.rowIcon,
          ),
        ],
      ),
    );
  }
}
