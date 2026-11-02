import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/reveal/hint_providers.dart';
import 'package:dottoday/domain/entities/reveal_hint.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/reveal/hint_scheduler.dart';
import 'package:dottoday/features/timeline/review/week_review_sheet.dart';
import 'package:dottoday/features/timeline/state/hint_signals.dart';
import 'package:dottoday/features/timeline/widgets/task_sheet.dart';
import 'package:dottoday/shared/learning/wake_up_explain_sheet.dart';
import 'package:dottoday/shared/thinking/status_hint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart' as tz;

/// The progressive reveal (docs/14 §5) and Wake Up's discovery (docs/15
/// §11): at most one quiet row a day above the thread — the [StatusHint]
/// line, never a modal or a toast — chosen by [pickHint]. Its first
/// showing each day is recorded; *Not now* (the promise's *Later*) retires
/// it for good.
class RevealHintRow extends ConsumerStatefulWidget {
  const RevealHintRow({required this.today, super.key});

  final DateTime today;

  @override
  ConsumerState<RevealHintRow> createState() => _RevealHintRowState();
}

/// A leaf: only which showing it has already recorded this session.
class _RevealHintRowState extends ConsumerState<RevealHintRow> {
  (HintId, DateTime)? _recorded;

  @override
  Widget build(BuildContext context) {
    final signals = watchHintSignals(ref, widget.today);
    final records = ref.watch(revealHintsProvider).value;
    final profile = ref.watch(currentProfileProvider).value;
    if (signals == null || records == null || profile == null) {
      return const SizedBox.shrink();
    }
    final pick = pickHint(
      signals: signals,
      records: records,
      nowUtc: ref.watch(clockProvider).nowUtc(),
      zone: tz.getLocation(profile.tzId),
    );
    if (pick == null) return const SizedBox.shrink();
    if (pick.firstToday && _recorded != (pick.hint, widget.today)) {
      _recorded = (pick.hint, widget.today);
      final container = ProviderScope.containerOf(context, listen: false);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => unawaited(recordHintShown(container, pick.hint)),
      );
    }
    final l10n = context.l10n;
    final promise = pick.hint == HintId.wakeUpPromise;
    // Minimal's promise is one line with one button (docs/15 §10).
    final link = promise && !watchSimplified(ref, FeatureId.wakeUpDiscovery);
    final hint = StatusHint(
      lead: _text(l10n, pick.hint),
      action: promise ? l10n.wakeUpDiscoveryTurnOn : l10n.hintShowMe,
      dismissLabel: promise ? l10n.wakeUpDiscoveryLater : l10n.promptNotNow,
      onOpen: () => _open(context, pick),
      onDismiss: () =>
          unawaited(dismissHint(ProviderScope.containerOf(context), pick.hint)),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DotSpace.page),
      child: link
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                hint,
                TextButton(
                  onPressed: () => unawaited(showWakeUpExplainSheet(context)),
                  child: Text(l10n.wakeUpSeeHowItWorks),
                ),
              ],
            )
          : hint,
    );
  }

  static String _text(AppLocalizations l10n, HintId hint) => switch (hint) {
    HintId.unstick => l10n.unstickPrompt,
    HintId.routines => l10n.hintRoutines,
    HintId.breakDown => l10n.hintBreakDown,
    HintId.nextUpWidget => l10n.hintWidget,
    HintId.weekReview => l10n.hintWeek,
    HintId.learnedDefaults => l10n.hintLearned,
    HintId.wakeUpPromise => l10n.wakeUpDiscoveryPromise,
    HintId.missionOffer => l10n.wakeUpDiscoveryMissionOffer,
    // Coach marks and the check's text: never this row.
    HintId.wakeUpStartDay || HintId.wakeUpShift || HintId.wakeUpCheckPing => '',
  };

  /// Show me: the hidden feature, where it lives.
  void _open(BuildContext context, HintPick pick) {
    final today = widget.today;
    switch (pick.hint) {
      case HintId.unstick:
        if (pick.taskId case final id?) showTaskSheet(context, id);
      case HintId.breakDown:
        if (pick.taskId case final id?) {
          Actions.maybeInvoke(context, BreakDownIntent(id));
        }
      case HintId.routines:
        unawaited(
          context.push(
            AppRoutes.settingsPage(SettingsPage.routines),
            extra: today,
          ),
        );
      case HintId.nextUpWidget:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.hintWidgetHow)));
      case HintId.weekReview:
        unawaited(showWeekReview(context, today));
      case HintId.learnedDefaults:
        unawaited(
          context.push(AppRoutes.settingsPage(SettingsPage.everything)),
        );
      // Turn on: Settings › Wake Up; the card has done its job (15 §11).
      case HintId.wakeUpPromise:
        unawaited(dismissHint(ProviderScope.containerOf(context), pick.hint));
        unawaited(context.push(AppRoutes.settingsPage(SettingsPage.wakeUp)));
      case HintId.missionOffer:
        unawaited(context.push(AppRoutes.settingsPage(SettingsPage.wakeUp)));
      case HintId.wakeUpStartDay ||
          HintId.wakeUpShift ||
          HintId.wakeUpCheckPing:
        break;
    }
  }
}
