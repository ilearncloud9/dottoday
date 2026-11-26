import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/onboarding/day_fills.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/features/onboarding/steps/fills/fills_geometry.dart';
import 'package:dottoday/features/onboarding/steps/fills/fills_layout.dart';
import 'package:dottoday/features/onboarding/steps/fills/fills_thread.dart';
import 'package:dottoday/features/onboarding/steps/intrinsic_floor.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:dottoday/shared/time_input/time_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// The thread on What fills your days: Wake Up ("Start of your day"),
/// the [picked] ("Most days") in time order, Wind Down ("Time to slow
/// down"), and NOW.
class FillsDayThread extends ConsumerWidget {
  const FillsDayThread({
    required this.day,
    required this.picked,
    required this.color,
    required this.dotKey,
    required this.width,
    required this.land,
    this.flying,
    this.landing,
    super.key,
  });

  final FillsDay day;
  final List<DayFill> picked;
  final Color Function(DayFill) color;
  final GlobalKey Function(String id) dotKey;

  /// The step's width, to measure the rows' words at large text.
  final double width;
  final Animation<double> land;
  final String? flying;
  final String? landing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final use24h = use24hFor(
      context,
      ref.watch(currentProfileProvider).value?.settings.use24h,
    );
    String time(int m) => formatClockTime(
      context,
      ClockTime.fromMinutes(m % (24 * 60)),
      use24h: use24h,
    );
    final picks = [
      for (final f in picked)
        (
          kind: FillRowKind.pick,
          minute: f.minuteOn(day.wake, day.wind),
          title: f.title,
          sub: l10n.onboardingMostDays,
          color: color(f),
          glyph: TaskIcon.fromKey(f.iconKey).glyph,
          id: f.id,
        ),
    ]..sort((a, b) => a.minute.compareTo(b.minute));
    final rows = <FillRow>[
      (
        kind: FillRowKind.wake,
        minute: day.wake,
        title: l10n.settingsWakeUp,
        sub: l10n.onboardingWakeSub,
        color: t.tasks[TaskColor.amber].ring,
        glyph: DotGlyphs.onbSun,
        id: null,
      ),
      ...picks,
      (
        kind: FillRowKind.wind,
        minute: day.wind,
        title: l10n.settingsWindDown,
        sub: l10n.onboardingWindSub,
        color: t.tasks[TaskColor.indigo].ring,
        glyph: DotGlyphs.onbMoon,
        id: null,
      ),
    ];
    final g = FillsGeometry.of(
      context,
      times: [for (final r in rows) time(r.minute)],
    );
    // At large text the thread is as tall as its wrapped rows need and
    // the step scrolls (ED-488); otherwise 300 at least, as before.
    final least = g.large
        ? fillThreadHeight(
            [for (final r in rows) (kind: r.kind, minute: r.minute)],
            scale: g.scale,
            room: [
              for (final r in rows)
                g.room(context, (r.title, r.sub), r.kind, width: width),
            ],
          )
        : OnbSize.threadMinHeight;
    return IntrinsicFloor(
      height: least + OnbSize.threadInsetTop + OnbSize.threadInsetBottom,
      child: Padding(
        padding: const EdgeInsets.only(
          top: OnbSize.threadInsetTop,
          bottom: OnbSize.threadInsetBottom,
        ),
        child: FillsThread(
          wake: day.wake,
          wind: day.wind,
          now: day.now,
          nowLabel: l10n.onboardingHelloNow,
          time: time,
          dotKeys: {for (final p in picks) p.id: dotKey(p.id)},
          land: land,
          flying: flying,
          landing: landing,
          rows: rows,
        ),
      ),
    );
  }
}

/// The user's day: Wake Up, Wind Down and now, in minutes from the day's
/// midnight (now after midnight counts on, up to Wind Down).
final class FillsDay {
  const FillsDay(this.wake, this.wind, this.now);

  factory FillsDay.of(Profile profile, DateTime nowUtc) {
    final common = commonWindow(profile.settings);
    final wake = windowMinutes(common.start);
    final wind = windowMinutes(common.end);
    final local = tz.TZDateTime.from(nowUtc, tz.getLocation(profile.tzId));
    var now = local.hour * 60 + local.minute;
    if (now < wake && now + 24 * 60 <= wind) now += 24 * 60;
    return FillsDay(wake, wind, now);
  }

  final int wake;
  final int wind;
  final int now;
}
