import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/tips/seen_tips.dart';
import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/features/timeline/widgets/prompt_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Today's one-time "Ask Siri 'What's next in Dottoday'" card (docs/09
/// M14.3, D3; derived): iPhone only, after the third task added since
/// onboarding ([siriTipDueProvider]). Show me opens Settings › Siri &
/// Shortcuts; either button puts it away for good on this device.
class SiriTipCard extends ConsumerWidget {
  const SiriTipCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(siriTipDueProvider).value != true) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    void putAway() =>
        unawaited(ref.read(seenTipsProvider.notifier).putAway(Tip.siriToday));
    return PromptCard(
      title: l10n.settingsSiri,
      child: PromptNudge(
        detail: l10n.siriTipTitle,
        action: l10n.siriTipShow,
        dismissLabel: l10n.tipDismiss,
        onAction: () {
          putAway();
          unawaited(context.push(AppRoutes.settingsPage(SettingsPage.siri)));
        },
        onNotNow: putAway,
      ),
    );
  }
}
