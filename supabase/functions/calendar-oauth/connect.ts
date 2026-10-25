// calendar-oauth (docs/09 M7.4, 06 §1): connects a Google or Microsoft
// calendar. Without Deno so node can test it; index.ts wires it up.
//
// 1. The app POSTs {provider, returnTo} with its session → the provider's
//    sign-in URL (state + PKCE kept server side for 10 minutes).
// 2. The provider sends the browser to GET …/callback?code&state → the code
//    is exchanged here, the refresh token goes to Vault, and the browser goes
//    back to `returnTo` (the app's Calendars page).
import { authorizeUrl, challengeOf, exchangeCode, randomToken } from '../_shared/calendar/oauth.ts';
import type { OAuthClient } from '../_shared/calendar/oauth.ts';
import { callerId, connectAccount, putState, takeState } from '../_shared/calendar/store.ts';
import type { Db, Provider } from '../_shared/calendar/store.ts';

/** Where the apps come back to (allow-listed, docs/06 §7). */
export const appReturn = 'dottoday://settings/calendars';

export interface Deps {
  db: Db;
  /** The provider's OAuth client, or null when it isn't set up. */
  client: (p: Provider) => OAuthClient | null;
  /** Web origins the browser may be sent back to (CALENDAR_RETURN_ORIGINS). */
  returnOrigins: string[];
  now: () => number;
  log: (event: string, fields?: Record<string, unknown>) => void;
}

export type Outcome =
  | { status: 200; body: { url: string } }
  | { status: 400 | 401 | 405 | 503; body: { error: string } }
  | { status: 302; location: string }
  | { status: 400; text: string };

/** Whether the browser may be sent to [url] after connecting. */
export function allowedReturn(url: unknown, origins: string[]): url is string {
  if (typeof url !== 'string' || url.length > 512) return false;
  if (url === appReturn) return true;
  try {
    const u = new URL(url);
    return (u.protocol === 'https:' || u.protocol === 'http:') && origins.includes(u.origin);
  } catch {
    return false;
  }
}

const isProvider = (p: unknown): p is Provider => p === 'google' || p === 'microsoft';

/** Step 1: the sign-in URL for the caller behind [jwt]. */
export async function start(jwt: string | null, body: unknown, deps: Deps): Promise<Outcome> {
  const user = await callerId(deps.db, jwt);
  if (!user) return { status: 401, body: { error: 'no session' } };
  const { provider, returnTo } = (body ?? {}) as { provider?: unknown; returnTo?: unknown };
  if (!isProvider(provider)) return { status: 400, body: { error: 'provider' } };
  if (!allowedReturn(returnTo, deps.returnOrigins)) return { status: 400, body: { error: 'returnTo' } };
  const client = deps.client(provider);
  if (!client) return { status: 503, body: { error: 'not_configured' } };
  const state = randomToken(32);
  const verifier = randomToken(48);
  await putState(deps.db, state, { user_id: user, provider, code_verifier: verifier, return_to: returnTo });
  return { status: 200, body: { url: authorizeUrl(provider, client, state, await challengeOf(verifier)) } };
}

/**
 * Step 2: the provider's redirect. Always ends on the app's page when the
 * state is known (connected or not: the page shows which); an unknown or
 * expired state gets a plain message, since there is nowhere safe to go.
 */
export async function callback(params: URLSearchParams, deps: Deps): Promise<Outcome> {
  const raw = params.get('state') ?? '';
  const state = raw.length >= 32 && raw.length <= 128 ? await takeState(deps.db, raw) : null;
  if (!state) return { status: 400, text: 'This link has expired. Go back to Dottoday and try again.' };
  const back: Outcome = { status: 302, location: state.return_to };
  const code = params.get('code');
  const client = deps.client(state.provider);
  if (!code || !client) {
    // Cancelled at the provider (`error=access_denied`) or not set up.
    deps.log('calendar_oauth.not_connected', { provider: state.provider, reason: params.get('error') ?? 'no_code' });
    return back;
  }
  try {
    const connected = await exchangeCode(state.provider, client, code, state.code_verifier, deps.db.fetch, deps.now());
    await connectAccount(deps.db, { user: state.user_id, provider: state.provider, ...connected });
    deps.log('calendar_oauth.connected', { provider: state.provider });
  } catch (e) {
    // Status codes only: never a token or an address in a log.
    deps.log('calendar_oauth.failed', { provider: state.provider, error: String((e as Error).message).slice(0, 80) });
  }
  return back;
}
