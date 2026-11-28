import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/sounds/sound_options.dart';
import 'package:dottoday/shared/sounds/sound_preview.dart';
import 'package:dottoday/shared/sounds/sound_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A task's own sound (docs/12 §6): Default, None, or a sound, picked with
/// a preview; the task editor's Sound row and Create task's ⋯ › Sound.
/// Returns the pick (`key` null is Default), or null when dismissed.
Future<({String? key})?> showSoundPicker(
  BuildContext context, {
  required String? initial,
}) => showAppSheet<({String? key})>(
  context: context,
  // The list is long: it scrolls between a fixed title and Done.
  fullHeight: true,
  builder: (_) => _SoundSheet(initial: initial),
);

/// The picker: Default, None, then the sound sections. A tap marks and
/// plays; Done returns the mark. Closing stops the preview.
class _SoundSheet extends ConsumerStatefulWidget {
  const _SoundSheet({required this.initial});

  final String? initial;

  @override
  ConsumerState<_SoundSheet> createState() => _SoundSheetState();
}

class _SoundSheetState extends ConsumerState<_SoundSheet> {
  late String? _picked = widget.initial;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final fallback = ref
        .watch(currentProfileProvider)
        .value
        ?.settings
        .reminderSound;
    return SoundPreviewScope(
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: DotSpace.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DotSpace.s,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(l10n.sheetSound, style: t.styles.cardTitle),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: l10n.sheetClose,
                  icon: DotIcon(DotGlyphs.close, color: t.colors.secondary),
                ),
              ],
            ),
            if (ref.watch(deviceMutedProvider).value ?? false)
              const SoundMutedBanner(),
            Expanded(
              child: SingleChildScrollView(
                child: SoundOptionList(
                  sections: taskSoundSections(
                    l10n,
                    defaultName: reminderSoundName(l10n, fallback),
                  ),
                  selected: _picked,
                  onPick: (key) {
                    setState(() => _picked = key);
                    // Default plays what the task will then play.
                    previewSound(
                      ref,
                      key ?? fallback ?? defaultReminderSoundId,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: DotSpace.l),
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop((key: _picked)),
                child: Text(l10n.alertsDone),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
