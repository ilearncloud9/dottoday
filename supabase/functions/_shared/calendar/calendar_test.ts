// node --experimental-strip-types --test supabase/functions/_shared/calendar/calendar_test.ts
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { argbOf, plainText, writeResultOf, TokenRejected } from './api.ts';
import { googleApi, googleEvent } from './google.ts';
import { graphEvent, microsoftApi } from './microsoft.ts';
import { authorizeUrl, challengeOf, exchangeCode, ReconnectError, refresh, stillFresh } from './oauth.ts';
import { oauthClients, returnOrigins } from './env.ts';

const client = { clientId: 'cid', clientSecret: 'secret', redirectUri: 'http://sb/cb', tenant: 'common' };

function jwtOf(claims: Record<string, string>): string {
  const part = Buffer.from(JSON.stringify(claims)).toString('base64url');
  return `x.${part}.y`;
}

test('google timed and all-day events', () => {
  const timed = googleEvent({
    id: 'e1_20261024T090000Z', summary: 'Standup', etag: '"1"',
    start: { dateTime: '2026-10-24T11:00:00+02:00' }, end: { dateTime: '2026-10-24T11:15:00+02:00' },
    description: 'Notes<br>line two &amp; more',
  }, true)!;
  assert.equal(timed.start, Date.parse('2026-10-24T09:00:00Z'));
  assert.equal(timed.end - timed.start, 15 * 60_000);
  assert.equal(timed.writable, true);
  assert.equal(timed.description, 'Notes\nline two & more');
  const allDay = googleEvent({ id: 'h', start: { date: '2026-10-24' }, end: { date: '2026-10-26' } }, true)!;
  assert.deepEqual([allDay.allDay, allDay.startDate, allDay.endDate, allDay.writable], [true, '2026-10-24', '2026-10-26', false]);
  assert.equal(googleEvent({ id: 'c', status: 'cancelled', start: {}, end: {} }, true), null);
  assert.equal(googleEvent({ id: 'bad', start: { dateTime: 'nope' }, end: { dateTime: 'nope' } }, true), null);
});

test('series ids: an instance names its repeating event, a one-off none', () => {
  const at = { start: { dateTime: '2026-10-24T09:00:00Z' }, end: { dateTime: '2026-10-24T09:30:00Z' } };
  assert.equal(googleEvent({ id: 'r_20261024', recurringEventId: 'r', ...at }, true)!.seriesId, 'r');
  assert.equal(googleEvent({ id: 'once', ...at }, true)!.seriesId, undefined);
  const graphAt = { start: { dateTime: '2026-10-24T09:00:00' }, end: { dateTime: '2026-10-24T09:30:00' } };
  assert.equal(graphEvent({ id: 'occ', seriesMasterId: 'master', ...graphAt }, true)!.seriesId, 'master');
  assert.equal(graphEvent({ id: 'single', ...graphAt }, true)!.seriesId, undefined);
});

test('graph events: UTC times, organiser only, all-day dates', () => {
  const e = graphEvent({
    id: 'AAMk=', subject: 'Review', '@odata.etag': 'W/"x"', isOrganizer: true,
    start: { dateTime: '2026-10-24T09:00:00.0000000', timeZone: 'UTC' },
    end: { dateTime: '2026-10-24T10:30:00.0000000', timeZone: 'UTC' },
  }, true)!;
  assert.equal(e.start, Date.parse('2026-10-24T09:00:00Z'));
  assert.equal(e.etag, 'W/"x"');
  assert.equal(e.writable, true);
  assert.equal(graphEvent({ id: 'i', isOrganizer: false, start: { dateTime: '2026-10-24T09:00:00' }, end: { dateTime: '2026-10-24T10:00:00' } }, true)!.writable, false);
  const allDay = graphEvent({ id: 'a', isAllDay: true, start: { dateTime: '2026-10-24T00:00:00.0000000' }, end: { dateTime: '2026-10-25T00:00:00.0000000' } }, true)!;
  assert.deepEqual([allDay.startDate, allDay.endDate, allDay.writable], ['2026-10-24', '2026-10-25', false]);
  assert.equal(graphEvent({ id: 'x', isCancelled: true }, true), null);
});

test('helpers', () => {
  assert.equal(argbOf('#ff8800'), 0xffff8800);
  assert.equal(argbOf(''), null);
  assert.equal(plainText('<p>a</p><div>b</div>'), 'a\nb');
  assert.equal(plainText('<b></b>'), undefined);
  assert.equal(writeResultOf(200), 'written');
  assert.equal(writeResultOf(412), 'changed');
  assert.equal(writeResultOf(410), 'gone');
  assert.equal(writeResultOf(403), 'not_writable');
  assert.equal(writeResultOf(500), 'failed');
  assert.throws(() => writeResultOf(401), TokenRejected);
});

test('authorize URLs carry PKCE, state and the scopes', async () => {
  const challenge = await challengeOf('verifier-verifier-verifier-verifier-verifier');
  const g = new URL(authorizeUrl('google', client, 'st', challenge));
  assert.equal(g.origin, 'https://accounts.google.com');
  assert.equal(g.searchParams.get('code_challenge_method'), 'S256');
  assert.equal(g.searchParams.get('access_type'), 'offline');
  assert.match(g.searchParams.get('scope')!, /calendar\.events/);
  const m = new URL(authorizeUrl('microsoft', client, 'st', challenge));
  assert.equal(m.pathname, '/common/oauth2/v2.0/authorize');
  assert.match(m.searchParams.get('scope')!, /offline_access/);
  assert.equal(m.searchParams.get('state'), 'st');
});

test('code exchange names the account; refresh rotates or keeps the token', async () => {
  const exchange = (async () => Response.json({
    access_token: 'at', refresh_token: 'rt', expires_in: 3600,
    id_token: jwtOf({ sub: 's1', oid: 'o1', preferred_username: 'kody@example.com' }),
  })) as typeof fetch;
  const c = await exchangeCode('microsoft', client, 'code', 'v', exchange, 1000);
  assert.deepEqual([c.subject, c.label, c.tokens.expires_at], ['o1', 'kody@example.com', 1000 + 3_600_000]);
  const keep = (async () => Response.json({ access_token: 'at2', expires_in: 60 })) as typeof fetch;
  const t = await refresh('google', client, { refresh_token: 'rt' }, keep, 0);
  assert.deepEqual([t.refresh_token, t.access_token], ['rt', 'at2']);
  const revoked = (async () => Response.json({ error: 'invalid_grant' }, { status: 400 })) as typeof fetch;
  await assert.rejects(refresh('google', client, { refresh_token: 'rt' }, revoked, 0), ReconnectError);
  assert.equal(stillFresh({ refresh_token: 'r', access_token: 'a', expires_at: 100_000 }, 0), true);
  assert.equal(stillFresh({ refresh_token: 'r', access_token: 'a', expires_at: 30_000 }, 0), false);
});

test('google api pages events and sends If-Match', async () => {
  const calls: string[] = [];
  const fake = (async (url: string, init: RequestInit = {}) => {
    calls.push(`${init.method ?? 'GET'} ${url.split('?')[0]} ${(init.headers as Record<string, string>)['If-Match'] ?? ''}`.trim());
    if (url.includes('/calendarList/')) return Response.json({ id: 'c', accessRole: 'owner' });
    if (init.method === 'PATCH') return new Response(null, { status: 412 });
    const page2 = url.includes('pageToken=p2');
    return Response.json({
      items: [{ id: page2 ? 'b' : 'a', start: { dateTime: '2026-10-24T09:00:00Z' }, end: { dateTime: '2026-10-24T10:00:00Z' } }],
      nextPageToken: page2 ? undefined : 'p2',
    });
  }) as typeof fetch;
  const api = googleApi(fake);
  const events = await api.events('tok', 'c', 0, 1);
  assert.deepEqual(events.map((e) => [e.id, e.writable]), [['a', true], ['b', true]]);
  assert.equal(await api.update('tok', 'c', 'a', { start: 0, end: 1 }, '"e1"'), 'changed');
  assert.ok(calls.at(-1)!.endsWith('"e1"'));
});

test('graph api: read-only calendars and missing events', async () => {
  const fake = (async (url: string) => {
    if (url.includes('/events/')) return new Response(null, { status: 404 });
    return Response.json({ value: [{ id: 'c1', name: 'Work', hexColor: '#00aa00', canEdit: false }] });
  }) as typeof fetch;
  const api = microsoftApi(fake);
  const [cal] = await api.calendars('tok');
  assert.deepEqual([cal.readOnly, cal.colorArgb], [true, 0xff00aa00]);
  assert.equal(await api.event('tok', 'c1', 'gone'), null);
});

test('env: placeholders count as unset', () => {
  const env: Record<string, string> = {
    SUPABASE_URL: 'https://p.supabase.co',
    GOOGLE_CALENDAR_CLIENT_ID: 'id', GOOGLE_CALENDAR_CLIENT_SECRET: 's',
    MICROSOFT_CALENDAR_CLIENT_ID: 'placeholder-x', MICROSOFT_CALENDAR_CLIENT_SECRET: 's',
    CALENDAR_RETURN_ORIGINS: 'https://app.example, http://localhost:8099',
  };
  const clients = oauthClients((k) => env[k]);
  assert.equal(clients('google')!.redirectUri, 'https://p.supabase.co/functions/v1/calendar-oauth/callback');
  assert.equal(clients('microsoft'), null);
  assert.deepEqual(returnOrigins((k) => env[k]), ['https://app.example', 'http://localhost:8099']);
});
