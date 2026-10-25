'use strict';
// The B6 action queue on the web (docs/09 M9.2d), loaded by sw.js. When a
// reminder's Done (or +15, M9.7) is pressed and no Dottoday tab is open,
// the worker queues the action in Cache Storage instead of opening a tab;
// the next tab drains it through the app's write path
// (lib/data/intents/web_action_queue_store.dart: same cache and path,
// entries as lib/domain/intents/dot_action.dart reads them). IDs only.
(function (scope) {
  const CACHE = 'dottoday-day-snapshot';
  const PATH = '__snapshot/actions.json';

  // RFC 9562 UUID v7: 48-bit Unix ms, version 7, variant 10, random rest.
  function uuidV7(nowMs, random) {
    const bytes = random || crypto.getRandomValues(new Uint8Array(16));
    let ms = BigInt(Math.max(0, Math.floor(nowMs)));
    for (let i = 5; i >= 0; i--) { bytes[i] = Number(ms & 0xffn); ms >>= 8n; }
    bytes[6] = (bytes[6] & 0x0f) | 0x70;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    const hex = Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('');
    return [hex.slice(0, 8), hex.slice(8, 12), hex.slice(12, 16), hex.slice(16, 20), hex.slice(20)].join('-');
  }

  // The queue entry for notification [action] on the reminder whose payload
  // is [payload] (notification_payload.dart: `o` is the occurrence id), or
  // null when the action isn't one the worker can do alone. +15 needs the
  // end the snapshot shows, so the app applies it only while it still holds.
  function fromNotification(action, payload, snapshot, nowMs, random) {
    let occurrenceId;
    try { occurrenceId = JSON.parse(payload || '{}').o; } catch (_) { return null; }
    if (typeof occurrenceId !== 'string' || occurrenceId === '') return null;
    const base = { id: uuidV7(nowMs, random), at_ms: nowMs, occurrence_id: occurrenceId.toLowerCase() };
    if (action === 'done') return { ...base, kind: 'mark_done' };
    if (action === 'plus15') {
      const block = ((snapshot && snapshot.blocks) || []).find((b) => b.id === occurrenceId);
      if (!block || typeof block.end_ms !== 'number') return null;
      return { ...base, kind: 'add_fifteen', planned_end_ms: block.end_ms };
    }
    return null;
  }

  async function read(caches, base) {
    const cache = await caches.open(CACHE);
    const hit = await cache.match(new URL(PATH, base).href);
    if (!hit) return [];
    try {
      const list = await hit.json();
      return Array.isArray(list) ? list : [];
    } catch (_) {
      return [];
    }
  }

  async function append(caches, base, entry) {
    const list = await read(caches, base);
    list.push(entry);
    const cache = await caches.open(CACHE);
    await cache.put(new URL(PATH, base).href, new Response(JSON.stringify(list), {
      headers: { 'content-type': 'application/json' },
    }));
  }

  scope.dottodayActionQueue = { uuidV7, fromNotification, read, append };
})(self);
