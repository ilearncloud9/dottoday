import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/notifications/sound/browser_sound_any.dart';
import 'package:dottoday/data/notifications/sound_files.dart';
import 'package:dottoday/domain/notifications/sound_catalogue.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Plays a bundled reminder sound once, in the app (docs/02 F6.6, M8.4d):
/// the Sound picker's preview, and on the web the in-app strip's reminder
/// (a browser notification can't carry a custom sound). Best effort: a
/// sound that can't play is logged, never thrown. One sound at a time: a
/// new [play] cuts off the one still playing, so tapping through a picker
/// never stacks previews (docs/12 §6).
abstract interface class SoundPlayer {
  Future<void> play(CatalogueSound sound);

  /// Stops the sound [play] started, if it is still playing: the pickers
  /// call it when they close.
  Future<void> stop();

  /// Whether the device's ringer is silent, so a preview won't be heard
  /// (docs/12 §6). Only Android can tell; false when unknown.
  Future<bool> deviceMuted();
}

/// The player for this build: the browser's audio on the web, the
/// `dottoday/sound` channel on iOS, Android and macOS.
SoundPlayer platformSoundPlayer(Logger logger) =>
    kIsWeb ? _BrowserSoundPlayer(logger) : ChannelSoundPlayer(logger);

/// Native playback over `dottoday/sound` (`play` with [appleSoundFile]'s
/// name): the `Library/Sounds` copy or the bundled `.caf` on Apple
/// platforms, the raw resource of the same base name on Android; both play
/// as a notification sound, so the silent switch and Do Not Disturb apply.
final class ChannelSoundPlayer implements SoundPlayer {
  ChannelSoundPlayer(
    this._logger, [
    this._channel = const MethodChannel('dottoday/sound'),
  ]);

  final Logger _logger;
  final MethodChannel _channel;

  @override
  Future<void> play(CatalogueSound sound) async {
    try {
      await _channel.invokeMethod<void>('play', appleSoundFile(sound));
    } on Object catch (e, s) {
      // MissingPluginException in tests, PlatformException on a device
      // without the file: no preview, nothing else breaks.
      _logger.warn('notifications.sound_failed', error: e, stackTrace: s);
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stop');
    } on Object catch (e, s) {
      // MissingPluginException in tests: nothing is playing anyway.
      _logger.warn('notifications.sound_failed', error: e, stackTrace: s);
    }
  }

  @override
  Future<bool> deviceMuted() async {
    try {
      return await _channel.invokeMethod<bool>('isMuted') ?? false;
    } on Object catch (e, s) {
      // MissingPluginException in tests: no banner, nothing else breaks.
      _logger.warn('notifications.sound_failed', error: e, stackTrace: s);
      return false;
    }
  }
}

final class _BrowserSoundPlayer implements SoundPlayer {
  _BrowserSoundPlayer(this._logger);

  final Logger _logger;

  @override
  Future<void> play(CatalogueSound sound) async {
    try {
      // Flutter web serves asset `x` at `assets/x`.
      await playBrowserSound('assets/${webSoundAsset(sound)}');
    } on Object catch (e, s) {
      // Autoplay rules may refuse audio before the first user gesture.
      _logger.warn('notifications.sound_failed', error: e, stackTrace: s);
    }
  }

  @override
  Future<void> stop() async => stopBrowserSound();

  /// A browser can't read the device's ringer.
  @override
  Future<bool> deviceMuted() async => false;
}
