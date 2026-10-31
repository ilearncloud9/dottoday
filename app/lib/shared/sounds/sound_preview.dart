import 'dart:async';

import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/notifications/sound/sound_player.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/notifications/sound_catalogue.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Plays [key] when it names a bundled sound (not System or None): the
/// pickers' play-on-tap preview (docs/12 §6). Previews play whatever the
/// Sounds in app switch says; the OS's mute still applies.
void previewSound(WidgetRef ref, String? key) {
  final sound = catalogueSound(key);
  if (sound == null) return;
  unawaited(ref.read(soundPlayerProvider).play(sound));
}

/// Wraps a sound picker so its preview stops when the picker closes — by
/// Done, ✕, a swipe or Back (docs/12 §6): a choice ends the preview, even a
/// 27 s Start loop. A new preview already cuts off the last one
/// ([SoundPlayer.play]).
class SoundPreviewScope extends ConsumerStatefulWidget {
  const SoundPreviewScope({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<SoundPreviewScope> createState() => _SoundPreviewScopeState();
}

class _SoundPreviewScopeState extends ConsumerState<SoundPreviewScope> {
  // Read up front: `ref` can't be used in dispose.
  late final SoundPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = ref.read(soundPlayerProvider);
  }

  @override
  void dispose() {
    unawaited(_player.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
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
