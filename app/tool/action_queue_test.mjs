// web/action_queue.js, the service worker's half of the B6 queue
// (docs/09 M9.2d). Run: node --test app/tool/action_queue_test.mjs
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import vm from 'node:vm';

globalThis.self = globalThis;
vm.runInThisContext(readFileSync(new URL('../web/action_queue.js', import.meta.url), 'utf8'));
const q = globalThis.dottodayActionQueue;

const occurrence = '01928c3e-0000-7000-8000-0000000000b1';
const payload = JSON.stringify({ o: occurrence.toUpperCase(), p: 'start' });
const now = Date.UTC(2026, 9, 21, 12);
const fixed = () => new Uint8Array(16).fill(0xab);

test('uuidV7 is lowercase version 7 and carries the time', () => {
  const id = q.uuidV7(now, fixed());
  assert.match(id, /^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/);
  assert.equal(parseInt(id.replace(/-/g, '').slice(0, 12), 16), now);
});

test('Done queues mark_done with the lowercase occurrence id', () => {
  const entry = q.fromNotification('done', payload, null, now, fixed());
  assert.equal(entry.kind, 'mark_done');
  assert.equal(entry.occurrence_id, occurrence);
  assert.equal(entry.at_ms, now);
});

test('+15 carries the end the snapshot shows; unknown dots queue nothing', () => {
  const snapshot = { blocks: [{ id: occurrence, end_ms: now + 600000 }] };
  const plus = q.fromNotification('plus15', JSON.stringify({ o: occurrence }), snapshot, now, fixed());
  assert.equal(plus.kind, 'add_fifteen');
  assert.equal(plus.planned_end_ms, now + 600000);
  assert.equal(q.fromNotification('plus15', payload, { blocks: [] }, now), null);
});

test("Smallest step's Start queues start_focus (the app opens Focus)", () => {
  const entry = q.fromNotification('start', payload, null, now, fixed());
  assert.equal(entry.kind, 'start_focus');
  assert.equal(entry.occurrence_id, occurrence);
});

test('open, snooze and broken payloads are not queued', () => {
  assert.equal(q.fromNotification('open', payload, null, now), null);
  assert.equal(q.fromNotification('snooze', payload, null, now), null);
  assert.equal(q.fromNotification('done', '{not json', null, now), null);
  assert.equal(q.fromNotification('done', '{}', null, now), null);
});

test('append keeps what is already queued', async () => {
  const store = new Map();
  const caches = {
    open: async () => ({
      match: async (url) => (store.has(url) ? new Response(store.get(url)) : undefined),
      put: async (url, response) => store.set(url, await response.text()),
    }),
  };
  const base = 'https://dottoday.app/';
  await q.append(caches, base, { id: 'a' });
  await q.append(caches, base, { id: 'b' });
  assert.deepEqual((await q.read(caches, base)).map((e) => e.id), ['a', 'b']);
});
