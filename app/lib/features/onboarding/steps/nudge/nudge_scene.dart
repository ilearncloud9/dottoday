import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/onboarding/day_fills.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/features/onboarding/flow/onb_nav.dart';
import 'package:dottoday/features/onboarding/steps/fills/fills_day_thread.dart';
import 'package:dottoday/features/onboarding/steps/fills/fills_draft.dart';
import 'package:dottoday/features/onboarding/steps/fills/fills_layout.dart';
import 'package:dottoday/features/onboarding/steps/fills/fills_look.dart';
import 'package:dottoday/features/onboarding/steps/fills/fills_thread.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:dottoday/shared/time_input/time_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the nudge shows (`vNudge`, `setSubject`): your thread with the
/// subject as a task (`9:30 PM · 30 min`), and the words for its preview
/// and ask; with nothing picked, Wind Down is the subject and has no task.
final class NudgeScene {
  NudgeScene._(this._context, this.day, this.picked, this.subject, this._time);

  factory NudgeScene.of(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
    DateTime nowUtc,
  ) {
    final day = FillsDay.of(profile, nowUtc);
    final picked = draftPicked(context.l10n, ref.watch(fillsDraftProvider));
    final use24h = use24hFor(context, profile.settings.use24h);
    String time(int m) => formatClockTime(
      context,
      ClockTime.fromMinutes(m % (24 * 60)),
      use24h: use24h,
    );
    return NudgeScene._(
      context,
      day,
      picked,
      nudgeSubject(picked, day.wake, day.wind, day.now),
      time,
    );
  }

  final BuildContext _context;
  final FillsDay day;
  final List<DayFill> picked;
  final DayFill? subject;
  final String Function(int minute) _time;

  AppLocalizations get _l10n => _context.l10n;

  bool get android => onbAndroid(_context);

  int get _at => subject?.minuteOn(day.wake, day.wind) ?? day.wind;

  /// Its title: the subject's, or Wind Down.
  String get subjectTitle => subject?.title ?? _l10n.settingsWindDown;

  /// "Read in 10 minutes".
  String get bannerTitle => _l10n.onboardingNudgeIn(subjectTitle);

  /// "9:30 PM – 10:00 PM", or Wind Down's time alone.
  String get span {
    final s = subject;
    if (s == null) return _time(day.wind);
    return _l10n.onboardingNudgeSpan(_time(_at), _time(_at + s.durationMin));
  }

  /// When the reminder would arrive: 10 minutes before.
  String get when => _time(_at - 10);
  String get wakeTime => _time(day.wake);
  String get windTime => _time(day.wind);

  /// The thread; the subject's row drops on [drop].
  Widget thread(Animation<double> drop) {
    final t = DotTheme.of(_context);
    final l10n = _l10n;
    final s = subject;
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
      for (final f
          in [...picked]..sort(
            (a, b) => a
                .minuteOn(day.wake, day.wind)
                .compareTo(b.minuteOn(day.wake, day.wind)),
          ))
        (
          kind: f == s ? FillRowKind.task : FillRowKind.pick,
          minute: f.minuteOn(day.wake, day.wind),
          title: f.title,
          sub: f == s
              ? l10n.onboardingTaskMeta(
                  _time(_at),
                  formatDurationShort(l10n, f.durationMin),
                )
              : l10n.onboardingMostDays,
          color: t.tasks[TaskColor.fromKey(f.colorKey)].ring,
          glyph: TaskIcon.fromKey(f.iconKey).glyph,
          id: f.id,
        ),
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
    return FillsThread(
      rows: rows,
      wake: day.wake,
      wind: day.wind,
      now: day.now,
      nowLabel: l10n.onboardingHelloNow,
      time: _time,
      dotKeys: const {},
      land: kAlwaysCompleteAnimation,
      // Reduce Motion: it fades in with the rest, 200 ms.
      drop: t.motion.isReduced
          ? drop
          : CurvedAnimation(
              parent: drop,
              curve: Interval(
                0,
                OnbMotion.drop.inMilliseconds / OnbMotion.nudge.inMilliseconds,
              ),
            ),
    );
  }
}
