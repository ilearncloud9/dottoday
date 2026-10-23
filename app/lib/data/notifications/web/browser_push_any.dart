// Picks the browser push bindings on the web and the stub elsewhere.
export 'browser_push_stub.dart'
    if (dart.library.js_interop) 'browser_push.dart';
