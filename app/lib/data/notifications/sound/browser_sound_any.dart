// Picks the browser audio binding on the web and the stub elsewhere.
export 'browser_sound_stub.dart'
    if (dart.library.js_interop) 'browser_sound.dart';
