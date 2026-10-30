import 'dart:async';

import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/data/notifications/sound/sound_player.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'in_app_alerts.g.dart';

/// Reminders shown inside the app instead of by the OS: on the web without
/// notification permission, and quiet-hours ones (docs/07 Web, M5.3).
/// Newest last; the banner shows it until acted on or dismissed.
@Riverpod(keepAlive: true)
class InAppAlerts extends _$InAppAlerts {
  @override
  List<OsNotification> build() => const [];

  void add(OsNotification n) => state = [
    for (final o in state)
      if (o.id != n.id) o,
    n,
  ];

  void dismiss(int id) => state = [
    for (final o in state)
      if (o.id != id) o,
  ];
}

/// Shows [n] in the in-app strip and plays its picked sound (docs/02
/// F6.6, M8.4d): a browser notification can't carry a custom sound, so on
/// the web the strip does. Quiet hours stay quiet; no picked sound plays
/// nothing.
void deliverInApp(
  OsNotification n, {
  required void Function(OsNotification n) add,
  required SoundPlayer player,
}) {
  add(n);
  if (n.sound case final sound? when !n.silent && !n.soundOff) {
    unawaited(player.play(sound));
  }
}
