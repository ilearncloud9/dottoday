// The OAuth code flow for Google and Microsoft calendars (docs/09 M7.4,
// 06 §1): authorize URL with PKCE, code exchange and refresh. Client ids and
// secrets are function secrets (supabase/functions/.env locally); the app
// never sees them or any provider token.
import type { Provider, TokenSet } from './store.ts';

/** One provider's OAuth client (from the function's environment). */
export interface OAuthClient {
  clientId: string;
  clientSecret: string;
  /** The calendar-oauth callback registered at the provider. */
  redirectUri: string;
  /** Microsoft only: `common` (work, school and personal accounts). */
  tenant?: string;
}

/** Thrown when an account must be connected again (revoked, expired). */
export class ReconnectError extends Error {
  constructor() {
    super('reconnect');
  }
}

/**
 * What each provider is asked for. Google: list calendars, read and change
 * events. Microsoft: read and change calendars, plus a refresh token.
 */
export const scopes: Record<Provider, string[]> = {
  google: [
    'openid',
    'email',
    'https://www.googleapis.com/auth/calendar.calendarlist.readonly',
    'https://www.googleapis.com/auth/calendar.events',
  ],
  microsoft: ['openid', 'email', 'offline_access', 'Calendars.ReadWrite'],
};

const googleAuth = 'https://accounts.google.com/o/oauth2/v2/auth';
const googleToken = 'https://oauth2.googleapis.com/token';
const msBase = (tenant = 'common') => `https://login.microsoftonline.com/${tenant}/oauth2/v2.0`;

/** Random bytes as base64url (state, PKCE verifier). */
export function randomToken(bytes: number): string {
  return base64url(crypto.getRandomValues(new Uint8Array(bytes)));
}

/** The S256 PKCE challenge of [verifier]. */
export async function challengeOf(verifier: string): Promise<string> {
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(verifier));
  return base64url(new Uint8Array(digest));
}

function base64url(bytes: Uint8Array): string {
  let s = '';
  for (const b of bytes) s += String.fromCharCode(b);
  return btoa(s).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

/** Where the browser goes to let Dottoday read [provider]'s calendars. */
export function authorizeUrl(
  provider: Provider,
  client: OAuthClient,
  state: string,
  challenge: string,
): string {
  const params = new URLSearchParams({
    client_id: client.clientId,
    redirect_uri: client.redirectUri,
    response_type: 'code',
    scope: scopes[provider].join(' '),
    state,
    code_challenge: challenge,
    code_challenge_method: 'S256',
  });
  if (provider === 'google') {
    // A refresh token every time, so reconnecting always works.
    params.set('access_type', 'offline');
    params.set('prompt', 'consent');
  } else {
    params.set('response_mode', 'query');
    params.set('prompt', 'select_account');
  }
  const base = provider === 'google' ? googleAuth : `${msBase(client.tenant)}/authorize`;
  return `${base}?${params}`;
}

function tokenUrl(provider: Provider, client: OAuthClient): string {
  return provider === 'google' ? googleToken : `${msBase(client.tenant)}/token`;
}

interface TokenResponse {
  access_token?: string;
  refresh_token?: string;
  expires_in?: number;
  id_token?: string;
  error?: string;
}

async function postToken(
  provider: Provider,
  client: OAuthClient,
  form: Record<string, string>,
  send: typeof fetch,
): Promise<{ status: number; body: TokenResponse }> {
  const r = await send(tokenUrl(provider, client), {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      client_id: client.clientId,
      client_secret: client.clientSecret,
      ...form,
    }),
  });
  return { status: r.status, body: (await r.json().catch(() => ({}))) as TokenResponse };
}

/** Who connected: a stable id for the account and a label (its email). */
export interface Connected {
  tokens: TokenSet;
  subject: string;
  label: string;
}

/** Exchanges the callback's [code]; throws on any failure. */
export async function exchangeCode(
  provider: Provider,
  client: OAuthClient,
  code: string,
  verifier: string,
  send: typeof fetch,
  now: number,
): Promise<Connected> {
  const { status, body } = await postToken(provider, client, {
    grant_type: 'authorization_code',
    code,
    code_verifier: verifier,
    redirect_uri: client.redirectUri,
    ...(provider === 'microsoft' ? { scope: scopes.microsoft.join(' ') } : {}),
  }, send);
  if (status !== 200 || !body.refresh_token || !body.access_token || !body.id_token) {
    throw new Error(`exchange: ${status} ${body.error ?? ''}`.trim());
  }
  const claims = idClaims(body.id_token);
  // Microsoft's `oid` is the same for every app; `sub` is per app.
  const subject = claims.oid ?? claims.sub;
  if (!subject) throw new Error('exchange: no subject');
  return {
    tokens: {
      refresh_token: body.refresh_token,
      access_token: body.access_token,
      expires_at: now + (body.expires_in ?? 0) * 1000,
    },
    subject,
    label: (claims.email ?? claims.preferred_username ?? provider).slice(0, 80),
  };
}

/**
 * The id token's claims. Not verified: it came straight from the provider's
 * token endpoint over TLS (OpenID Connect Core §3.1.3.7), and only names
 * the account; it grants nothing.
 */
function idClaims(idToken: string): Record<string, string | undefined> {
  const part = idToken.split('.')[1] ?? '';
  const json = atob(part.replace(/-/g, '+').replace(/_/g, '/'));
  return JSON.parse(new TextDecoder().decode(Uint8Array.from(json, (c) => c.charCodeAt(0))));
}

/**
 * Fresh tokens for [tokens]. Microsoft rotates the refresh token, Google
 * keeps it. A revoked or expired grant is a [ReconnectError].
 */
export async function refresh(
  provider: Provider,
  client: OAuthClient,
  tokens: TokenSet,
  send: typeof fetch,
  now: number,
): Promise<TokenSet> {
  const { status, body } = await postToken(provider, client, {
    grant_type: 'refresh_token',
    refresh_token: tokens.refresh_token,
    ...(provider === 'microsoft' ? { scope: scopes.microsoft.join(' ') } : {}),
  }, send);
  if (body.error === 'invalid_grant' || status === 401) throw new ReconnectError();
  if (status !== 200 || !body.access_token) throw new Error(`refresh: ${status}`);
  return {
    refresh_token: body.refresh_token ?? tokens.refresh_token,
    access_token: body.access_token,
    expires_at: now + (body.expires_in ?? 0) * 1000,
  };
}

/** Whether [tokens]' access token still has a minute left at [now]. */
export function stillFresh(tokens: TokenSet, now: number): boolean {
  return !!tokens.access_token && (tokens.expires_at ?? 0) - 60_000 > now;
}

/** Google lets an app give its grant back; Microsoft has no such call. */
export async function revoke(provider: Provider, tokens: TokenSet, send: typeof fetch): Promise<void> {
  if (provider !== 'google') return;
  await send('https://oauth2.googleapis.com/revoke', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ token: tokens.refresh_token }),
  });
}
