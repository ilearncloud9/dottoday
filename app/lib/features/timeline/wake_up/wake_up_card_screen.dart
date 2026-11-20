import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/reveal/hint_providers.dart';
import 'package:dottoday/domain/entities/reveal_hint.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_actions.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_body.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_state.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_coach_mark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The Wake Up card (docs/15 §5, M17.3): full screen over Today, once a
/// day. It reads the day and writes nothing of its own but the day row:
/// Start opens Focus on the first dot (its own start write) or marks the
/// day started, and Shift the rest opens Rebalance's ProposalSheet, which
/// writes only on Accept. Later and × close it.
class WakeUpCardScreen extends ConsumerStatefulWidget {
  const WakeUpCardScreen({super.key});

  @override
  ConsumerState<WakeUpCardScreen> createState() => _WakeUpCardScreenState();
}

class _WakeUpCardScreenState extends ConsumerState<WakeUpCardScreen> {
  var _marked = false;

  /// The coach mark whose showing this visit already recorded.
  HintId? _coached;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final model = ref.watch(wakeUpCardProvider).value;
    final minimal = watchSimplified(ref, FeatureId.wakeUpCard);
    if (model != null && !_marked) {
      _marked = true;
      unawaited(
        ref
            .read(wakeUpDayRepositoryProvider)
            .markCardShown(model.dateKey, ref.read(clockProvider).nowUtc()),
      );
    }
    final coach = model == null ? null : watchCardCoachMark(ref, model);
    if (coach != null && _coached != coach) {
      _coached = coach;
      final container = ProviderScope.containerOf(context, listen: false);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => unawaited(recordHintShown(container, coach)),
      );
    }
    return Scaffold(
      backgroundColor: t.colors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: _close,
                icon: DotIcon(DotGlyphs.close, color: t.colors.text),
              ),
            ),
            Expanded(
              child: model == null
                  ? const SizedBox.shrink()
                  : WakeUpCardBody(
                      model: model,
                      minimal: minimal,
                      onOpenTask: (id) => openTask(context, id),
                      onShift: (min) => unawaited(
                        shiftTheRest(context, model, min, close: _close),
                      ),
                      onStart: () => unawaited(
                        startTheDay(
                          ref,
                          model,
                          openFocus: (id) =>
                              context.pushReplacement(AppRoutes.focus(id)),
                          close: () {
                            if (mounted) _close();
                          },
                        ),
                      ),
                      onLater: _close,
                      onPlan: () => context.go(AppRoutes.add),
                      onMissionsOff: (off) =>
                          unawaited(answerMissionsOff(context, off)),
                      coachMark: coach,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.today);
    }
  }
}
