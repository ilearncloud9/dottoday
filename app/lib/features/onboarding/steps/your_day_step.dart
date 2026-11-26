import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/domain/time/wind_down.dart';
import 'package:dottoday/features/onboarding/flow/onb_buttons.dart';
import 'package:dottoday/features/onboarding/onboarding_flow.dart';
import 'package:dottoday/features/onboarding/steps/day_dial.dart';
import 'package:dottoday/features/onboarding/steps/intrinsic_floor.dart';
import 'package:dottoday/shared/text/balanced_text.dart';
import 'package:dottoday/shared/time_input/time_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Your day (prototype `vDay`, `mountDay`; ED-305, ED-487): "Your day runs
/// from…", the sun for Wake Up and the moon for Wind Down on a sky, and
/// "16 h awake · 8 h of sleep". Each move is saved at once, so Today
/// behind the card follows; a new account starts at 7:00 and 8 h of sleep
/// (Wind Down 23:00). At large text the step scrolls.
class YourDayStep extends ConsumerStatefulWidget {
  const YourDayStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  ConsumerState<YourDayStep> createState() => _YourDayStepState();
}

class _YourDayStepState extends ConsumerState<YourDayStep> {
  int? _wake;
  int? _wind;
  var _wakePops = 0;
  var _windPops = 0;

  /// The profile's day, inside the dial's ranges; a new account's Wind
  /// Down 8 h before the next Wake Up (docs/15 W6), saved straight away.
  void _start(Settings s) {
    final common = commonWindow(s);
    final wake = windowMinutes(
      common.start,
    ).clamp(DayDial.wakeFirst, DayDial.wakeLast);
    var wind = windowMinutes(common.end);
    if (s.sleepTargetMin == null) wind = wake + _day - defaultSleepTargetMin;
    _wake = wake;
    _wind = wind.clamp(DayDial.windFirst, DayDial.windLast);
    if (s.sleepTargetMin == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _save());
    }
  }

  void _set({int? wake, int? wind}) {
    final hour = (wake ?? wind)! % 60 == 0;
    setState(() {
      if (wake != null) {
        _wake = wake;
        if (hour) _wakePops++;
      }
      if (wind != null) {
        _wind = wind;
        if (hour) _windPops++;
      }
    });
    // A selection tick at each hour (prototype motion table).
    if (hour) unawaited(HapticFeedback.selectionClick());
    _save();
  }

  /// Saves the day and the night it leaves as the sleep target.
  void _save() {
    final wake = _wake!;
    final wind = _wind!;
    unawaited(
      updateSettings(
        ProviderScope.containerOf(context, listen: false),
        (s) => withCommonWindow(s, dayWindow(wake, wind % _day)).copyWith(
          sleepTargetMin: _snap(_day - (wind - wake)),
          sleepOfferAnswered: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final settings = ref.watch(currentProfileProvider).value?.settings;
    if (settings == null) return const SizedBox.shrink();
    if (_wake == null) _start(settings);
    final wake = _wake!;
    final wind = _wind!;
    final bleed = onboardingInCard(MediaQuery.sizeOf(context))
        ? OnbSize.cardSide
        : OnbSize.side;
    return LayoutBuilder(
      builder: (context, box) => ClipRect(
        clipper: _Bleed(bleed),
        child: SingleChildScrollView(
          clipBehavior: Clip.none,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: OnbSize.titleTop),
                  Semantics(
                    header: true,
                    child: BalancedText(
                      l10n.onboardingDayShapeTitle,
                      style: t.styles.onbTitle,
                      textAlign: TextAlign.start,
                      maxWidth: box.maxWidth,
                    ),
                  ),
                  const SizedBox(height: OnbSize.subTop),
                  Text(l10n.onboardingDayShapeBody, style: t.styles.onbSub),
                  const SizedBox(height: OnbSize.titleTop),
                  Expanded(
                    child: IntrinsicFloor(
                      height: OnbSize.dialMinHeight,
                      child: _dial(context, settings, wake, wind, bleed),
                    ),
                  ),
                  _sum(t, l10n, wind - wake),
                  OnbPrimary(
                    label: l10n.onboardingContinue,
                    onPressed: widget.onNext,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dial(
    BuildContext context,
    Settings settings,
    int wake,
    int wind,
    double bleed,
  ) {
    final l10n = context.l10n;
    final use24h =
        settings.use24h ?? MediaQuery.alwaysUse24HourFormatOf(context);
    String time(int m) => formatClockTime(
      context,
      ClockTime.fromMinutes(m % _day),
      use24h: use24h,
    );
    return DayDial(
      wake: wake,
      wind: wind,
      bleed: bleed,
      time: time,
      // The time without ":00" ("5 AM", "05"), as `ticks` writes it.
      hour: (m) => time(m).replaceFirst(':00', ''), // l10n-ignore: a time
      wakeLabel: l10n.settingsWakeUp,
      windLabel: l10n.settingsWindDown,
      wakePops: _wakePops,
      windPops: _windPops,
      onWake: (m) => _set(wake: m),
      onWind: (m) => _set(wind: m),
    );
  }

  /// "16 h awake · 8 h of sleep", read out as it changes.
  Widget _sum(DotTheme t, AppLocalizations l10n, int awake) => Padding(
    padding: const EdgeInsets.only(
      top: OnbSize.sumTop,
      bottom: OnbSize.sumBottom,
    ),
    child: Semantics(
      liveRegion: true,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: l10n.settingsAwake(_hours(l10n, awake)),
              style: TextStyle(color: t.colors.text),
            ),
            const TextSpan(text: ' · '), // l10n-ignore: a separator
            TextSpan(
              text: l10n.onboardingDayAsleep(_hours(l10n, _day - awake)),
            ),
          ],
        ),
        style: t.styles.onbSum,
        textAlign: TextAlign.center,
      ),
    ),
  );
}

const _day = 24 * 60;

/// "16 h", "16 h 15 min", "45 min" (prototype `hrs`).
String _hours(AppLocalizations l10n, int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return l10n.durationMinutes(m);
  if (m == 0) return l10n.durationHours(h);
  return l10n.durationHoursMinutes(h, m);
}

/// [minutes] on the sleep target's 15-minute steps, within its range.
int _snap(int minutes) {
  final steps = sleepTargetChoices;
  return ((minutes / 15).round() * 15).clamp(steps.first, steps.last);
}

/// Clips the step but lets the dial reach the screen's or card's edges.
class _Bleed extends CustomClipper<Rect> {
  const _Bleed(this.bleed);

  final double bleed;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(-bleed, 0, size.width + bleed, size.height);

  @override
  bool shouldReclip(_Bleed old) => old.bleed != bleed;
}
