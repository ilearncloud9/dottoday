// The Supabase calls delete-account makes (CR-160 W2), each turned into a
// small answer the deletion can act on. Everything that can't be told
// apart for certain comes back as 'unknown' / 'unreachable', never as a
// guess in either direction.

/** Where and how to call: the project URL and its service-role key. */
export interface Calls {
  url: string;
  /** The service-role key: only in this function, never in a client. */
  serviceKey: string;
  fetch: typeof fetch;
  /** How long one Auth Admin deletion may take before its outcome counts
   * as unknown (default 30 s). */
  adminTimeoutMs?: number;
}

export type Rpc =
  | { kind: 'ok'; data: any }
  | { kind: 'error'; code: string | null }
  | { kind: 'unreachable' };

const service = (c: Calls) => ({
  apikey: c.serviceKey,
  Authorization: `Bearer ${c.serviceKey}`,
  'Content-Type': 'application/json',
});

/** A database function, as the service role. */
export async function rpc(c: Calls, fn: string, args: Record<string, unknown>): Promise<Rpc> {
  let r: Response;
  try {
    r = await c.fetch(`${c.url}/rest/v1/rpc/${fn}`, {
      method: 'POST',
      headers: service(c),
      body: JSON.stringify(args),
    });
  } catch (_) {
    return { kind: 'unreachable' };
  }
  const data = await r.json().catch(() => null);
  if (r.ok) return { kind: 'ok', data };
  return { kind: 'error', code: typeof data?.code === 'string' ? data.code : null };
}

/** The live deletion attempt of [id]: its id, null when not frozen,
 * undefined when it couldn't be read. */
export async function deletionAttempt(id: string, c: Calls): Promise<string | null | undefined> {
  try {
    const r = await c.fetch(
      `${c.url}/rest/v1/account_revisions?select=deletion_attempt&user_id=eq.${encodeURIComponent(id)}`,
      { headers: service(c) },
    );
    if (!r.ok) return undefined;
    const rows = (await r.json()) as { deletion_attempt: string | null }[];
    return rows[0]?.deletion_attempt ?? null;
  } catch (_) {
    return undefined;
  }
}

export type SessionUser =
  | { kind: 'user'; id: string; email: string | null }
  | { kind: 'gone' }
  | { kind: 'invalid' }
  | { kind: 'unavailable' };

/** Who the session belongs to. A session the gateway let through (verify_jwt:
 * signature and expiry checked) whose user no longer exists is 'gone': a
 * retry after a deletion whose answer was lost. */
export async function sessionUser(jwt: string, c: Calls): Promise<SessionUser> {
  let r: Response;
  try {
    r = await c.fetch(`${c.url}/auth/v1/user`, {
      headers: { apikey: c.serviceKey, Authorization: `Bearer ${jwt}` },
    });
  } catch (_) {
    return { kind: 'unavailable' };
  }
  if (r.ok) {
    const u = (await r.json().catch(() => null)) as { id?: unknown; email?: unknown } | null;
    if (typeof u?.id !== 'string') return { kind: 'invalid' };
    return { kind: 'user', id: u.id, email: typeof u.email === 'string' ? u.email : null };
  }
  if (r.status >= 500) return { kind: 'unavailable' };
  const sub = subject(jwt);
  if (!sub) return { kind: 'invalid' };
  switch (await adminUserState(sub, c)) {
    case 'absent': return { kind: 'gone' };
    case 'unknown': return { kind: 'unavailable' };
    case 'present': return { kind: 'invalid' };
  }
}

const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;

/** The `sub` of a JWT the gateway already verified; null if it has none. */
export function subject(jwt: string): string | null {
  const part = jwt.split('.')[1];
  if (!part) return null;
  try {
    const json = atob(part.replace(/-/g, '+').replace(/_/g, '/').padEnd(Math.ceil(part.length / 4) * 4, '='));
    const sub = (JSON.parse(json) as { sub?: unknown }).sub;
    return typeof sub === 'string' && uuid.test(sub) ? sub : null;
  } catch (_) {
    return null;
  }
}

/** Whether Auth still has user [id]. */
export async function adminUserState(id: string, c: Calls): Promise<'present' | 'absent' | 'unknown'> {
  try {
    const r = await c.fetch(`${c.url}/auth/v1/admin/users/${id}`, { headers: service(c) });
    if (r.ok) return 'present';
    if (r.status === 404) return 'absent';
    return 'unknown';
  } catch (_) {
    return 'unknown';
  }
}

// The only answers that prove this request ended without deleting: Auth
// (GoTrue v2.197) rejects it before its deletion transaction starts, and
// says so with a specific error code. Verified in GoTrue's source (the
// admin-credentials middleware: no_authorization, bad_jwt, not_admin; the
// handler's body parsing: bad_json; the body limit: request_entity_too_large;
// every error inside the transaction is a 500) and against the local Auth.
// A status alone proves nothing: a 4xx without one of these codes (a gateway,
// a proxy, another Auth version, 405/422/429) stays 'unknown', and so does
// every 5xx (a failed commit is a 500 too).
const preTransactionRefusals: Record<number, readonly string[]> = {
  400: ['bad_json'],
  401: ['no_authorization'],
  403: ['bad_jwt', 'not_admin'],
  413: ['request_entity_too_large'],
};

/** GoTrue's error code from either of its error formats. */
function authErrorCode(body: unknown): string | null {
  if (typeof body !== 'object' || body === null) return null;
  const b = body as { error_code?: unknown; code?: unknown };
  if (typeof b.error_code === 'string') return b.error_code; // initial format
  if (typeof b.code === 'string') return b.code; // X-Supabase-Api-Version 2024-01-01
  return null;
}

export type AdminDelete = 'deleted' | 'absent' | 'refused' | 'unknown';

/** One Auth Admin hard deletion of [id], classified conservatively. */
export async function adminDeleteUser(id: string, c: Calls): Promise<AdminDelete> {
  let r: Response;
  try {
    r = await c.fetch(`${c.url}/auth/v1/admin/users/${id}`, {
      method: 'DELETE',
      headers: service(c),
      body: JSON.stringify({ should_soft_delete: false }),
      signal: AbortSignal.timeout(c.adminTimeoutMs ?? 30_000),
    });
  } catch (_) {
    return 'unknown'; // timeout, lost connection: it may have run
  }
  if (r.status >= 200 && r.status < 300) {
    await r.body?.cancel().catch(() => undefined);
    return 'deleted';
  }
  if (r.status === 404) {
    await r.body?.cancel().catch(() => undefined);
    return 'absent'; // the caller confirms the user really is gone
  }
  const code = authErrorCode(await r.json().catch(() => null));
  return code !== null && preTransactionRefusals[r.status]?.includes(code) ? 'refused' : 'unknown';
}
