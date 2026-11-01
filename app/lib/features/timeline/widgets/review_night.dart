import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/wind_down.dart';
import 'package:dottoday/features/timeline/state/day_ends.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Wind Down review's first line (docs/15 W6): the night it plans,
/// "7 h 20 until Wake Up at 06:30", or "7 h 45 if you wind down now"
/// before Wind Down. A plan, never a measure: no score, no comparison.
class ReviewNightLine extends ConsumerWidget {
  const ReviewNightLine({required this.day, super.key});

  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ends = ref.watch(dayEndsProvider(day)).value;
    final data = ref.watch(timelineDataProvider(day)).value;
    if (ends == null || data == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    final length = formatDurationShort(
      l10n,
      nightMinutes(now, ends.nextWakeUtc),
    );
    final wake = timeOfUtc(
      context,
      data.day.location,
      ends.nextWakeUtc,
      use24h: use24hFor(context, data.settings.use24h),
    );
    return Text(
      now.isBefore(ends.shape.bedUtc)
          ? l10n.reviewNightIfNow(length)
          : l10n.reviewNightUntil(length, wake),
      style: DotTheme.of(context).styles.body,
    );
  }
}

/// The one-time sleep offer for existing users (docs/15 §11, W6): "New:
/// tell Dottoday how much sleep you want…" with a slider (8 h to start),
/// Set and Not now. Either answer retires it for good
/// (`sleepOfferAnswered`); Set writes the target, and Wind Down follows
/// from tomorrow's first dot.
class SleepOffer extends StatefulWidget {
  const SleepOffer({super.key});

  @override
  State<SleepOffer> createState() => _SleepOfferState();
}

class _SleepOfferState extends State<SleepOffer> {
  var _minutes = defaultSleepTargetMin;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final choices = sleepTargetChoices;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.reviewSleepOffer, style: t.styles.body),
        Slider(
          value: choices.indexOf(_minutes).toDouble(),
          max: choices.length - 1,
          divisions: choices.length - 1,
          label: formatDurationShort(l10n, _minutes),
          semanticFormatterCallback: (_) => formatDurationShort(l10n, _minutes),
          onChanged: (i) => setState(() => _minutes = choices[i.round()]),
        ),
        Text(formatDurationShort(l10n, _minutes), style: t.styles.rowMeta),
        Wrap(
          spacing: DotSpace.s,
          children: [
            FilledButton(
              onPressed: () => _answer(
                (s) => s.copyWith(
                  sleepTargetMin: _minutes,
                  sleepOfferAnswered: true,
                ),
              ),
              child: Text(l10n.reviewSleepOfferSet),
            ),
            TextButton(
              onPressed: () =>
                  _answer((s) => s.copyWith(sleepOfferAnswered: true)),
              child: Text(l10n.reviewSleepOfferLater),
            ),
          ],
        ),
      ],
    );
  }

  void _answer(Settings Function(Settings) change) => unawaited(
    updateSettings(ProviderScope.containerOf(context, listen: false), change),
  );
}
