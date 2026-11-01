import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/time/wind_down.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';

/// "− 8 h +": a sleep target on [sleepTargetChoices] (docs/15 W6), used by
/// onboarding's Day shape and the Wind Down review's one-time offer.
///
/// A stepper rather than Material's `Slider`, whose always-shown value
/// indicator portal becomes a full-screen node on the web that swallows
/// every click (found by the a11y-web check). It has two 48 pt buttons,
/// works by keyboard, and reads out the value.
class SleepStepper extends StatelessWidget {
  const SleepStepper({
    required this.minutes,
    required this.onChanged,
    super.key,
  });

  /// A value of [sleepTargetChoices].
  final int minutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final choices = sleepTargetChoices;
    final i = choices.indexOf(minutes).clamp(0, choices.length - 1);
    final value = formatDurationShort(l10n, choices[i]);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: l10n.sleepLess,
          onPressed: i == 0 ? null : () => onChanged(choices[i - 1]),
          icon: DotIcon(DotGlyphs.minus, color: t.colors.accentInk),
        ),
        Semantics(
          liveRegion: true,
          child: Text(value, style: t.styles.rowTitle),
        ),
        IconButton(
          tooltip: l10n.sleepMore,
          onPressed: i == choices.length - 1
              ? null
              : () => onChanged(choices[i + 1]),
          icon: DotIcon(DotGlyphs.add, color: t.colors.accentInk),
        ),
      ],
    );
  }
}
