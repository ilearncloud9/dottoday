import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/notifications/wake_up_alarm.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sounds/sound_options.dart';
import 'package:dottoday/shared/sounds/sound_preview.dart';
import 'package:dottoday/shared/sounds/sound_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wake Up and Wind Down › Vary the sound (docs/15 §9; E-Phones draws the
/// row, owner 2026-11-24 the page): the switch, then which 2–6 Start
/// sounds rotate. A tap adds or removes one and plays it; the last two
/// can't be removed and a seventh can't be added, so the set always rings.
class VarySoundPage extends ConsumerWidget {
  const VarySoundPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(currentProfileProvider).value?.settings;
    if (settings == null) return const SizedBox.shrink();
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final picked = {for (final s in wakeUpRotation(settings)) s.id};
    final options = startSoundSections(l10n).first.options;
    return SoundPreviewScope(
      child: SettingsPageFrame(
        title: l10n.wakeUpVary,
        page: SettingsPage.varySound,
        children: [
          SettingsGroup(
            caption: '',
            children: [
              SettingsRow(
                glyph: DotGlyphs.repeat,
                tint: t.tasks[TaskColor.violet].ink,
                title: l10n.wakeUpVary,
                subtitle: l10n.wakeUpVaryDetail,
                toggle: settings.wakeUpVarySound,
                onToggle: (on) => changeSettings(
                  context,
                  (s) => s.copyWith(wakeUpVarySound: on),
                ),
              ),
            ],
          ),
          if (settings.wakeUpVarySound) ...[
            SoundOptionList(
              sections: [SoundSection(l10n.wakeUpRotationTitle, options)],
              selected: null,
              picked: picked,
              disabled: {
                for (final o in options)
                  if (!_canFlip(picked, o.key)) o.key,
              },
              onPick: (key) {
                if (key == null) return;
                _flip(context, picked, key);
                previewSound(ref, key);
              },
            ),
            PageText(
              l10n.wakeUpRotationDetail(wakeUpRotationMin, wakeUpRotationMax),
            ),
          ],
        ],
      ),
    );
  }

  static bool _canFlip(Set<String> picked, String? id) => picked.contains(id)
      ? picked.length > wakeUpRotationMin
      : picked.length < wakeUpRotationMax;

  static void _flip(BuildContext context, Set<String> picked, String id) {
    final next = picked.contains(id)
        ? (picked.toSet()..remove(id))
        : {...picked, id};
    changeSettings(
      context,
      (s) => s.copyWith(wakeUpRotationIds: next.toList()),
    );
  }
}
