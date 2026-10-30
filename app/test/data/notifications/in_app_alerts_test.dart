import 'package:dottoday/data/notifications/in_app_alerts.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/data/notifications/sound/sound_player.dart';
import 'package:dottoday/domain/notifications/sound_catalogue.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:flutter_test/flutter_test.dart';

final class _Player implements SoundPlayer {
  final played = <CatalogueSound>[];

  @override
  Future<void> play(CatalogueSound sound) async => played.add(sound);
}

OsNotification _n({
  String? sound,
  bool silent = false,
  bool soundOff = false,
}) => OsNotification(
  id: 1,
  title: 'Gym',
  body: 'Starts in 10 minutes',
  fireAtUtc: DateTime.utc(2026, 10, 24, 9),
  payload: '{}',
  channel: NotificationChannelKind.alerts,
  silent: silent,
  sound: sound == null ? null : resolveSound(sound),
  soundOff: soundOff,
);

// The web's in-app strip plays the picked sound (docs/02 F6.6, M8.4d).
void main() {
  test('shows the reminder and plays its sound once', () {
    final shown = <OsNotification>[];
    final player = _Player();
    final n = _n(sound: 'bell');
    deliverInApp(n, add: shown.add, player: player);
    expect(shown, [n]);
    expect(player.played, [resolveSound('bell')]);
  });

  test('quiet hours and the system sound stay silent', () {
    final shown = <OsNotification>[];
    final player = _Player();
    deliverInApp(
      _n(sound: 'bell', silent: true),
      add: shown.add,
      player: player,
    );
    deliverInApp(_n(), add: shown.add, player: player);
    // docs/12 §3: "None" shows and stays silent.
    deliverInApp(_n(soundOff: true), add: shown.add, player: player);
    expect(shown, hasLength(3));
    expect(player.played, isEmpty);
  });
}
