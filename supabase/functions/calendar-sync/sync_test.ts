// node --experimental-strip-types --test supabase/functions/calendar-sync/sync_test.ts
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { handle } from './sync.ts';
import type { Deps } from './sync.ts';
import { TokenRejected } from '../_shared/calendar/api.ts';
import type { CalendarApi, EventInfo } from '../_shared/calendar/api.ts';

const acc = '0192f000-0000-7000-8000-000000000001';

interface World {
  tokens: { refresh_token: string; access_token?: string; expires_at?: number } | null;
  refresh: number;
  stored: string[];
  deleted: string[];
  accounts: { id: string; provider: string; label: string }[];
}

const event: EventInfo = { id: 'e1', title: 'T', start: 1, end: 2, allDay: false, etag: '"1"', writable: true };

function setup(api: Partial<CalendarApi>, world: Partial<World> = {}): [Deps, World] {
  const w: World = {
    tokens: { refresh_token: 'rt', access_token: 'at', expires_at: 10_000_000 },
    refresh: 200,
    stored: [],
    deleted: [],
    accounts: [{ id: acc, provider: 'google', label: 'kody@example.com' }],
    ...world,
  };
  const send = (async (url: string, init: RequestInit = {}) => {
    if (url.endsWith('/auth/v1/user')) {
      const ok = (init.headers as Record<string, string>).Authorization === 'Bearer good';
      return ok ? Response.json({ id: 'u1' }) : new Response(null, { status: 401 });
    }
    if (url.includes('/rest/v1/calendar_accounts')) {
      if (init.method === 'DELETE') {
        w.deleted.push(url);
        return new Response(null, { status: 204 });
      }
      assert.ok(url.includes('user_id=eq.u1'), 'always filtered by the caller');
      const id = /[?&]id=eq\.([^&]+)/.exec(url)?.[1];
      return Response.json(w.accounts.filter((a) => !id || a.id === decodeURIComponent(id)));
    }
    if (url.endsWith('/rpc/calendar_token_get')) return Response.json(w.tokens ? JSON.stringify(w.tokens) : null);
    if (url.endsWith('/rpc/calendar_token_put')) {
      w.stored.push(JSON.parse(String(init.body)).p_token);
      return new Response(null, { status: 204 });
    }
    if (url.startsWith('https://oauth2.googleapis.com/token')) {
      return w.refresh === 200
        ? Response.json({ access_token: 'fresh', expires_in: 3600 })
        : Response.json({ error: 'invalid_grant' }, { status: 400 });
    }
    return new Response(null, { status: 200 });
  }) as typeof fetch;
  const full: CalendarApi = {
    calendars: async () => [],
    events: async () => [],
    event: async () => null,
    update: async () => 'written',
    ...api,
  };
  return [
    {
      db: { url: 'http://sb', serviceKey: 'service', fetch: send },
      client: () => ({ clientId: 'c', clientSecret: 's', redirectUri: 'http://sb/cb' }),
      api: () => full,
      now: () => 0,
      log: () => {},
    },
    w,
  ];
}

test('no session, unknown action', async () => {
  const [d] = setup({});
  assert.equal((await handle(null, { action: 'calendars' }, d)).status, 401);
  assert.equal((await handle('good', { action: 'drop' }, d)).status, 400);
});

test('calendars: ids carry their account; a revoked account says reconnect', async () => {
  const [d] = setup({ calendars: async () => [{ id: 'primary', name: 'Kody', colorArgb: null, readOnly: false }] });
  const out = await handle('good', { action: 'calendars' }, d);
  const [account] = out.body.accounts as { status: string; calendars: { id: string }[] }[];
  assert.equal(account.status, 'ok');
  assert.equal(account.calendars[0].id, `${acc}/primary`);
  const [revoked] = setup({}, { tokens: { refresh_token: 'rt' }, refresh: 400 });
  const r = await handle('good', { action: 'calendars' }, revoked);
  assert.equal((r.body.accounts as { status: string }[])[0].status, 'reconnect');
});

test('events: window and calendar checked against the caller', async () => {
  let asked: unknown[] = [];
  const [d] = setup({ events: async (_t, cal, from, to) => { asked = [cal, from, to]; return [event]; } });
  const ok = await handle('good', { action: 'events', calendarId: `${acc}/primary`, from: 1000, to: 2000 }, d);
  assert.deepEqual([ok.status, asked], [200, ['primary', 1000, 2000]]);
  assert.equal((await handle('good', { action: 'events', calendarId: `${acc}/primary`, from: 1, to: 1 + 101 * 86_400_000 }, d)).status, 400);
  const other = '0192f000-0000-7000-8000-000000000009';
  assert.equal((await handle('good', { action: 'events', calendarId: `${other}/primary`, from: 1, to: 2 }, d)).status, 404);
  assert.equal((await handle('good', { action: 'events', calendarId: 'primary', from: 1, to: 2 }, d)).status, 404);
});

test('an expired access token is refreshed and stored first', async () => {
  let token = '';
  const [d, w] = setup({ event: async (t) => { token = t; return event; } }, { tokens: { refresh_token: 'rt' } });
  const out = await handle('good', { action: 'event', calendarId: `${acc}/c`, eventId: 'e1' }, d);
  assert.deepEqual([out.status, token], [200, 'fresh']);
  assert.equal(JSON.parse(w.stored[0]).access_token, 'fresh');
});

test('a rejected token is refreshed once, then it is reconnect', async () => {
  let calls = 0;
  const [d] = setup({ event: async () => { calls++; throw new TokenRejected(); } });
  const out = await handle('good', { action: 'event', calendarId: `${acc}/c`, eventId: 'e1' }, d);
  assert.deepEqual([out.status, out.body.error, calls], [409, 'reconnect', 2]);
});

test('update: validated, passes the etag, returns the result', async () => {
  let seen: unknown[] = [];
  const [d] = setup({ update: async (_t, cal, id, patch, etag) => { seen = [cal, id, patch, etag]; return 'changed'; } });
  const call = { action: 'update', calendarId: `${acc}/c`, eventId: 'e1', start: 10, end: 20, etag: '"7"' };
  const out = await handle('good', call, d);
  assert.deepEqual([out.body.result, seen], ['changed', ['c', 'e1', { start: 10, end: 20 }, '"7"']]);
  assert.equal((await handle('good', { ...call, end: 5 }, d)).status, 400);
  assert.equal((await handle('good', { ...call, title: 'x'.repeat(201) }, d)).status, 400);
  assert.equal((await handle('good', { ...call, etag: undefined }, d)).status, 400);
});

test('disconnect deletes only the caller\'s account', async () => {
  const [d, w] = setup({});
  const out = await handle('good', { action: 'disconnect', accountId: acc }, d);
  assert.equal(out.status, 200);
  assert.equal(w.deleted.length, 1);
  assert.ok(w.deleted[0].includes('user_id=eq.u1'));
  assert.equal((await handle('good', { action: 'disconnect', accountId: 'nope' }, d)).status, 400);
});

test('provider failures are a 502 without details', async () => {
  const [d] = setup({ events: async () => { throw new Error('events: 500'); } });
  const out = await handle('good', { action: 'events', calendarId: `${acc}/c`, from: 1, to: 2 }, d);
  assert.deepEqual([out.status, out.body], [502, { error: 'provider' }]);
});
