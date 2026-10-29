import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/intents/siri_providers.dart';
import 'package:dottoday/data/onboarding/first_thread.dart';
import 'package:dottoday/domain/scheduling/day_capacity.dart';
import 'package:dottoday/features/onboarding/steps/step_frame.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:dottoday/shared/dot/thread_day.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// O6 Done (docs/10 §5.1, docs/09 M4.6): tomorrow's thread with the
/// habits from O3 on it, and "Open today", which ends onboarding. On
/// iPhone, one line points to Siri (M14.3).
class DoneStep extends ConsumerWidget {
  const DoneStep({required this.onFinish, super.key});

  final Future<void> Function() onFinish;

  /// Tall enough for a few rows; the card scrolls inside.
  static const _cardHeight = 420.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = DotTheme.of(context);
    final first = ref.watch(firstThreadProvider).value;
    final empty = first == null || first.rows.isEmpty;
    return StepFrame(
      title: l10n.onboardingDoneTitle,
      body: empty ? l10n.onboardingDoneEmpty : l10n.onboardingDoneBody,
      primary: l10n.onboardingOpenToday,
      onPrimary: () => unawaited(onFinish()),
      children: [
        if (first != null)
          SizedBox(height: _cardHeight, child: _card(context, ref, first)),
        // One quiet line on iPhone (M14.3, D3); no new step.
        if (ref.watch(siriAvailableProvider))
          Text(
            l10n.onboardingSiriLine,
            style: t.styles.rowMeta.copyWith(color: t.colors.muted),
          ),
      ],
    );
  }

  Widget _card(BuildContext context, WidgetRef ref, FirstThread first) {
    final l10n = context.l10n;
    final use24h = use24hFor(context, first.use24h);
    final format = ThreadFormat(
      time: (utc) => timeOfUtc(context, first.zone, utc, use24h: use24h),
      range: l10n.threadTimeRange,
      duration: (m) => formatDurationShort(l10n, m),
    );
    final planned = first.rows.fold(0, (sum, o) => sum + o.durationMin);
    return DayCard(
      title: l10n.onboardingTomorrow,
      summary: DaySummary(
        done: 0,
        total: first.rows.length,
        plannedMinutes: planned,
        freeMinutes: capacityOf(first.rows, first.shape).freeMinutes,
      ),
      entries: threadEntries(
        blocks: first.rows,
        shape: first.shape,
        nowUtc: ref.watch(clockProvider).nowUtc(),
        format: format,
      ),
    );
  }
}
