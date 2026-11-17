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
  // Whom entries are stamped with, as the app publishes it (CR-160 I7;
  // lib/domain/intents/action_queue_store.dart encodeQueueOwner).
  const OWNER_PATH = '__snapshot/queue_owner.json';
  // The Web Lock the app's remove and publish take too
  // (lib/data/snapshot/web/snapshot_store_web.dart withQueueLock).
  const LOCK = 'dottoday-action-queue';
  // Most entries and bytes; past either a new entry is refused, never an
  // older one evicted (queueCapacity in action_queue_store.dart).
  const CAPACITY = 500;
  const MAX_BYTES = 1000000;

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
    // Smallest step's Start (M10.6): the app opens Focus when it drains.
    if (action === 'start') return { ...base, kind: 'start_focus' };
    if (action === 'plus15') {
      const block = ((snapshot && snapshot.blocks) || []).find((b) => b.id === occurrenceId);
      if (!block || typeof block.end_ms !== 'number') return null;
      return { ...base, kind: 'add_fifteen', planned_end_ms: block.end_ms };
    }
    return null;
  }

  async function read(caches, base) {
    return (await stored(caches, base)) || [];
  }

  // The stored array; [] when there is none, null when it can't be read
  // (then nothing is written over it, CR-160 I7).
  async function stored(caches, base) {
    const cache = await caches.open(CACHE);
    const hit = await cache.match(new URL(PATH, base).href);
    if (!hit) return [];
    try {
      const list = await hit.json();
      return Array.isArray(list) ? list : null;
    } catch (_) {
      return null;
    }
  }

  // [entry] with the owner [marker] names (its id and guest session), or
  // as it is while a change of owner is under way or before the app
  // published one: the app then keeps it and never applies it.
  function stamp(entry, marker) {
    if (!marker || marker.switching === true || marker.refuse === true ||
        typeof marker.owner !== 'string' || !marker.owner) {
      return entry;
    }
    const out = { ...entry, owner: marker.owner };
    if (typeof marker.guest_session === 'string') out.guest_session = marker.guest_session;
    return out;
  }

  async function readOwner(caches, base) {
    const cache = await caches.open(CACHE);
    const hit = await cache.match(new URL(OWNER_PATH, base).href);
    if (!hit) return null;
    try { return await hit.json(); } catch (_) { return null; }
  }

  function locked(body) {
    const locks = scope.navigator && scope.navigator.locks;
    return locks ? locks.request(LOCK, body) : body();
  }

  // Appends [entry], stamped with the published owner, under the queue's
  // lock, so the app's read-then-write never overwrites it. Resolves false,
  // queuing nothing, while the app refuses (an account being deleted), when
  // the queue is full or can't be read: the caller opens the app instead.
  function append(caches, base, entry) {
    return locked(async () => {
      const marker = await readOwner(caches, base);
      if (marker && marker.refuse === true) return false;
      const list = await stored(caches, base);
      if (!list || list.length >= CAPACITY) return false;
      list.push(stamp(entry, marker));
      const body = JSON.stringify(list);
      if (body.length > MAX_BYTES) return false;
      const cache = await caches.open(CACHE);
      await cache.put(new URL(PATH, base).href, new Response(body, {
        headers: { 'content-type': 'application/json' },
      }));
      return true;
    });
  }

  scope.dottodayActionQueue = { uuidV7, fromNotification, read, append, stamp };
})(self);
