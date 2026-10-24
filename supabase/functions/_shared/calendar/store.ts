// Database access for the calendar functions (docs/09 M7.4): PostgREST with
// the service-role key, always filtered by the caller's own user id (06 §3).
// Tokens only through the Vault functions of migration 0005.

/** What the functions need to reach the database. */
export interface Db {
  /** The project URL (SUPABASE_URL). */
  url: string;
  /** The service-role key: only in Edge Functions, never in a client. */
  serviceKey: string;
  fetch: typeof fetch;
}

export type Provider = 'google' | 'microsoft';

/** A connected Google/Microsoft account (`calendar_accounts`). */
export interface Account {
  id: string;
  provider: Provider;
  label: string;
}

/** What Vault holds per account: JSON, never logged. */
export interface TokenSet {
  refresh_token: string;
  access_token?: string;
  /** Epoch ms the access token stops working. */
  expires_at?: number;
}

/** A connect in progress (`calendar_oauth_states`). */
export interface OAuthState {
  user_id: string;
  provider: Provider;
  code_verifier: string;
  return_to: string;
}

function headers(db: Db): Record<string, string> {
  return {
    apikey: db.serviceKey,
    Authorization: `Bearer ${db.serviceKey}`,
    'Content-Type': 'application/json',
  };
}

async function rpc(db: Db, fn: string, args: Record<string, unknown>): Promise<unknown> {
  const r = await db.fetch(`${db.url}/rest/v1/rpc/${fn}`, {
    method: 'POST',
    headers: headers(db),
    body: JSON.stringify(args),
  });
  if (!r.ok) throw new Error(`rpc ${fn}: ${r.status}`);
  return r.status === 204 ? null : await r.json();
}

/** The user behind [jwt] (their own session, never an id from a body). */
export async function callerId(db: Db, jwt: string | null): Promise<string | null> {
  if (!jwt) return null;
  const me = await db.fetch(`${db.url}/auth/v1/user`, {
    headers: { apikey: db.serviceKey, Authorization: `Bearer ${jwt}` },
  });
  if (!me.ok) return null;
  const user = (await me.json()) as { id?: string };
  return typeof user.id === 'string' ? user.id : null;
}

export async function putState(db: Db, state: string, row: OAuthState): Promise<void> {
  const r = await db.fetch(`${db.url}/rest/v1/calendar_oauth_states`, {
    method: 'POST',
    headers: { ...headers(db), Prefer: 'return=minimal' },
    body: JSON.stringify({ state, ...row }),
  });
  if (!r.ok) throw new Error(`state: ${r.status}`);
}

/** Takes [state] once; null when unknown or expired. */
export async function takeState(db: Db, state: string): Promise<OAuthState | null> {
  const rows = (await rpc(db, 'calendar_oauth_take_state', { p_state: state })) as OAuthState[];
  return rows[0] ?? null;
}

/** Connects (or reconnects) an account with its tokens; its row id. */
export async function connectAccount(
  db: Db,
  args: { user: string; provider: Provider; subject: string; label: string; tokens: TokenSet },
): Promise<string> {
  return (await rpc(db, 'calendar_account_connect', {
    p_user: args.user,
    p_provider: args.provider,
    p_external: args.subject,
    p_label: args.label,
    p_token: JSON.stringify(args.tokens),
  })) as string;
}

export async function getTokens(db: Db, account: string): Promise<TokenSet | null> {
  const raw = (await rpc(db, 'calendar_token_get', { p_account: account })) as string | null;
  if (!raw) return null;
  const parsed = JSON.parse(raw) as TokenSet;
  return typeof parsed.refresh_token === 'string' ? parsed : null;
}

export async function putTokens(db: Db, account: string, tokens: TokenSet): Promise<void> {
  await rpc(db, 'calendar_token_put', { p_account: account, p_token: JSON.stringify(tokens) });
}

/** [user]'s connected accounts, oldest first; only [id] when given. */
export async function accountsOf(db: Db, user: string, id?: string): Promise<Account[]> {
  const filter = id ? `&id=eq.${encodeURIComponent(id)}` : '';
  const r = await db.fetch(
    `${db.url}/rest/v1/calendar_accounts?select=id,provider,label` +
      `&user_id=eq.${encodeURIComponent(user)}&provider=in.(google,microsoft)${filter}` +
      '&order=created_at',
    { headers: headers(db) },
  );
  if (!r.ok) throw new Error(`accounts: ${r.status}`);
  return (await r.json()) as Account[];
}

/** Deletes [user]'s account [id]; its Vault token goes with it (trigger). */
export async function deleteAccount(db: Db, user: string, id: string): Promise<void> {
  const r = await db.fetch(
    `${db.url}/rest/v1/calendar_accounts?id=eq.${encodeURIComponent(id)}` +
      `&user_id=eq.${encodeURIComponent(user)}`,
    { method: 'DELETE', headers: headers(db) },
  );
  if (!r.ok) throw new Error(`disconnect: ${r.status}`);
}
