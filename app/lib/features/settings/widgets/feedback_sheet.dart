import 'dart:async';

import 'package:dottoday/core/env/env_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/feedback/feedback_providers.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/domain/feedback/feedback_mail.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Send feedback (PRD F11, R-19): what is sent, the diagnostics opt-in
/// with exactly what it adds, Write email. From Settings › ABOUT and Help.
/// The app sends nothing: the person sends the draft from their mail app.
Future<void> showFeedbackSheet(BuildContext context) => showAppSheet<void>(
  context: context,
  title: context.l10n.settingsFeedback,
  builder: (_) => const _Feedback(),
);

/// The feedback sheet.
class _Feedback extends ConsumerStatefulWidget {
  const _Feedback();

  @override
  ConsumerState<_Feedback> createState() => _FeedbackState();
}

/// A leaf: only the opt-in.
class _FeedbackState extends ConsumerState<_Feedback> {
  var _diagnostics = false;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.m,
      children: [
        Text(l10n.settingsFeedbackIntro, style: t.styles.body),
        MergeSemantics(
          child: InkWell(
            onTap: () => setState(() => _diagnostics = !_diagnostics),
            child: Row(
              spacing: DotSpace.m,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsFeedbackDiagnostics,
                        style: t.styles.body,
                      ),
                      Text(
                        l10n.settingsFeedbackDiagnosticsHint,
                        style: t.styles.rowMeta,
                      ),
                    ],
                  ),
                ),
                DotSwitch(
                  value: _diagnostics,
                  onChanged: (v) => setState(() => _diagnostics = v),
                ),
              ],
            ),
          ),
        ),
        if (_diagnostics) const _Preview(),
        FilledButton(
          onPressed: () => unawaited(_send(context)),
          child: Text(l10n.settingsFeedbackWrite),
        ),
      ],
    );
  }

  Future<void> _send(BuildContext context) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final version = await ref.read(appVersionProvider.future);
    if (!mounted) return;
    final diagnostics = _diagnostics ? await _diagnosticsText() : null;
    if (!mounted) return;
    final uri = feedbackMailto(
      subject: l10n.settingsFeedbackSubject,
      version: version,
      platform: currentFeedbackPlatform,
      recipient: ref.read(envProvider).feedbackEmail,
      diagnostics: diagnostics,
    );
    final opened = await ref.read(linkLauncherProvider).open(uri);
    navigator.pop();
    if (!opened) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsFeedbackNoMail)),
      );
    }
  }

  /// The block, waiting for it if still loading; null when unreadable —
  /// the preview said so and the failure is logged, so the email goes
  /// without it rather than not at all.
  Future<String?> _diagnosticsText() async {
    try {
      return (await ref.read(feedbackDiagnosticsProvider.future)).toText();
    } on Exception {
      return null;
    }
  }
}

/// Exactly what the opt-in adds, before anything leaves the device.
class _Preview extends ConsumerWidget {
  const _Preview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final diagnostics = ref.watch(feedbackDiagnosticsProvider);
    if (diagnostics.hasError) {
      return Text(
        l10n.settingsFeedbackDiagnosticsFailed,
        style: t.styles.rowMeta,
      );
    }
    final text = diagnostics.value?.toText();
    if (text == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.xs,
      children: [
        Text(l10n.settingsFeedbackPreview, style: t.styles.rowMeta),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: t.colors.outline),
            borderRadius: BorderRadius.circular(DotRadii.card),
          ),
          child: Padding(
            padding: const EdgeInsets.all(DotSpace.m),
            child: SelectableText(text, style: t.styles.rowMeta),
          ),
        ),
      ],
    );
  }
}
