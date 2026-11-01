import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/reveal/hint_providers.dart';
import 'package:dottoday/domain/entities/reveal_hint.dart';
import 'package:dottoday/domain/reveal/hint_scheduler.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The card's coach mark today (docs/15 §11), from the shared hint budget:
/// on Start the day after "I'm up" stopped the alarm (first 2 times), or on
/// Shift the rest? at a late start (once). Null while the records load.
HintId? watchCardCoachMark(WidgetRef ref, WakeUpCardModel m) {
  final records = ref.watch(revealHintsProvider).value;
  if (records == null) return null;
  final pick = pickHint(
    signals: HintSignals(
      daysOfUse: 0,
      surface: HintSurface.wakeUpCard,
      alarmStopped: m.day?.stoppedAtUtc != null && m.first != null,
      shiftOffered: m.lateMin != null && m.first != null && !m.lowEnergy,
    ),
    records: records,
    nowUtc: ref.watch(clockProvider).nowUtc(),
    zone: m.data.day.location,
  );
  return pick?.hint;
}

/// One quiet line teaching the control below or above it: muted, never a
/// bubble over the screen, so it can't cover what it explains.
class WakeUpCoachMark extends StatelessWidget {
  const WakeUpCoachMark(this.hint, {super.key});

  final HintId hint;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final text = switch (hint) {
      HintId.wakeUpShift => l10n.wakeUpDiscoveryShift,
      _ => l10n.wakeUpDiscoveryStartDay,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DotSpace.s),
      child: Text(
        text,
        style: t.styles.rowMeta.copyWith(color: t.colors.muted),
      ),
    );
  }
}
