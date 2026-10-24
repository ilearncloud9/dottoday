/// The bundled reminder sounds (docs/02 F6.6, M8.4d): short tones made for
/// Dottoday by `tool/gen_sounds.dart`, no third-party audio. Loud dots keep
/// their own alarm chime (11 A0); this set is for every other task
/// reminder. The stored key is [name].
enum ReminderSound {
  /// One soft ping.
  dot,

  /// Two notes, rising.
  chime,

  /// A small bell.
  bell,

  /// Three quick notes.
  ripple;

  /// The sound stored as [key] (`Settings.reminderSound`, `Alert.sound`),
  /// or null for the system sound — also for a key this version doesn't
  /// know (a newer device's), so a stored string never names a file.
  static ReminderSound? fromKey(String? key) =>
      values.where((s) => s.name == key).firstOrNull;
}
