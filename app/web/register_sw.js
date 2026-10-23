'use strict';
// Registers sw.js: reminders and web push (docs/09 M5.3). A file, not an
// inline script, so the CSP can stay script-src 'self' (06 §8).
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('sw.js').catch(() => {});
  });
}
