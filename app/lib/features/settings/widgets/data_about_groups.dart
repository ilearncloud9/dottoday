import 'dart:async';

import 'package:dottoday/core/env/env_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/domain/feedback/feedback_mail.dart';
import 'package:dottoday/features/settings/widgets/trash_sheet.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// DATA: Trash (R-11). Calendars and Export join with their pages (M3f.7).
class DataGroup extends StatelessWidget {
  const DataGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return SettingsGroup(
      caption: l10n.settingsData,
      children: [
        SettingsRow(
          glyph: DotGlyphs.trash,
          tint: t.colors.muted,
          title: l10n.settingsTrash,
          subtitle: l10n.settingsTrashDetail,
          onTap: () => unawaited(showTrashSheet(context)),
        ),
      ],
    );
  }
}

/// ABOUT: Version, What's new, Send feedback (PRD F11, R-19).
class AboutGroup extends ConsumerWidget {
  const AboutGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final version = ref.watch(appVersionProvider).value;
    return SettingsGroup(
      caption: l10n.settingsAbout,
      children: [
        SettingsRow(
          glyph: DotGlyphs.today,
          tint: t.colors.accentInk,
          title: l10n.settingsVersion,
          value: version,
        ),
        SettingsRow(
          glyph: DotGlyphs.bolt,
          tint: t.tasks[TaskColor.amber].ink,
          title: l10n.settingsWhatsNew,
          onTap: () => unawaited(
            showAppSheet<void>(
              context: context,
              title: l10n.settingsWhatsNew,
              builder: (_) =>
                  Text(l10n.settingsWhatsNewBody, style: t.styles.body),
            ),
          ),
        ),
        SettingsRow(
          glyph: DotGlyphs.edit,
          tint: t.tasks[TaskColor.mint].ink,
          title: l10n.settingsFeedback,
          onTap: () => unawaited(_feedback(context, version)),
        ),
      ],
    );
  }

  Future<void> _feedback(BuildContext context, String? version) =>
      showAppSheet<void>(
        context: context,
        title: context.l10n.settingsFeedback,
        builder: (_) => _Feedback(version: version ?? ''),
      );
}

/// The feedback sheet: what is sent, the diagnostics opt-in, Write email.
class _Feedback extends ConsumerStatefulWidget {
  const _Feedback({required this.version});

  final String version;

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
              children: [
                Expanded(
                  child: Text(
                    l10n.settingsFeedbackDiagnostics,
                    style: t.styles.body,
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
    final platform = feedbackPlatform(
      web: kIsWeb,
      target: defaultTargetPlatform.name,
    );
    final uri = feedbackMailto(
      subject: l10n.settingsFeedbackSubject,
      version: widget.version,
      platform: platform,
      recipient: ref.read(envProvider).feedbackEmail,
      diagnostics: _diagnostics
          ? feedbackDiagnostics(version: widget.version, platform: platform)
          : null,
    );
    final opened = await ref.read(linkLauncherProvider).open(uri);
    navigator.pop();
    if (!opened) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsFeedbackNoMail)),
      );
    }
  }
}
