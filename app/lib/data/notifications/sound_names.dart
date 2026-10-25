import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/notifications/reminder_sound.dart';

/// [sound]'s name in the UI and in Android's channel list ("Chime").
String soundName(AppLocalizations l10n, ReminderSound sound) => switch (sound) {
  ReminderSound.dot => l10n.soundDot,
  ReminderSound.chime => l10n.soundChime,
  ReminderSound.bell => l10n.soundBell,
  ReminderSound.ripple => l10n.soundRipple,
};
