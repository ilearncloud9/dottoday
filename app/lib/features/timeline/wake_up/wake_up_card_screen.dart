import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/wake_up/wake_up_card.dart';
import 'package:dottoday/features/timeline/state/rebalance_flow.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_body.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_state.dart';
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
                      onOpenTask: (id) =>
                          unawaited(context.push(AppRoutes.task(id))),
                      onShift: (min) => unawaited(_shift(model, min)),
                      onStart: () => unawaited(_start(model)),
                      onLater: _close,
                      onPlan: () => context.go(AppRoutes.add),
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

  /// Focus on the first dot when it begins within 15 min, else the day
  /// is marked started and Today shows (15 §5 step 7).
  Future<void> _start(WakeUpCardModel model) async {
    final now = ref.read(clockProvider).nowUtc();
    if (startDot(model.first, now) case final dot?) {
      context.pushReplacement(AppRoutes.focus(dot.id));
      return;
    }
    await ref.read(wakeUpDayRepositoryProvider).markStarted(model.dateKey, now);
    if (mounted) _close();
  }

  /// Rebalance by the minutes up after plan, from now (15 §5 step 6). The
  /// card closes first so the sheet opens over Today; nothing is written
  /// before Accept.
  Future<void> _shift(WakeUpCardModel model, int minutes) async {
    final l10n = context.l10n;
    final container = ProviderScope.containerOf(context, listen: false);
    _close();
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
}
