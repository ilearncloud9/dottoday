import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/scheduling/learning_meta.dart';
import 'package:dottoday/data/scheduling/learning_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/scheduling/low_energy.dart';
import 'package:dottoday/features/timeline/state/reality_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What today's card says about learning (docs/13 §4.2–§4.3): whether it
/// offers Plan / Reality, the line under its header, and the one-time
/// highlight of the toggle.
typedef TodayLearning = ({
  bool offer,
  Widget? note,
  ({String announcement, VoidCallback onDone})? highlight,
});

/// [TodayLearning] for the day page. [today] is the local date; the
/// crossing of the reality threshold is remembered on this device as soon
/// as it is seen, so the toggle stays when the 90-day window later empties.
TodayLearning todayLearning(
  BuildContext context,
  WidgetRef ref, {
  required bool isToday,
  required bool isSide,
  required bool hasActuals,
  required bool realityOn,
  required Settings settings,
  required DateTime now,
  required DateTime today,
}) {
  final total = ref.watch(learningThresholdsProvider).realityMinRuns;
  final progress = ref.watch(learningProgressProvider).value;
  final meta = ref.watch(learningMetaProvider).value;
  ref.listen(learningProgressProvider, (_, next) {
    final crossed = next.value?.realityRevealed ?? false;
    final stored = ref.read(learningMetaProvider).value?.realityRevealed;
    if (crossed && stored == false) {
      unawaited(
        ref.read(learningMetaProvider.notifier).markRealityRevealed(today),
      );
    }
  });
  final revealed = progress?.realityRevealed ?? meta?.realityRevealed ?? false;
  final offer = offerReality(
    isToday: isToday,
    isSide: isSide,
    revealed: revealed,
  );
  final prompts = showLearningPromptsOnToday(
    lowEnergy: lowEnergyOn(settings, now),
    // docs/12 (minimal mode) lands separately and wires its switch here.
    minimalMode: false,
  );
  final l10n = context.l10n;
  Widget? note;
  if (offer && realityOn && !hasActuals) {
    note = _NoteLine(text: l10n.realityNothingStartedToday);
  } else if (progress != null &&
      meta != null &&
      showLearningCaption(
        isToday: isToday,
        revealed: revealed,
        promptsOnToday: prompts,
        today: today,
        putAwayOn: meta.captionDay,
      )) {
    final done = progress.realityRuns.clamp(0, total);
    note = _NoteLine(
      text: l10n.learnCaption(total, done),
      onHide: () => unawaited(
        ref.read(learningMetaProvider.notifier).putCaptionAway(today),
      ),
    );
  }
  final highlight = offer && prompts && meta != null && !meta.realityHighlighted
      ? (
          announcement: l10n.learnRealityReady,
          onDone: () => unawaited(
            ref.read(learningMetaProvider.notifier).markRealityHighlighted(),
          ),
        )
      : null;
  return (offer: offer, note: note, highlight: highlight);
}

/// One muted line under the card's header, with a × to hide it until
/// tomorrow when [onHide] is set.
class _NoteLine extends StatelessWidget {
  const _NoteLine({required this.text, this.onHide});

  final String text;
  final VoidCallback? onHide;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final hide = onHide;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        DotSpace.l,
        0,
        DotSpace.xs,
        DotSpace.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: t.styles.rowMeta.copyWith(color: t.colors.muted),
            ),
          ),
          if (hide != null)
            IconButton(
              onPressed: hide,
              tooltip: context.l10n.learnCaptionHide,
              // 48 covers both floors (44 pt, 48 dp).
              constraints: const BoxConstraints.tightFor(
                width: DotTouch.android,
                height: DotTouch.android,
              ),
              icon: DotIcon(
                DotGlyphs.close,
                color: t.colors.muted,
                size: DotSize.rowIcon,
              ),
            ),
        ],
      ),
    );
  }
}
