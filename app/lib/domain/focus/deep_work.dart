/// How "Deep work" quiets this device while a dot is in Focus (11 A3,
/// docs/09 M10.5).
enum DeepWorkKind {
  /// Android: Do Not Disturb at the alarms-only level until the dot's
  /// planned end, with notification-policy access.
  dnd,

  /// iPhone and Mac: an app can't switch Focus; a Shortcuts automation
  /// with Dottoday's Start focus does, and the app says so.
  shortcuts,

  /// The web: the browser can't; the computer's own setting.
  none,
}

/// Deep work here and now.
final class DeepWorkStatus {
  const DeepWorkStatus({
    required this.kind,
    this.granted = false,
    this.on = false,
  });

  final DeepWorkKind kind;

  /// Android: notification-policy access is allowed.
  final bool granted;

  /// Dottoday turned Do Not Disturb on and it is still on.
  final bool on;
}

/// The device's quiet mode, behind one port (`data/focus/`).
abstract interface class DeepWorkGateway {
  Future<DeepWorkStatus> status();

  /// Quiets the device until [untilUtc]; false when it can't (no access).
  /// The level is always [deepWorkDndLevel].
  Future<bool> turnOn(DateTime untilUtc);

  /// Restores what was there, if Dottoday changed it.
  Future<void> turnOff();

  /// Android: the notification-policy access screen; Apple: Shortcuts.
  Future<void> openSettings();
}

/// The only Do Not Disturb level deep work asks for: alarms only. Never
/// total silence, so the dot-start alarm channel still rings (11 A3: "a
/// deep-work dot must never silence the next dot's start").
const deepWorkDndLevel = 'alarms';
