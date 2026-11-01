import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/wake_up/wake_up_providers.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The learned offer under Sleep target (docs/15 §7b): "You usually get
/// up ~12 min after Wake Up. Move Wind Down 15 min earlier?" Move it adds
/// the minutes to the sleep target, so Wind Down follows; either answer
/// quiets it for 30 days. Never automatic.
class WindDownLearnOffer extends ConsumerWidget {
  const WindDownLearnOffer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offer = ref.watch(learnedWindDownOfferProvider).value;
    if (offer == null) return const SizedBox.shrink();
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    void answer({required bool move}) {
      final now = ref.read(clockProvider).nowUtc();
      changeSettings(
        context,
        (s) => s.copyWith(
          windDownLearnOfferAt: now,
          sleepTargetMin: move && s.sleepTargetMin != null
              ? s.sleepTargetMin! + offer.more
              : s.sleepTargetMin,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.windDownLearnOffer(offer.usual, offer.more),
          style: t.styles.body,
        ),
        Wrap(
          spacing: DotSpace.s,
          children: [
            TextButton(
              onPressed: () => answer(move: true),
              child: Text(l10n.windDownLearnMove),
            ),
            TextButton(
              onPressed: () => answer(move: false),
              child: Text(l10n.windDownLearnKeep),
            ),
          ],
        ),
      ],
    );
  }
}
