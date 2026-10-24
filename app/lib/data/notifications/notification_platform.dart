import 'package:dottoday/domain/notifications/reminder_sound.dart';

/// Which Android channel (docs/07 Android) a notification posts on; Apple
/// platforms ignore it.
enum NotificationChannelKind {
  alerts,
  summary,

  /// Loud dot-starts (11 A0): alarm audio, full-screen intent.
  alarms,
}

/// The bundled alarm chime: copied into `Library/Sounds` on iOS
/// (`installAlarmSound`), in the app bundle's Resources on macOS
/// (`tool/xcode_add_sounds.rb`) — where notification sounds are looked up.
const alarmSoundFile = 'dot_alarm.caf';

/// [sound]'s file: a Flutter asset in `assets/sounds/` (copied to
/// `Library/Sounds` on iOS, bundled as a resource on macOS, played by the
/// web's in-app strip)
/// and, without the extension, an Android raw resource (`tool/gen_sounds.dart`).
String reminderSoundFile(ReminderSound sound) => 'reminder_${sound.name}.wav';

/// One notification, composed and ready for the OS.
final class OsNotification {
  const OsNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.fireAtUtc,
    required this.payload,
    required this.channel,
    this.silent = false,
    this.timeSensitive = false,
    this.loud = false,
    this.withActions = true,
    this.sound,
  });

  final int id;
  final String title;
  final String body;
  final DateTime fireAtUtc;
  final String payload;
  final NotificationChannelKind channel;

  /// Quiet hours: delivered without sound or banner (docs/02 F6).
  final bool silent;

  /// iOS time-sensitive interruption level (docs/07 iOS).
  final bool timeSensitive;

  /// Rings like an alarm: the day's first dot or a routine start (11 A0).
  /// Apple platforms play [alarmSoundFile]; Android posts on the alarm
  /// channel.
  final bool loud;

  /// Done / Snooze / Open (task alerts); Bedtime has none.
  final bool withActions;

  /// A bundled sound (F6.6); null plays the system sound. Never set with
  /// [loud], which has its own chime.
  final ReminderSound? sound;
}

/// A tap or action on a delivered notification.
final class NotificationTap {
  const NotificationTap({this.id, this.actionId, this.payload});

  final int? id;
  final String? actionId;
  final String? payload;
}

/// The OS scheduler under the gateway: a port so the scheduling logic is
/// tested without a device (`FlnNotificationPlatform` is the real one).
abstract interface class NotificationPlatform {
  /// Sets up channels and action categories; [onTap] receives taps and
  /// actions while the app runs.
  Future<void> initialize(void Function(NotificationTap) onTap);

  /// The tap that launched the app, if one did.
  Future<NotificationTap?> launchTap();

  /// (id, payload) of every pending notification.
  Future<List<(int, String?)>> pending();

  Future<void> cancel(int id);

  Future<void> schedule(OsNotification n);
}
