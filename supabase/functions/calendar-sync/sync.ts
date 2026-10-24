// calendar-sync (docs/09 M7.4, 04 §7, ADR-0011): the app's window onto its
// connected Google/Microsoft calendars. Read on request and handed back,
// never stored here. Without Deno so node can test it; index.ts wires it.
//
// POST {action, ...} with the caller's session:
//   calendars                         → each account with its calendars
//   events     {calendarId, from, to} → the events of one calendar
//   event      {calendarId, eventId}  → one event now (write-back's read)
//   update     {calendarId, eventId, start, end, title?, etag} → result
//   disconnect {accountId}            → the account and its token are gone
// A calendar id is `<account id>/<provider calendar id>`, so every call is
// checked against the caller's own accounts.
import { TokenRejected } from '../_shared/calendar/api.ts';
import type { CalendarApi } from '../_shared/calendar/api.ts';
import { ReconnectError, refresh, revoke, stillFresh } from '../_shared/calendar/oauth.ts';
import type { OAuthClient } from '../_shared/calendar/oauth.ts';
import { accountsOf, callerId, deleteAccount, getTokens, putTokens } from '../_shared/calendar/store.ts';
import type { Account, Db, Provider } from '../_shared/calendar/store.ts';

export interface Deps {
  db: Db;
  client: (p: Provider) => OAuthClient | null;
  api: (p: Provider) => CalendarApi;
  now: () => number;
  log: (event: string, fields?: Record<string, unknown>) => void;
}

export interface Outcome {
  status: number;
  body: Record<string, unknown>;
}

/** The widest window one read may ask for (the app asks for 91 days). */
const maxWindowMs = 100 * 86_400_000;
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;

const bad = (error: string): Outcome => ({ status: 400, body: { error } });
const str = (v: unknown, max: number): v is string => typeof v === 'string' && v.length > 0 && v.length <= max;
const ms = (v: unknown): v is number => Number.isSafeInteger(v) && (v as number) > 0;

/** Answers one call of the caller behind [jwt]. */
export async function handle(jwt: string | null, body: unknown, deps: Deps): Promise<Outcome> {
  const user = await callerId(deps.db, jwt);
  if (!user) return { status: 401, body: { error: 'no session' } };
  const call = (body ?? {}) as Record<string, unknown>;
  try {
    switch (call.action) {
      case 'calendars':
        return { status: 200, body: { accounts: await calendars(user, deps) } };
      case 'events':
        return await events(user, call, deps);
      case 'event':
        return await event(user, call, deps);
      case 'update':
        return await update(user, call, deps);
      case 'disconnect':
        return await disconnect(user, call, deps);
      default:
        return bad('action');
    }
  } catch (e) {
    if (e instanceof ReconnectError) return { status: 409, body: { error: 'reconnect' } };
    deps.log('calendar_sync.failed', { action: String(call.action), error: String((e as Error).message).slice(0, 80) });
    return { status: 502, body: { error: 'provider' } };
  }
}

/** Every account with its calendars, or why they couldn't be listed. */
async function calendars(user: string, deps: Deps) {
  const out = [];
  for (const account of await accountsOf(deps.db, user)) {
    try {
      const list = await withToken(account, deps, (api, token) => api.calendars(token));
      out.push({
        ...account,
        status: 'ok',
        calendars: list.map((c) => ({ ...c, id: `${account.id}/${c.id}` })),
      });
    } catch (e) {
      const status = e instanceof ReconnectError ? 'reconnect' : 'failed';
      if (status === 'failed') deps.log('calendar_sync.list_failed', { provider: account.provider });
      out.push({ ...account, status, calendars: [] });
    }
  }
  return out;
}

/** The caller's account and the provider's id of `<account>/<calendar>`. */
async function calendarOf(user: string, id: unknown, deps: Deps): Promise<[Account, string] | null> {
  if (!str(id, 256)) return null;
  const slash = id.indexOf('/');
  const accountId = id.slice(0, slash);
  const calendarId = id.slice(slash + 1);
  if (slash < 0 || !uuid.test(accountId) || !calendarId) return null;
  const [account] = await accountsOf(deps.db, user, accountId);
  return account ? [account, calendarId] : null;
}

async function events(user: string, call: Record<string, unknown>, deps: Deps): Promise<Outcome> {
  const { from, to } = call;
  if (!ms(from) || !ms(to) || to <= from || to - from > maxWindowMs) return bad('window');
  const found = await calendarOf(user, call.calendarId, deps);
  if (!found) return { status: 404, body: { error: 'calendar' } };
  const [account, calendarId] = found;
  const list = await withToken(account, deps, (api, token) => api.events(token, calendarId, from, to));
  return { status: 200, body: { events: list } };
}

async function event(user: string, call: Record<string, unknown>, deps: Deps): Promise<Outcome> {
  const found = await calendarOf(user, call.calendarId, deps);
  if (!found) return { status: 404, body: { error: 'calendar' } };
  if (!str(call.eventId, 512)) return bad('eventId');
  const [account, calendarId] = found;
  const eventId = call.eventId;
  const info = await withToken(account, deps, (api, token) => api.event(token, calendarId, eventId));
  return { status: 200, body: { event: info } };
}

async function update(user: string, call: Record<string, unknown>, deps: Deps): Promise<Outcome> {
  const { start, end, title, etag, eventId } = call;
  if (!ms(start) || !ms(end) || end <= start) return bad('times');
  if (title !== undefined && title !== null && !str(title, 200)) return bad('title');
  if (!str(etag, 256) || !str(eventId, 512)) return bad('event');
  const found = await calendarOf(user, call.calendarId, deps);
  if (!found) return { status: 404, body: { error: 'calendar' } };
  const [account, calendarId] = found;
  const patch = { start, end, ...(typeof title === 'string' ? { title } : {}) };
  const result = await withToken(account, deps, (api, token) =>
    api.update(token, calendarId, eventId, patch, etag));
  return { status: 200, body: { result } };
}

async function disconnect(user: string, call: Record<string, unknown>, deps: Deps): Promise<Outcome> {
  if (!str(call.accountId, 36) || !uuid.test(call.accountId)) return bad('accountId');
  const [account] = await accountsOf(deps.db, user, call.accountId);
  if (!account) return { status: 200, body: { disconnected: true } };
  const tokens = await getTokens(deps.db, account.id);
  // Give the grant back where the provider allows it; never blocks.
  if (tokens) await revoke(account.provider, tokens, deps.db.fetch).catch(() => {});
  await deleteAccount(deps.db, user, account.id);
  deps.log('calendar_sync.disconnected', { provider: account.provider });
  return { status: 200, body: { disconnected: true } };
}

/**
 * Runs [work] with a fresh access token for [account]: refreshed (and the
 * rotated tokens stored) when it is about to expire, and once more when the
 * provider rejects it anyway. No token, or a refused refresh → reconnect.
 */
async function withToken<T>(
  account: Account,
  deps: Deps,
  work: (api: CalendarApi, token: string) => Promise<T>,
): Promise<T> {
  const client = deps.client(account.provider);
  let tokens = await getTokens(deps.db, account.id);
  if (!client || !tokens) throw new ReconnectError();
  const api = deps.api(account.provider);
  for (let attempt = 0; ; attempt++) {
    if (attempt > 0 || !stillFresh(tokens, deps.now())) {
      tokens = await refresh(account.provider, client, tokens, deps.db.fetch, deps.now());
      await putTokens(deps.db, account.id, tokens);
    }
    try {
      return await work(api, tokens.access_token!);
    } catch (e) {
      if (!(e instanceof TokenRejected) || attempt > 0) throw e instanceof TokenRejected ? new ReconnectError() : e;
    }
  }
}
