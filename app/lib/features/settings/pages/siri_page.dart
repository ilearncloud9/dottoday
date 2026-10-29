import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/intents/siri_providers.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings › Siri & Shortcuts (docs/09 M14.3, D3; derived — 11 §B6): what
/// Siri can do, the five phrases exactly as `AppShortcuts.strings` says
/// them (`siri_phrases_test`), how to ask, and Open Shortcuts for the
/// Action button and Control Center. iPhone only; no new intent.
class SiriPage extends ConsumerWidget {
  const SiriPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return SettingsPageFrame(
      title: l10n.settingsSiri,
      children: [
        PageText(l10n.siriIntro),
        PageText(l10n.siriHowTo),
        SettingsGroup(
          caption: l10n.siriPhrasesCaption,
          children: [
            for (final (glyph, color, phrase, detail) in [
              (
                DotGlyphs.add,
                t.colors.accentInk,
                l10n.siriPhraseAdd,
                l10n.siriPhraseAddDetail,
              ),
              (
                DotGlyphs.clock,
                t.tasks[TaskColor.sky].ink,
                l10n.siriPhraseNext,
                l10n.siriPhraseNextDetail,
              ),
              (
                DotGlyphs.check,
                t.tasks[TaskColor.mint].ink,
                l10n.siriPhraseDone,
                l10n.siriPhraseDoneDetail,
              ),
              (
                DotGlyphs.timer,
                t.tasks[TaskColor.amber].ink,
                l10n.siriPhrasePlus15,
                l10n.siriPhrasePlus15Detail,
              ),
              (
                DotGlyphs.bolt,
                t.tasks[TaskColor.violet].ink,
                l10n.siriPhraseFocus,
                l10n.siriPhraseFocusDetail,
              ),
            ])
              SettingsRow(
                glyph: glyph,
                tint: color,
                title: phrase,
                subtitle: detail,
              ),
          ],
        ),
        SettingsGroup(
          caption: l10n.siriShortcutsCaption,
          children: [
            SettingsRow(
              glyph: DotGlyphs.share,
              tint: t.tasks[TaskColor.teal].ink,
              title: l10n.siriOpenShortcuts,
              subtitle: l10n.siriShortcutsBody,
              onTap: () => unawaited(
                ref.read(linkLauncherProvider).open(shortcutsAppUri),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
