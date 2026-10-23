'use strict';
// Dottoday's service worker (docs/07 Web, docs/09 M5.3): shows reminders,
// routes taps on them back to the app, and receives web push.
// Payloads carry IDs only (06 §1); text arrives encrypted end to end.

let queued = [];

self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => event.waitUntil(self.clients.claim()));

// A tap or an action button: focus the app (or open it) and tell it.
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const data = event.notification.data || {};
  const message = {
    type: 'dottoday-notification',
    action: event.action || 'open',
    id: data.id ?? null,
    payload: data.payload ?? null,
  };
  event.waitUntil((async () => {
    const windows = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
    if (windows.length > 0) {
      await windows[0].focus();
      windows[0].postMessage(message);
      return;
    }
    // Delivered when the opened page says it is listening.
    queued.push(message);
    await self.clients.openWindow('./');
  })());
});

self.addEventListener('message', (event) => {
  if (!event.data || event.data.type !== 'dottoday-ready' || !event.source) return;
  for (const message of queued) event.source.postMessage(message);
  queued = [];
});

// Web push (signed in): the browser has already decrypted the payload the
// app encrypted for this subscription; the server only saw ciphertext.
self.addEventListener('push', (event) => {
  if (!event.data) return;
  let n;
  try {
    n = event.data.json();
  } catch (_) {
    return;
  }
  if (!n || typeof n.title !== 'string') return;
  event.waitUntil(self.registration.showNotification(n.title, {
    body: n.body || '',
    tag: String(n.id),
    silent: n.silent === true,
    icon: 'icons/Icon-192.png',
    data: { id: n.id, payload: n.payload },
    actions: Array.isArray(n.actions) ? n.actions : [],
  }));
});
