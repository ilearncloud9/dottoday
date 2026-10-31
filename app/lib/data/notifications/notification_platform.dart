import 'package:dottoday/domain/notifications/reminder_sound.dart';
import 'package:dottoday/domain/notifications/sound_catalogue.dart';

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
    this.startAction = false,
    this.sound,
    this.soundOff = false,
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

  /// Rings like an alarm: the day's first dot or a routine start (11 A0),
  /// with the Start [sound] (docs/12 D2; `dot_alarm` when null). Android
  /// posts on that sound's alarm channel.
  final bool loud;

  /// Done / Snooze / Open (task alerts); Wind Down has none.
  final bool withActions;

  /// Smallest step (M10.6): the one Start button instead of the task's.
  final bool startAction;

  /// The bundled sound (docs/12); null plays the system sound. With
  /// [loud], the Start sound.
  final CatalogueSound? sound;

  /// The task's sound is "None" (docs/12 §3): it shows and vibrates, with
  /// no sound.
  final bool soundOff;
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

  /// Catalogue sound ids whose OS channel the user muted (Android; empty
  /// where sounds have no channel), for the health panel (docs/12 §4).
  Future<Set<String>> mutedSoundIds();
}
