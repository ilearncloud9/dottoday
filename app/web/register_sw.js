'use strict';
// Registers sw.js: reminders, web push and offline (docs/09 M5.3, M5.7). A
// file, not an inline script, so the CSP can stay script-src 'self' (06 §8).
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('sw.js').catch(() => {});
    // A first visit loads everything before the worker exists, so nothing
    // passed through it to be cached (found by CI, M5.7). Once the app is
    // drawn, hand the worker what this page loaded so the next visit
    // opens offline.
    navigator.serviceWorker.ready.then(async (registration) => {
      while (!document.querySelector('flutter-view, flt-glass-pane')) {
        await new Promise((r) => setTimeout(r, 500));
      }
      const urls = performance.getEntriesByType('resource')
        .map((e) => e.name)
        .filter((u) => new URL(u).origin === location.origin);
      registration.active?.postMessage({ type: 'dottoday-cache', urls: ['./', ...urls] });
    }).catch(() => {});
  });
}
