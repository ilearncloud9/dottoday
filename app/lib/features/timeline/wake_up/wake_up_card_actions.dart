import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/wake_up/wake_up_card.dart';
import 'package:dottoday/features/timeline/state/rebalance_flow.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the Wake Up card's answers do, wherever the card is drawn: its
/// own screen (docs/15 §5) or folded into Minimal's Now (E-R2-26 frame 4).
/// [close] puts the card away: the screen pops, Now records it answered.

/// Start the day (15 §5 step 7): Focus on the first dot when it begins
/// within 15 min ([openFocus] with its id), else the day is marked started
/// and the Wake Up Check is called off (15 W3).
Future<void> startTheDay(
  WidgetRef ref,
  WakeUpCardModel model, {
  required ValueChanged<String> openFocus,
  required VoidCallback close,
}) async {
  final now = ref.read(clockProvider).nowUtc();
  if (startDot(model.first, now) case final dot?) {
    openFocus(dot.id);
    return;
  }
  final sync = ref.read(notificationSyncProvider);
  final logger = ref.read(loggerProvider);
  await ref.read(wakeUpDayRepositoryProvider).markStarted(model.dateKey, now);
  close();
  try {
    await sync.resync(model.data.userId);
  } on Object catch (e, st) {
    logger.error(
      'wake_up.resync_failed', // l10n-ignore: log key
      error: e,
      stackTrace: st,
    );
  }
}

/// Rebalance by the minutes up after plan, from now (15 §5 step 6). The
/// card is put away first; nothing is written before Accept.
Future<void> shiftTheRest(
  BuildContext context,
  WakeUpCardModel model,
  int minutes, {
  required VoidCallback close,
}) async {
  final l10n = context.l10n;
  final container = ProviderScope.containerOf(context, listen: false);
  close();
  await openRebalance(
    container,
    l10n,
    today: model.data.day.date,
    fromUtc: model.nowUtc,
    deltaMin: minutes,
    subtitle: l10n.wakeUpCardLate(minutes),
    title: l10n.wakeUpCardShift,
  );
}

/// The once-only offer (15 §8 rule 4): either answer retires it; only
/// "Turn off" turns missions off.
Future<void> answerMissionsOff(BuildContext context, bool off) =>
    updateSettings(
      ProviderScope.containerOf(context, listen: false),
      (s) => s.copyWith(
        missionOffOfferAnswered: true,
        missionMode: off ? MissionMode.off : s.missionMode,
      ),
    );
