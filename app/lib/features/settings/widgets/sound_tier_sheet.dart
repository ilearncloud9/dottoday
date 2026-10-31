import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/sounds/sound_options.dart';
import 'package:dottoday/shared/sounds/sound_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Start or Done list in a sheet: a tap picks and plays; Done closes
/// and stops the preview.
Future<void> showSoundTierSheet(
  BuildContext context, {
  required String title,
  required List<SoundSection> sections,
  required String Function(Settings) selected,
  required Settings Function(Settings, String) write,
}) => showAppSheet<void>(
  context: context,
  title: title,
  builder: (_) => SoundPreviewScope(
    child: Consumer(
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
    ),
  ),
);
