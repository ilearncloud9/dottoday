import 'dart:async';

import 'package:dottoday/core/env/env_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/search/recent_searches.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/data/thinking/thinking_providers.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/features/settings/pages/thinking_status_block.dart';
import 'package:dottoday/features/settings/widgets/app_lock_group.dart';
import 'package:dottoday/features/settings/widgets/feedback_sheet.dart';
import 'package:dottoday/shared/learning/wake_up_explain_sheet.dart';
import 'package:dottoday/shared/notifications/wake_up_tier_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings › Help (docs/09 M3f.7): six quick answers — the sixth is Wake
/// Up's explain sheet with this device's tier (docs/15 §11) — then Send
/// feedback. Answers are on the device, so Help works offline.
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SettingsPageFrame(
      title: l10n.settingsHelp,
      children: [
        PageText(l10n.helpIntro),
        Column(
          children: [
            _Answer(l10n.helpMoveQ, l10n.helpMoveA),
            _Answer(l10n.helpLateQ, l10n.helpLateA),
            _Answer(l10n.helpRepeatQ, l10n.helpRepeatA),
            _Answer(l10n.helpPasteQ, l10n.helpPasteA),
            _Answer(l10n.helpKeysQ, l10n.helpKeysA),
            const _WakeUpAnswer(),
          ],
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilledButton(
            onPressed: () => unawaited(showFeedbackSheet(context)),
            child: Text(l10n.settingsFeedback),
          ),
        ),
      ],
    );
  }
}

/// A question that opens to its answer.
class _Answer extends StatelessWidget {
  const _Answer(this.question, this.answer, {this.child});

  final String question;
  final String answer;

  /// Shown in place of [answer]'s text.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        expandedAlignment: AlignmentDirectional.centerStart,
        childrenPadding: const EdgeInsets.only(bottom: DotSpace.m),
        title: Text(question, style: t.styles.body),
        children: [child ?? PageText(answer)],
      ),
    );
  }
}

/// Help › Wake Up (docs/15 §11): the explain sheet's four lines and how
/// Wake Up rings on this device, in the §2 tier's plain words.
class _WakeUpAnswer extends ConsumerWidget {
  const _WakeUpAnswer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final caps = ref.watch(alarmCapabilitiesNowProvider).value;
    final tier = caps == null ? null : wakeUpTierText(l10n, caps).$1;
    return _Answer(l10n.helpWakeUpQ, '', child: WakeUpExplain(tierLine: tier));
  }
}

/// Settings › Privacy (docs/09 M3f.7, docs/06): what stays on the device,
/// what sync sends, no tracking, crash reports when they are on; Clear
/// recent searches; where thinking help runs (M10.1, ADR-0009); and the
/// full policy when its URL is configured (M8.6).
class PrivacyPage extends ConsumerWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final hasRecent = ref.watch(recentSearchesProvider).value?.isNotEmpty;
    final env = ref.watch(envProvider);
    final policy = env.privacyPolicyUrl;
    return SettingsPageFrame(
      title: l10n.settingsPrivacy,
      children: [
        // This device's lock (M5.8), above what the page explains.
        const AppLockGroup(),
        _Section(l10n.privacyLocalTitle, l10n.privacyLocalBody),
        _Section(l10n.privacyTrackTitle, l10n.privacyTrackBody),
        _Section(l10n.privacySyncTitle, l10n.privacySyncBody),
        // Said only when Sentry is configured: otherwise nothing is sent.
        if (env.sentryDsn != null)
          _Section(l10n.privacyCrashTitle, l10n.privacyCrashBody),
        _Section(l10n.privacySearchTitle, l10n.privacySearchBody),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton(
            onPressed: hasRecent == true
                ? () => unawaited(_clear(context, ref))
                : null,
            child: Text(l10n.privacyClearSearches),
          ),
        ),
        const _ThinkingSection(),
        if (policy != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () =>
                  unawaited(ref.read(linkLauncherProvider).open(policy)),
              child: Text(l10n.privacyPolicyOpen),
            ),
          ),
      ],
    );
  }

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final text = context.l10n.snackSearchesCleared;
    await ref.read(recentSearchesProvider.notifier).clear();
    messenger.showSnackBar(SnackBar(content: Text(text)));
  }
}

/// ADR-0009's compliance line: the on-device paths, the rules fallback,
/// this device's status and next step (M14.2), and Clear thinking history.
class _ThinkingSection extends ConsumerWidget {
  const _ThinkingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DotSpace.s,
      children: [
        _Section(l10n.privacyThinkingTitle, l10n.privacyThinkingBody),
        const ThinkingStatusBlock(),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton(
            onPressed: () => unawaited(_clear(context, ref)),
            child: Text(l10n.privacyClearThinking),
          ),
        ),
      ],
    );
  }

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final text = context.l10n.snackThinkingCleared;
    await ref.read(thinkingMemoryProvider).clear();
    messenger.showSnackBar(SnackBar(content: Text(text)));
  }
}

/// A heading and its paragraph.
class _Section extends StatelessWidget {
  const _Section(this.title, this.body);

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: DotSpace.xs,
    children: [
      Semantics(
        header: true,
        child: Text(title, style: DotTheme.of(context).styles.cardTitle),
      ),
      PageText(body),
    ],
  );
}
