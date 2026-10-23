{{flutter_js}}
{{flutter_build_config}}

// No serviceWorkerSettings: Flutter's own worker is deprecated and
// unregisters itself, which would take Dottoday's sw.js (same scope) with
// it. sw.js is registered by index.html (docs/09 M5.3).
// CanvasKit from this site, not Google's CDN, so the CSP can keep
// script-src 'self' (06 §8, docs/09 M5.7).
_flutter.loader.load({ config: { canvasKitBaseUrl: 'canvaskit/' } });
