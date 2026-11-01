import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/sound_names.gen.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/sound_catalogue.dart';
import 'package:dottoday/domain/notifications/wake_up_alarm.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/sounds/sound_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Vary the sound › Sounds (docs/15 §9): which 2–6 Start sounds rotate.
/// A tap adds or removes one and plays it; the last two can't be removed
/// and a seventh can't be added, so the set always rings.
Future<void> showWakeUpRotationSheet(BuildContext context) =>
    showAppSheet<void>(
      context: context,
      title: context.l10n.wakeUpRotationTitle,
      builder: (_) => const SoundPreviewScope(child: _RotationList()),
    );

class _RotationList extends ConsumerWidget {
  const _RotationList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(currentProfileProvider).value?.settings;
    if (settings == null) return const SizedBox.shrink();
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final picked = {for (final s in wakeUpRotation(settings)) s.id};
    final starts = [
      for (final s in soundCatalogue)
        if (s.category == SoundCategory.start) s,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.wakeUpRotationDetail(wakeUpRotationMin, wakeUpRotationMax),
          style: t.styles.rowMeta,
        ),
        for (final s in starts)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.trailing,
            title: Text(soundDisplayName(l10n, s), style: t.styles.body),
            value: picked.contains(s.id),
            onChanged: _canFlip(picked, s.id)
                ? (_) {
                    _flip(context, picked, s.id);
                    previewSound(ref, s.id);
                  }
                : null,
          ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.alertsDone),
        ),
      ],
    );
  }

  static bool _canFlip(Set<String> picked, String id) => picked.contains(id)
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

/// "3 sounds": the row's value.
String wakeUpRotationValue(AppLocalizations l10n, Settings settings) =>
    l10n.wakeUpRotationCount(wakeUpRotation(settings).length);
