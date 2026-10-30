import 'package:dottoday/domain/notifications/sound_catalogue.dart';

/// Stored sound value meaning "explicitly silent": vibration / visual
/// only (docs/12-sounds.md §3, the "None" picker row).
const soundNoneKey = 'none';

/// `Settings.reminderSound` value meaning the OS's own sound. Only valid
/// in Settings; on a task it counts as an unknown id (docs/12 §3).
const soundSystemKey = 'system';

/// What a task reminder plays when nothing is chosen anywhere.
const defaultReminderSoundId = 'dot';

/// The alarm-loud tier's default, `Settings.startSoundId` (D2).
const defaultStartSoundId = 'dot_alarm';

/// The Done sound's default, `Settings.doneSoundId` (D4).
const defaultDoneSoundId = 'done.swift';

/// What a normal-tier reminder plays.
sealed class ReminderSoundChoice {
  const ReminderSoundChoice();
}

/// No sound: "None" was picked somewhere in the chain.
final class SilentSound extends ReminderSoundChoice {
  const SilentSound();

  @override
  bool operator ==(Object other) => other is SilentSound;

  @override
  int get hashCode => (SilentSound).hashCode;
}

/// The OS's default notification sound (Settings "System sound").
final class SystemSound extends ReminderSoundChoice {
  const SystemSound();

  @override
  bool operator ==(Object other) => other is SystemSound;

  @override
  int get hashCode => (SystemSound).hashCode;
}

/// A bundled [sound].
final class BundledSound extends ReminderSoundChoice {
  const BundledSound(this.sound);

  final CatalogueSound sound;

  @override
  bool operator ==(Object other) =>
      other is BundledSound && other.sound == sound;

  @override
  int get hashCode => sound.hashCode;
}

/// The bundled sound for [id]: itself when this version ships it, else its
/// category's default by id prefix (`start.` → [defaultStartSoundId],
/// `done.` → [defaultDoneSoundId], anything else →
/// [defaultReminderSoundId]). Total: never throws, never null (docs/12 §3).
///
/// ```dart
/// resolveSound('clear.lift').id;   // 'clear.lift'
/// resolveSound('start.gone').id;   // 'dot_alarm'
/// resolveSound(null).id;           // 'dot'
/// ```
CatalogueSound resolveSound(String? id) {
  final known = catalogueSound(id);
  if (known != null) return known;
  final fallback = switch (id) {
    final String s when s.startsWith('start.') => defaultStartSoundId,
    final String s when s.startsWith('done.') => defaultDoneSoundId,
    _ => defaultReminderSoundId,
  };
  // The defaults are first-party or pinned by the catalogue test.
  return catalogueSound(fallback) ?? soundCatalogue.first;
}

/// The sound of a normal-tier task reminder (docs/12 §3). The first
/// non-null value wins, in this order: [alert] (`Alert.sound`),
/// [occurrence], [series], [settings] (`Settings.reminderSound`).
/// [soundNoneKey] anywhere stops the chain silent; [soundSystemKey] only
/// counts in [settings]; an unknown id, or a Start / Done sound on a task,
/// plays the default tone, never nothing.
///
/// ```dart
/// resolveReminderSound();                                  // Bundled dot
/// resolveReminderSound(series: 'none', settings: 'bell');  // Silent
/// resolveReminderSound(settings: 'system');                // System
/// ```
ReminderSoundChoice resolveReminderSound({
  String? alert,
  String? occurrence,
  String? series,
  String? settings,
}) {
  for (final (value, inSettings) in [
    (alert, false),
    (occurrence, false),
    (series, false),
    (settings, true),
  ]) {
    if (value == null) continue;
    if (value == soundNoneKey) return const SilentSound();
    if (value == soundSystemKey && inSettings) return const SystemSound();
    final sound = catalogueSound(value);
    if (sound != null && sound.category.isNormalTier) {
      return BundledSound(sound);
    }
    return BundledSound(resolveSound(defaultReminderSoundId));
  }
  return BundledSound(resolveSound(defaultReminderSoundId));
}

/// The alarm-loud tier's sound: [id] when it is a Start sound, else
/// [defaultStartSoundId] (D2).
CatalogueSound resolveStartSound(String? id) =>
    _inCategory(id, SoundCategory.start, defaultStartSoundId);

/// The Done sound: [id] when it is a Done sound, else [defaultDoneSoundId]
/// (D4).
CatalogueSound resolveDoneSound(String? id) =>
    _inCategory(id, SoundCategory.done, defaultDoneSoundId);

CatalogueSound _inCategory(
  String? id,
  SoundCategory category,
  String fallback,
) {
  final sound = catalogueSound(id);
  return sound != null && sound.category == category
      ? sound
      : resolveSound(fallback);
}
