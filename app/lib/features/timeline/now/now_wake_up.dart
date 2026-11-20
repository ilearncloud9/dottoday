import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_actions.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_body.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The Wake Up card folded into Minimal's Now (owner, E-R2-26 frame 4;
/// R2-19's card): "Good morning…", the first dot, Start the day and Later,
/// raised under the horizon. It stays until one of them answers it; the
/// answer is the day's "card shown", so it comes once a day, as the card's
/// own screen does.
class NowWakeUp extends ConsumerWidget {
  const NowWakeUp({required this.model, super.key});

  final WakeUpCardModel model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    void putAway() => unawaited(
      ref
          .read(wakeUpDayRepositoryProvider)
          .markCardShown(model.dateKey, ref.read(clockProvider).nowUtc())
          .then((_) => ref.invalidate(wakeUpCardProvider)),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.raised,
        borderRadius: BorderRadius.circular(DotRadii.sheet),
        boxShadow: DotElevation.capsule(t.colors),
      ),
      child: WakeUpCardBody(
        model: model,
        minimal: true,
        inline: true,
        onOpenTask: (id) => openTask(context, id),
        onShift: (min) =>
            unawaited(shiftTheRest(context, model, min, close: putAway)),
        onStart: () => unawaited(
          startTheDay(
            ref,
            model,
            openFocus: (id) {
              putAway();
              unawaited(context.push(AppRoutes.focus(id)));
            },
            close: putAway,
          ),
        ),
        onLater: putAway,
        onPlan: () => context.go(AppRoutes.add),
        onMissionsOff: (off) => unawaited(answerMissionsOff(context, off)),
      ),
    );
  }
}
