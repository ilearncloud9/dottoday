import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/domain/time/wind_down.dart';
import 'package:dottoday/features/onboarding/steps/step_frame.dart';
import 'package:dottoday/shared/dot/day_shape_slider.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/time_input/time_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// O2 Day shape (docs/10 §5.1, docs/09 M4.2; docs/15 W6): "When does your
/// day start and end?" with the Settings sun → moon slider, and how much
/// sleep, which places Wind Down: "Wind Down 22:45 · 7 h 45 of sleep".
/// Dragging the moon instead shows the sleep it leaves. A new account starts
/// at 8 h. Each move is saved to the profile at once, as in Settings;
/// Continue moves on.
class DayShapeStep extends ConsumerStatefulWidget {
  const DayShapeStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  ConsumerState<DayShapeStep> createState() => _DayShapeStepState();
}

class _DayShapeStepState extends ConsumerState<DayShapeStep> {
  var _started = false;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final settings = ref.watch(currentProfileProvider).value?.settings;
    if (settings == null) return const SizedBox.shrink();
    final common = commonWindow(settings);
    final wake = windowMinutes(common.start);
    final bed = windowMinutes(common.end);
    // A new account plans 8 h of sleep from the start (15 W6).
    if (!_started && settings.sleepTargetMin == null) {
      _started = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _save(wake, _windDownFor(wake, defaultSleepTargetMin)),
      );
    }
    String at(int m) => formatClockTime(
      context,
      ClockTime.fromMinutes(m % _day),
      use24h: settings.use24h,
    );
    final sleep = _sleepFor(wake, bed);
    return StepFrame(
      title: l10n.onboardingDayShapeTitle,
      body: l10n.onboardingDayShapeBody,
      primary: l10n.onboardingContinue,
      onPrimary: widget.onNext,
      children: [
        _card(t, l10n, at, wake, bed),
        _sleep(t, l10n, at, wake, bed, sleep),
      ],
    );
  }

  /// The slider in a raised card; each move is saved at once.
  Widget _card(
    DotTheme t,
    AppLocalizations l10n,
    String Function(int m) at,
    int wake,
    int bed,
  ) => DecoratedBox(
    decoration: BoxDecoration(
      color: t.colors.raised,
      borderRadius: BorderRadius.circular(DotRadii.card),
      border: Border.all(color: t.colors.hairline),
    ),
    child: DayShapeSlider(
      wakeMinute: wake,
      bedMinute: bed,
      timeText: at,
      awakeText: (m) => l10n.settingsAwake(formatDurationShort(l10n, m)),
      wakeLabel: l10n.settingsWakeUp,
      bedLabel: l10n.settingsWindDown,
      onChanged: _save,
    ),
  );

  /// "How much sleep do you want?": the slider places Wind Down.
  Widget _sleep(
    DotTheme t,
    AppLocalizations l10n,
    String Function(int m) at,
    int wake,
    int bed,
    int sleep,
  ) {
    final choices = sleepTargetChoices;
    final index = choices.indexOf(_snap(sleep));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: DotSpace.l),
        Text(l10n.onboardingSleepTarget, style: t.styles.rowTitle),
        Slider(
          value: index.toDouble(),
          max: choices.length - 1,
          divisions: choices.length - 1,
          label: formatDurationShort(l10n, choices[index]),
          semanticFormatterCallback: (_) =>
              formatDurationShort(l10n, choices[index]),
          onChanged: (i) => _save(wake, _windDownFor(wake, choices[i.round()])),
        ),
        Text(
          l10n.onboardingWindDownLive(
            at(bed),
            formatDurationShort(l10n, sleep),
          ),
          style: t.styles.rowMeta,
        ),
      ],
    );
  }

  /// Saves the day [wake]–[bed] and the sleep it leaves as the target.
  void _save(int wake, int bed) => unawaited(
    updateSettings(
      ProviderScope.containerOf(context, listen: false),
      (s) =>
          withCommonWindow(
            s,
            TimeWindow(start: windowTime(wake), end: windowTime(bed)),
          ).copyWith(
            sleepTargetMin: _snap(_sleepFor(wake, bed)),
            sleepOfferAnswered: true,
          ),
    ),
  );
}

const _day = 24 * 60;

/// Minutes of sleep from Wind Down [bed] to the next [wake].
int _sleepFor(int wake, int bed) => (wake + _day - bed) % _day;

/// Wind Down for [sleep] minutes before the next [wake].
int _windDownFor(int wake, int sleep) => (wake + _day - sleep) % _day;

/// [minutes] on the slider's 15-minute steps, within 6 h–10 h.
int _snap(int minutes) {
  final steps = sleepTargetChoices;
  final rounded = (minutes / 15).round() * 15;
  return rounded.clamp(steps.first, steps.last);
}
