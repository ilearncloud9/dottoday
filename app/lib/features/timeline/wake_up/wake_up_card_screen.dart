import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/layout/app_layout.dart';
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
import 'package:dottoday/features/timeline/wake_up/wake_up_dock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The Wake Up card (docs/15 §5, M17.3; E-R2-19-B, ED-314): full screen
/// over Today below the expanded width, its content in a 480 column on
/// medium widths (ED-456). From the expanded width the route hands over to
/// the panel docked beside Today ([WakeUpDocked]), as on iPad.
class WakeUpCardScreen extends ConsumerStatefulWidget {
  const WakeUpCardScreen({super.key});

  @override
  ConsumerState<WakeUpCardScreen> createState() => _WakeUpCardScreenState();
}

class _WakeUpCardScreenState extends ConsumerState<WakeUpCardScreen> {
  var _handedOver = false;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    if (AppLayout.classOf(context) == WidthClass.expanded) {
      // A notification's "I'm up" lands here: dock it beside Today instead.
      if (!_handedOver) {
        _handedOver = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ref.read(wakeUpDockedProvider.notifier).open();
          context.go(AppRoutes.today);
        });
      }
      return Scaffold(backgroundColor: t.colors.ground);
    }
    return Scaffold(
      backgroundColor: t.colors.ground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: DotSize.wakeCardColumn),
            child: WakeUpCard(onClose: _close, replaceWithFocus: true),
          ),
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

/// The card itself, wherever it is shown: its own screen or the panel
/// beside Today. It reads the day and writes nothing of its own but the day
/// row: Start opens Focus on the first dot (its own start write) or marks
/// the day started, and Shift the rest opens Rebalance's ProposalSheet,
/// which writes only on Accept. Later and × call [onClose].
class WakeUpCard extends ConsumerStatefulWidget {
  const WakeUpCard({
    required this.onClose,
    this.replaceWithFocus = false,
    super.key,
  });

  final VoidCallback onClose;

  /// Its own screen gives way to Focus; the panel opens Focus over Today.
  final bool replaceWithFocus;

  @override
  ConsumerState<WakeUpCard> createState() => _WakeUpCardState();
}

class _WakeUpCardState extends ConsumerState<WakeUpCard> {
  var _marked = false;

  /// The coach mark whose showing this visit already recorded.
  HintId? _coached;

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(wakeUpCardProvider).value;
    final minimal = watchSimplified(ref, FeatureId.wakeUpCard);
    if (model == null) return const SizedBox.shrink();
    if (!_marked) {
      _marked = true;
      unawaited(
        ref
            .read(wakeUpDayRepositoryProvider)
            .markCardShown(model.dateKey, ref.read(clockProvider).nowUtc()),
      );
    }
    final coach = watchCardCoachMark(ref, model);
    if (coach != null && _coached != coach) {
      _coached = coach;
      final container = ProviderScope.containerOf(context, listen: false);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => unawaited(recordHintShown(container, coach)),
      );
    }
    final close = widget.onClose;
    return WakeUpCardBody(
      model: model,
      minimal: minimal,
      onClose: close,
      onOpenTask: (id) => openTask(context, id),
      onShift: (min) =>
          unawaited(shiftTheRest(context, model, min, close: close)),
      onStart: () => unawaited(
        startTheDay(
          ref,
          model,
          openFocus: (id) {
            if (widget.replaceWithFocus) {
              context.pushReplacement(AppRoutes.focus(id));
              return;
            }
            close();
            unawaited(context.push(AppRoutes.focus(id)));
          },
          close: () {
            if (mounted) close();
          },
        ),
      ),
      onLater: close,
      onPlan: () {
        close();
        context.go(AppRoutes.add);
      },
      onMissionsOff: (off) => unawaited(answerMissionsOff(context, off)),
      coachMark: coach,
    );
  }
}
