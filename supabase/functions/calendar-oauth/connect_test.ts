// node --experimental-strip-types --test supabase/functions/calendar-oauth/connect_test.ts
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { allowedReturn, appReturn, callback, start } from './connect.ts';
import type { Deps } from './connect.ts';

interface Fake {
  deps: Deps;
  calls: string[];
  bodies: Record<string, unknown>[];
}

function fake(opts: { state?: Record<string, string> | null; exchange?: number; configured?: boolean } = {}): Fake {
  const calls: string[] = [];
  const bodies: Record<string, unknown>[] = [];
  const send = (async (url: string, init: RequestInit = {}) => {
    const key = `${init.method ?? 'GET'} ${url.split('?')[0]}`;
    calls.push(key);
    if (typeof init.body === 'string') bodies.push(JSON.parse(init.body));
    if (url.endsWith('/auth/v1/user')) {
      const ok = (init.headers as Record<string, string>).Authorization === 'Bearer good';
      return ok ? Response.json({ id: 'u1' }) : new Response(null, { status: 401 });
    }
    if (url.endsWith('/rpc/calendar_oauth_take_state')) {
      return Response.json(opts.state === null ? [] : [opts.state ?? {
        user_id: 'u1', provider: 'google', code_verifier: 'v'.repeat(43), return_to: appReturn,
      }]);
    }
    if (url.endsWith('/rpc/calendar_account_connect')) return Response.json('acc-1');
    if (url.startsWith('https://oauth2.googleapis.com/token')) {
      const claims = Buffer.from(JSON.stringify({ sub: 'g1', email: 'kody@example.com' })).toString('base64url');
      return Response.json(
        { access_token: 'at', refresh_token: 'rt', expires_in: 3600, id_token: `h.${claims}.s` },
        { status: opts.exchange ?? 200 },
      );
    }
    return new Response(null, { status: 201 });
  }) as typeof fetch;
  const logs: string[] = [];
  return {
    calls,
    bodies,
    deps: {
      db: { url: 'http://sb', serviceKey: 'service', fetch: send },
      client: () => (opts.configured === false ? null : { clientId: 'cid', clientSecret: 's', redirectUri: 'http://sb/cb' }),
      returnOrigins: ['http://localhost:8099'],
      now: () => 0,
      log: (e) => logs.push(e),
    },
  };
}

test('return URLs: the app page or an allowed web origin only', () => {
  const origins = ['http://localhost:8099'];
  assert.equal(allowedReturn(appReturn, origins), true);
  assert.equal(allowedReturn('http://localhost:8099/#/settings/calendars', origins), true);
  assert.equal(allowedReturn('https://evil.example/', origins), false);
  assert.equal(allowedReturn('dottoday://task/1', origins), false);
  assert.equal(allowedReturn('javascript:alert(1)', origins), false);
  assert.equal(allowedReturn(42, origins), false);
});

test('start: needs a session, a provider, an allowed return and a client', async () => {
  const f = fake();
  assert.equal((await start(null, {}, f.deps)).status, 401);
  assert.equal((await start('good', { provider: 'yahoo', returnTo: appReturn }, f.deps)).status, 400);
  assert.equal((await start('good', { provider: 'google', returnTo: 'https://evil.example' }, f.deps)).status, 400);
  assert.equal((await start('good', { provider: 'google', returnTo: appReturn }, fake({ configured: false }).deps)).status, 503);
});

test('start: stores the state and its verifier, returns the sign-in URL', async () => {
  const f = fake();
  const out = await start('good', { provider: 'google', returnTo: appReturn }, f.deps);
  assert.equal(out.status, 200);
  const url = new URL((out as { body: { url: string } }).body.url);
  const stored = f.bodies.find((b) => 'code_verifier' in b)!;
  assert.equal(stored.user_id, 'u1');
  assert.equal(stored.state, url.searchParams.get('state'));
  assert.notEqual(stored.code_verifier, url.searchParams.get('code_challenge'));
});

test('callback: exchanges the code, stores the token, goes back', async () => {
  const f = fake();
  const out = await callback(new URLSearchParams({ state: 's'.repeat(40), code: 'c' }), f.deps);
  assert.deepEqual(out, { status: 302, location: appReturn });
  const connect = f.bodies.find((b) => 'p_token' in b)!;
  assert.deepEqual([connect.p_user, connect.p_external, connect.p_label], ['u1', 'g1', 'kody@example.com']);
  assert.equal(JSON.parse(connect.p_token as string).refresh_token, 'rt');
});

test('callback: unknown state stops; a refused or failed exchange stores nothing', async () => {
  const unknown = await callback(new URLSearchParams({ state: 's'.repeat(40), code: 'c' }), fake({ state: null }).deps);
  assert.equal(unknown.status, 400);
  const short = fake();
  assert.equal((await callback(new URLSearchParams({ state: 'x', code: 'c' }), short.deps)).status, 400);
  assert.deepEqual(short.calls, []);
  const denied = fake();
  const back = await callback(new URLSearchParams({ state: 's'.repeat(40), error: 'access_denied' }), denied.deps);
  assert.equal(back.status, 302);
  assert.ok(!denied.calls.some((c) => c.includes('account_connect')));
  const failed = fake({ exchange: 400 });
  assert.equal((await callback(new URLSearchParams({ state: 's'.repeat(40), code: 'c' }), failed.deps)).status, 302);
  assert.ok(!failed.calls.some((c) => c.includes('account_connect')));
});
