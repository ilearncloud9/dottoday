// The browser's audio element for reminder sounds (M8.4d). Hand-written
// `dart:js_interop` bindings, like browser_notifications.dart, so the app
// takes no `package:web` dependency.
import 'dart:js_interop';

@JS('Audio')
extension type _Audio._(JSObject _) implements JSObject {
  external factory _Audio(String url);
  external JSPromise<JSAny?> play();
  external void pause();
}

/// The sound still playing, if any: a new one or [stopBrowserSound] pauses it.
_Audio? _current;

/// Plays the same-origin sound at [url] once, cutting off the one before;
/// throws when the browser refuses (autoplay before a gesture, a missing
/// file).
Future<void> playBrowserSound(String url) async {
  stopBrowserSound();
  final audio = _current = _Audio(url);
  await audio.play().toDart;
}

/// Pauses the sound [playBrowserSound] started; an ended one ignores it.
void stopBrowserSound() {
  _current?.pause();
  _current = null;
}
