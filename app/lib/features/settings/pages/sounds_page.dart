import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/notifications/sound_credits.gen.dart';
import 'package:dottoday/data/notifications/sound_names.gen.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/sounds/sound_options.dart';
import 'package:dottoday/shared/sounds/sound_preview.dart';
import 'package:dottoday/shared/sounds/sound_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings › Reminders › Sounds (docs/12 §6; derived from `SettingsGroup`
/// rows): the default task sound — System sound, None, then Dottoday,
/// Quiet, Clear, Playful — then Start sound, Done sound and Sounds in app,
/// and the one credit line. A tap picks and plays; previews always play.
class SoundsPage extends ConsumerWidget {
  const SoundsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(currentProfileProvider).value?.settings;
    if (settings == null) return const SizedBox.shrink();
    final muted = ref.watch(deviceMutedProvider).value ?? false;
    return SoundPreviewScope(
      child: SettingsPageFrame(
        title: l10n.soundsTitle,
        children: [
          if (muted) const SoundMutedBanner(),
          PageText(l10n.soundsIntro),
          SoundOptionList(
            sections: settingsSoundSections(l10n),
            // Unset is the Dot tone (docs/12 §3).
            selected: settings.reminderSound ?? defaultReminderSoundId,
            onPick: (key) {
              changeSettings(context, (s) => s.copyWith(reminderSound: key));
              previewSound(ref, key);
            },
          ),
          _MoreGroup(settings: settings),
          const _Credits(),
        ],
      ),
    );
  }
}

/// Start sound, Done sound and the Sounds in app switch.
class _MoreGroup extends StatelessWidget {
  const _MoreGroup({required this.settings});

  final Settings settings;

  /// Text scale past which the chosen name moves under the title instead
  /// of squeezing it beside it (accessibility-as-code: reflow).
  static const _stackAbove = 1.3;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final stacked = MediaQuery.textScalerOf(context).scale(1) > _stackAbove;
    // The chosen name beside the title, or under it at large text with
    // what the row is for below that.
    ({String? value, String subtitle, Widget? below}) named(
      String name,
      String detail,
    ) => stacked
        ? (
            value: null,
            subtitle: name,
            below: Text(detail, style: t.styles.rowMeta),
          )
        : (value: name, subtitle: detail, below: null);
    final start = named(
      soundDisplayName(l10n, resolveStartSound(settings.startSoundId)),
      l10n.soundsStartDetail,
    );
    final done = named(
      soundDisplayName(l10n, resolveDoneSound(settings.doneSoundId)),
      l10n.soundsDoneDetail,
    );
    return SettingsGroup(
      caption: l10n.soundsMoreCaption,
      children: [
        SettingsRow(
          glyph: DotGlyphs.sunrise,
          tint: t.tasks[TaskColor.amber].ink,
          title: l10n.soundsStart,
          subtitle: start.subtitle,
          value: start.value,
          below: start.below,
          onTap: () => unawaited(
            _showTierSheet(
              context,
              title: l10n.soundsStart,
              sections: startSoundSections(l10n),
              selected: (s) => resolveStartSound(s.startSoundId).id,
              write: (s, key) => s.copyWith(startSoundId: key),
            ),
          ),
        ),
        SettingsRow(
          glyph: DotGlyphs.check,
          tint: t.tasks[TaskColor.mint].ink,
          title: l10n.soundsDone,
          subtitle: done.subtitle,
          value: done.value,
          below: done.below,
          onTap: () => unawaited(
            _showTierSheet(
              context,
              title: l10n.soundsDone,
              sections: doneSoundSections(l10n),
              selected: (s) => resolveDoneSound(s.doneSoundId).id,
              write: (s, key) => s.copyWith(doneSoundId: key),
            ),
          ),
        ),
        SettingsRow(
          glyph: DotGlyphs.sound,
          tint: t.tasks[TaskColor.sky].ink,
          title: l10n.soundsInApp,
          subtitle: l10n.soundsInAppDetail,
          toggle: settings.inAppSoundsEnabled,
          onToggle: (on) => changeSettings(
            context,
            (s) => s.copyWith(inAppSoundsEnabled: on),
          ),
        ),
      ],
    );
  }
}

/// The Start or Done list in a sheet: a tap picks and plays; Done closes
/// and stops the preview.
Future<void> _showTierSheet(
  BuildContext context, {
  required String title,
  required List<SoundSection> sections,
  required String Function(Settings) selected,
  required Settings Function(Settings, String) write,
}) => showAppSheet<void>(
  context: context,
  title: title,
  builder: (_) =>
      SoundPreviewScope(child: _tierList(sections, selected, write)),
);

Widget _tierList(
  List<SoundSection> sections,
  String Function(Settings) selected,
  Settings Function(Settings, String) write,
) => Consumer(
  builder: (context, ref, _) {
    final settings = ref.watch(currentProfileProvider).value?.settings;
    if (settings == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        if (ref.watch(deviceMutedProvider).value ?? false)
          const SoundMutedBanner(),
        SoundOptionList(
          sections: sections,
          selected: selected(settings),
          onPick: (key) {
            if (key == null) return;
            changeSettings(context, (s) => write(s, key));
            previewSound(ref, key);
          },
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.alertsDone),
        ),
      ],
    );
  },
);

/// The single credit line per source (docs/12 §1), each a link to it.
class _Credits extends ConsumerWidget {
  const _Credits();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final source in soundCreditSources)
          Semantics(
            link: true,
            child: TextButton(
              style: TextButton.styleFrom(
                alignment: AlignmentDirectional.centerStart,
                foregroundColor: t.colors.muted,
                textStyle: t.styles.rowMeta,
              ),
              onPressed: () => unawaited(
                ref.read(linkLauncherProvider).open(Uri.parse(source.url)),
              ),
              child: Text(l10n.soundsCredit(source.name, source.license)),
            ),
          ),
      ],
    );
  }
}
