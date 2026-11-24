import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/notifications/sound_credits.gen.dart';
import 'package:dottoday/data/notifications/sound_names.gen.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/sound_catalogue.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/features/settings/widgets/sound_tier_sheet.dart';
import 'package:dottoday/shared/settings/settings_form.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sounds/sound_options.dart';
import 'package:dottoday/shared/sounds/sound_preview.dart';
import 'package:dottoday/shared/sounds/sound_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings › Reminders › Sounds (docs/12 §6; derived from `SettingsGroup`
/// rows): the default task sound — System sound, None, then Dottoday,
/// Quiet, Clear, Playful — then Start sound and Done sound, the Sound
/// effects switches (Sounds and Haptics in app), and the one credit line. A tap picks and plays; previews always play.
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
        page: SettingsPage.sounds,
        form: true,
        children: [
          if (muted) const SoundMutedBanner(),
          PageText(l10n.soundsIntro),
          _TaskSounds(
            // Unset is the Dot tone (docs/12 §3).
            selected: settings.reminderSound ?? defaultReminderSoundId,
            onPick: (key) {
              changeSettings(context, (s) => s.copyWith(reminderSound: key));
              previewSound(ref, key);
            },
          ),
          _MoreGroup(settings: settings),
          _EffectsGroup(settings: settings),
          const _Credits(),
        ],
      ),
    );
  }
}

/// The task reminder sound: the phone's list, or on a Mac/web form the
/// sections side by side as radio columns, each sound with ▶ to hear it
/// without picking it (ED-450).
class _TaskSounds extends ConsumerWidget {
  const _TaskSounds({required this.selected, required this.onPick});

  final String selected;
  final ValueChanged<String?> onPick;

  /// The columns across, at most.
  static const _columns = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final sections = settingsSoundSections(l10n);
    if (!settingsFormAt(context)) {
      return SoundOptionList(
        sections: sections,
        selected: selected,
        onPick: onPick,
      );
    }
    final t = DotTheme.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final across = MediaQuery.textScalerOf(context).scale(1) > 1.3
            ? 1
            : _columns;
        final width = (box.maxWidth - (across - 1) * DotSpace.l) / across;
        return Wrap(
          spacing: DotSpace.l,
          runSpacing: DotSpace.l,
          children: [
            for (final section in sections)
              SizedBox(
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: DotSpace.xxs,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(section.caption, style: t.styles.caption),
                    ),
                    for (final o in section.options)
                      FormRadio(
                        selected: o.key == selected,
                        title: o.label,
                        detail: o.detail,
                        onTap: () => onPick(o.key),
                        trailing: _PlayButton(sound: o.key, name: o.label),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// ▶: plays [sound] without choosing it.
class _PlayButton extends ConsumerWidget {
  const _PlayButton({required this.sound, required this.name});

  final String? sound;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (catalogueSound(sound) == null) return const SizedBox.shrink();
    final t = DotTheme.of(context);
    final label = context.l10n.soundsPlay(name);
    // Small, as E-FullA-v2's pointer controls; the line it sits on is the
    // larger target for choosing (ED-450).
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => previewSound(ref, sound),
          child: Container(
            width: DotSize.formCheck + DotSpace.xs,
            height: DotSize.formCheck + DotSpace.xs,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.colors.raised,
              border: Border.all(color: t.colors.hairlineStrong),
            ),
            child: Center(
              child: DotIcon(
                DotGlyphs.play,
                color: t.colors.accentInk,
                size: DotSize.inspectorChevron,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Start sound and Done sound.
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
    final form = settingsFormAt(context);
    final stacked =
        !form && MediaQuery.textScalerOf(context).scale(1) > _stackAbove;
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
          choices: form
              ? _choices(
                  context,
                  startSoundSections(l10n),
                  resolveStartSound(settings.startSoundId).id,
                  (s, key) => s.copyWith(startSoundId: key),
                )
              : null,
          trailing: form
              ? _PlayButton(
                  sound: resolveStartSound(settings.startSoundId).id,
                  name: start.value ?? '',
                )
              : null,
          onTap: () => unawaited(
            showSoundTierSheet(
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
          choices: form
              ? _choices(
                  context,
                  doneSoundSections(l10n),
                  resolveDoneSound(settings.doneSoundId).id,
                  (s, key) => s.copyWith(doneSoundId: key),
                )
              : null,
          trailing: form
              ? _PlayButton(
                  sound: resolveDoneSound(settings.doneSoundId).id,
                  name: done.value ?? '',
                )
              : null,
          onTap: () => unawaited(
            showSoundTierSheet(
              context,
              title: l10n.soundsDone,
              sections: doneSoundSections(l10n),
              selected: (s) => resolveDoneSound(s.doneSoundId).id,
              write: (s, key) => s.copyWith(doneSoundId: key),
            ),
          ),
        ),
      ],
    );
  }
}

/// A Mac/web pop-up's choices for Start or Done sound (ED-450).
List<FormChoice> _choices(
  BuildContext context,
  List<SoundSection> sections,
  String selected,
  Settings Function(Settings, String) write,
) => [
  for (final section in sections)
    for (final o in section.options)
      if (o.key case final key?)
        (
          label: o.label,
          selected: key == selected,
          onSelect: () => changeSettings(context, (s) => write(s, key)),
        ),
];

/// Sound effects: the app's own sounds and haptics, each one switch
/// (docs/12 §2.6), and a note that the device can still silence them.
class _EffectsGroup extends StatelessWidget {
  const _EffectsGroup({required this.settings});

  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return SettingsGroup(
      caption: l10n.soundsEffectsCaption,
      footer: l10n.soundsEffectsFooter,
      children: [
        SettingsRow(
          glyph: DotGlyphs.sound,
          tint: t.tasks[TaskColor.sky].ink,
          title: l10n.soundsInApp,
          subtitle: l10n.soundsInAppDetail,
          formLabel: l10n.soundsEffectsCaption,
          toggle: settings.inAppSoundsEnabled,
          onToggle: (on) => changeSettings(
            context,
            (s) => s.copyWith(inAppSoundsEnabled: on),
          ),
        ),
        // The Mac and the web have no haptics (ED-450).
        if (!settingsFormAt(context))
          SettingsRow(
            glyph: DotGlyphs.haptics,
            tint: t.tasks[TaskColor.amber].ink,
            title: l10n.soundsHapticsInApp,
            subtitle: l10n.soundsHapticsInAppDetail,
            toggle: settings.inAppHapticsEnabled,
            onToggle: (on) => changeSettings(
              context,
              (s) => s.copyWith(inAppHapticsEnabled: on),
            ),
          ),
      ],
    );
  }
}

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
