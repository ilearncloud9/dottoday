import 'dart:async';

import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/notifications/sound_catalogue.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Plays [key] when it names a bundled sound (not System or None): the
/// pickers' play-on-tap preview (docs/12 §6). Previews play whatever the
/// Sounds in app switch says; the OS's mute still applies.
void previewSound(WidgetRef ref, String? key) {
  final sound = catalogueSound(key);
  if (sound == null) return;
  unawaited(ref.read(soundPlayerProvider).play(sound));
}

/// Plays [sound] as the app's own feedback — the Done sound, Focus's tick —
/// unless Settings › Sounds › Sounds in app is off (docs/12 §2.6).
void playAppSound(WidgetRef ref, CatalogueSound sound) {
  final settings = ref.read(currentProfileProvider).value?.settings;
  if (!(settings?.inAppSoundsEnabled ?? true)) return;
  unawaited(ref.read(soundPlayerProvider).play(sound));
}

/// The Done sound (D4): one global choice, the same every time.
void playDoneSound(WidgetRef ref) => playAppSound(
  ref,
  resolveDoneSound(
    ref.read(currentProfileProvider).value?.settings.doneSoundId,
  ),
);
