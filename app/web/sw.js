'use strict';
// Dottoday's service worker (docs/07 Web, docs/09 M5.3, M5.7): keeps the
// app working offline, shows reminders, routes taps on them back to the
// app, and receives web push.
// Payloads carry IDs only (06 §1); text arrives encrypted end to end.

let queued = [];

// Offline (docs/07 Web, docs/09 M5.7): the app is local-first, so once its
// files are cached it opens and works without a network. Same-origin GETs
// go to the network first (always fresh when online) and are cached as
// they come; offline they come from the cache, and a page with nothing
// cached yet gets offline.html.
const SHELL = 'dottoday-shell-v1';
const OFFLINE = 'offline.html';

self.addEventListener('install', (event) => {
  event.waitUntil(caches.open(SHELL).then((c) => c.addAll([OFFLINE, 'offline.css'])).then(() => self.skipWaiting()));
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    for (const name of await caches.keys()) {
      if (name.startsWith('dottoday-') && name !== SHELL) await caches.delete(name);
    }
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  const url = new URL(request.url);
  if (request.method !== 'GET' || url.origin !== self.location.origin) return;
  if (request.headers.has('range')) return;
  event.respondWith((async () => {
    const cache = await caches.open(SHELL);
    try {
      const response = await fetch(request);
      if (response.ok && response.type === 'basic') {
        await cache.put(request, response.clone());
      }
      return response;
    } catch (_) {
      const cached = await cache.match(request, { ignoreSearch: request.mode === 'navigate' });
      if (cached) return cached;
      if (request.mode === 'navigate') {
        return (await cache.match('./')) || (await cache.match(OFFLINE));
      }
      return Response.error();
    }
  })());
});

// The files a first visit loaded before this worker existed (see
// register_sw.js). Same-origin only; one that fails is skipped.
self.addEventListener('message', (event) => {
  if (!event.data || event.data.type !== 'dottoday-cache') return;
  const urls = (event.data.urls || []).filter((u) => new URL(u, self.location.href).origin === self.location.origin);
  event.waitUntil((async () => {
    const cache = await caches.open(SHELL);
    await Promise.all(urls.map(async (u) => {
      if (await cache.match(u)) return;
      try {
        const response = await fetch(u);
        if (response.ok && response.type === 'basic') await cache.put(u, response);
      } catch (_) { /* offline already: nothing to add */ }
    }));
  })());
});

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
