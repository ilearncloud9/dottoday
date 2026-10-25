// The browser's audio element for reminder sounds (M8.4d). Hand-written
// `dart:js_interop` bindings, like browser_notifications.dart, so the app
// takes no `package:web` dependency.
import 'dart:js_interop';

@JS('Audio')
extension type _Audio._(JSObject _) implements JSObject {
  external factory _Audio(String url);
  external JSPromise<JSAny?> play();
}

/// Plays the same-origin sound at [url] once; throws when the browser
/// refuses (autoplay before a gesture, a missing file).
Future<void> playBrowserSound(String url) async {
  await _Audio(url).play().toDart;
}
