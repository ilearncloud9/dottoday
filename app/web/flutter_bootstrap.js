{{flutter_js}}
{{flutter_build_config}}

// No serviceWorkerSettings: Flutter's own worker is deprecated and
// unregisters itself, which would take Dottoday's sw.js (same scope) with
// it. sw.js is registered by index.html (docs/09 M5.3).
_flutter.loader.load();
