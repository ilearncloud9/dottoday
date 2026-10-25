import 'dart:async';

import 'package:dottoday/core/env/env_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/search/recent_searches.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/features/settings/widgets/app_lock_group.dart';
import 'package:dottoday/features/settings/widgets/feedback_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings › Help (docs/09 M3f.7): five quick answers, then Send
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
  const _Answer(this.question, this.answer);

  final String question;
  final String answer;

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
        children: [PageText(answer)],
      ),
    );
  }
}

/// Settings › Privacy (docs/09 M3f.7, docs/06): what stays on the device,
/// what sync sends, no tracking, crash reports when they are on; Clear
/// recent searches, and the full policy when its URL is configured (M8.6).
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
