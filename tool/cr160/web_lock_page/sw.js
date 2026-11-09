// Test worker for tool/cr160/web_queue_lock.mjs: the shipped queue code
// (app/web/action_queue.js, copied in by the runner) appending as the real
// worker does on a notification click.
importScripts('action_queue.js');
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (e) => e.waitUntil(self.clients.claim()));
self.addEventListener('message', (event) => {
  const { type, n, tag } = event.data || {};
  if (type !== 'append') return;
  event.waitUntil((async () => {
    let refused = 0;
    await Promise.all(Array.from({ length: n }, async (_, i) => {
      const ok = await self.dottodayActionQueue.append(caches, self.registration.scope, {
        id: `${tag}-${i}`, at_ms: Date.now(), kind: 'add_task', text: `${tag} ${i}`,
      });
      if (!ok) refused++;
    }));
    event.source.postMessage({ type: 'appended', refused });
  })());
});
