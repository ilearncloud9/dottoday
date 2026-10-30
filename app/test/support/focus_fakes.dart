import 'package:dottoday/data/focus/focus_providers.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/notifications/sound/sound_player.dart';
import 'package:dottoday/domain/focus/deep_work.dart';
import 'package:dottoday/domain/notifications/sound_catalogue.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// A device's quiet mode, recorded.
final class FakeDeepWork implements DeepWorkGateway {
  FakeDeepWork({this.kind = DeepWorkKind.dnd, this.granted = true});

  final DeepWorkKind kind;
  bool granted;
  bool on = false;
  DateTime? until;
  var settingsOpened = 0;

  @override
  Future<DeepWorkStatus> status() async =>
      DeepWorkStatus(kind: kind, granted: granted, on: on);

  @override
  Future<bool> turnOn(DateTime untilUtc) async {
    if (!granted) return false;
    on = true;
    until = untilUtc;
    return true;
  }

  @override
  Future<void> turnOff() async => on = false;

  @override
  Future<void> openSettings() async => settingsOpened++;
}

/// Sounds played, in order.
final class FakeSoundPlayer implements SoundPlayer {
  final played = <CatalogueSound>[];

  @override
  Future<void> play(CatalogueSound sound) async => played.add(sound);
}

/// The chime setting in memory.
final class FakeFocusChime extends FocusChime {
  FakeFocusChime([this._on = false]);

  bool _on;

  @override
  Future<bool> build() async => _on;

  @override
  Future<void> set({required bool on}) async {
    _on = on;
    state = AsyncData(on);
  }
}

/// Focus's device-side providers, faked.
List<Override> focusOverrides({
  required FakeDeepWork deepWork,
  required FakeSoundPlayer sounds,
  bool chime = false,
}) => [
  deepWorkGatewayProvider.overrideWithValue(deepWork),
  soundPlayerProvider.overrideWithValue(sounds),
  focusChimeProvider.overrideWith(() => FakeFocusChime(chime)),
];
