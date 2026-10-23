// Picks the browser bindings on the web and the stub elsewhere.
export 'browser_notifications_stub.dart'
    if (dart.library.js_interop) 'browser_notifications.dart';
