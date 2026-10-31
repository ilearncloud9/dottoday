import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/features/onboarding/steps/step_frame.dart';
import 'package:dottoday/shared/dot/day_shape_slider.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/time_input/time_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// O2 Day shape (docs/10 §5.1, docs/09 M4.2): "When does your day start
/// and end?" with the Settings sun → moon slider. Each move is saved to
/// the profile at once, as in Settings; Continue moves on.
class DayShapeStep extends ConsumerWidget {
  const DayShapeStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final settings = ref.watch(currentProfileProvider).value?.settings;
    if (settings == null) return const SizedBox.shrink();
    final common = commonWindow(settings);
    String at(int m) => formatClockTime(
      context,
      ClockTime.fromMinutes(m),
      use24h: settings.use24h,
    );
    return StepFrame(
      title: l10n.onboardingDayShapeTitle,
      body: l10n.onboardingDayShapeBody,
      primary: l10n.onboardingContinue,
      onPrimary: onNext,
      children: [_card(context, t, l10n, at, common)],
    );
  }

  /// The slider in a raised card; each move is saved at once.
  Widget _card(
    BuildContext context,
    DotTheme t,
    AppLocalizations l10n,
    String Function(int m) at,
    TimeWindow common,
  ) => DecoratedBox(
    decoration: BoxDecoration(
      color: t.colors.raised,
      borderRadius: BorderRadius.circular(DotRadii.card),
      border: Border.all(color: t.colors.hairline),
    ),
    child: DayShapeSlider(
      wakeMinute: windowMinutes(common.start),
      bedMinute: windowMinutes(common.end),
      timeText: at,
      awakeText: (m) => l10n.settingsAwake(formatDurationShort(l10n, m)),
      wakeLabel: l10n.settingsWakeUp,
      bedLabel: l10n.settingsWindDown,
      onChanged: (wake, bed) => unawaited(
        updateSettings(
          ProviderScope.containerOf(context, listen: false),
          (s) => withCommonWindow(
            s,
            TimeWindow(start: windowTime(wake), end: windowTime(bed)),
          ),
        ),
      ),
    ),
  );
}
