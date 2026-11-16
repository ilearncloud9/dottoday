// The account deletion of 06 §6 / PRD F7 (docs/09 M6.5) under the CR-160 W2
// contract (migration 0015): the account is deleted only at the revision
// its export was made at, frozen first, and every Auth Admin call is
// recorded before it is made, so an outcome that isn't known for certain
// keeps the account frozen instead of being guessed. Without Deno so node
// can test it; index.ts wires it to the request.
import { adminDeleteUser, adminUserState, deletionAttempt, rpc, sessionUser } from './supabase_calls.ts';
import type { Calls } from './supabase_calls.ts';

/** What the function needs from its surroundings. */
export interface Deps extends Calls {
  /** Sends the confirmation, or null when no mail provider is set up. */
  sendMail: ((to: string) => Promise<void>) | null;
}

export type Outcome = { status: number; body: Record<string, unknown> };

/** What the caller asked for: a deletion at a revision, or to cancel one. */
export type Ask = { kind: 'delete'; expected: number } | { kind: 'cancel' };

const out = (status: number, body: Record<string, unknown>): Outcome => ({ status, body });
// An app too old to send the revision its export was made at: never an
// unverified deletion (CR-160 W2).
const updateRequired = out(400, { error: 'update_required' });
const session = out(401, { error: 'session not valid' });
const changed = out(409, { error: 'changed' });
// Nothing frozen: try again.
const busy = out(503, { error: 'busy', retry: true });
// Frozen with an outcome not yet known: retrying the same revision finishes it.
const pending = out(503, { error: 'pending', retry: true });
const couldNot = out(500, { error: 'could_not_delete' });
// A retry after a success whose answer was lost: done, no second mail.
const already = out(200, { deleted: true, already: true, mailed: false });

/** The request body, or null when it doesn't carry a usable revision. */
export function readAsk(body: unknown): Ask | null {
  if (typeof body !== 'object' || body === null || Array.isArray(body)) return null;
  const b = body as Record<string, unknown>;
  if (b.action === 'cancel') return { kind: 'cancel' };
  if (b.action !== undefined) return null;
  const e = b.expected_revision;
  if (typeof e !== 'number' || !Number.isSafeInteger(e) || e < 0) return null;
  return { kind: 'delete', expected: e };
}

/**
 * Handles one `delete-account` request for the user behind [jwt] (their own
 * session, never an id from the body).
 */
export async function deleteAccount(jwt: string | null, body: unknown, deps: Deps): Promise<Outcome> {
  if (!jwt) return session;
  const ask = readAsk(body);
  if (!ask) return updateRequired;
  const who = await sessionUser(jwt, deps);
  if (who.kind === 'gone') return already;
  if (who.kind === 'unavailable') return busy;
  if (who.kind === 'invalid') return session;
  return ask.kind === 'cancel'
    ? cancel(who.id, deps)
    : remove(who.id, who.email, ask.expected, deps);
}

/** Freeze at [expected], record the call, then the Auth Admin deletion. */
async function remove(id: string, email: string | null, expected: number, d: Deps): Promise<Outcome> {
  const begun = await rpc(d, 'begin_account_deletion', { p_user: id, p_expected: expected });
  if (begun.kind === 'unreachable') return busy;
  if (begun.kind === 'error') return begun.code === '55P03' ? busy : couldNot;
  const row = Array.isArray(begun.data) ? begun.data[0] : null;
  switch (row?.outcome) {
    case 'changed': return changed;
    case 'pending': return pending;
    case 'gone': return already;
    case 'frozen': break;
    default: return couldNot;
  }
  const attempt = row.attempt as string;

  // Durably recorded before the call is made. If this answer is lost the
  // record may still have committed: unresolved, so the account stays frozen.
  const noted = await rpc(d, 'note_account_deletion_call', { p_user: id, p_attempt: attempt });
  if (noted.kind !== 'ok') return pending;
  if (noted.data !== true) {
    // The attempt ended meanwhile: cancelled (review again) or deleted.
    return (await adminUserState(id, d)) === 'absent' ? already : changed;
  }

  switch (await adminDeleteUser(id, d)) {
    case 'deleted': return out(200, { deleted: true, mailed: await mail(email, d) });
    case 'absent':
      // "Not found": an earlier call deleted it, if the user really is gone.
      return (await adminUserState(id, d)) === 'absent' ? already : pending;
    case 'unknown': return pending;
    case 'refused': return resolveRefusal(id, attempt, d);
  }
}

/** This call was definitely refused: resolve it, then end the freeze only if
 * no other call of the attempt is unresolved. */
async function resolveRefusal(id: string, attempt: string, d: Deps): Promise<Outcome> {
  const resolved = await rpc(d, 'note_account_deletion_refused', { p_user: id, p_attempt: attempt });
  if (resolved.kind !== 'ok' || resolved.data !== true) return pending;
  const released = await rpc(d, 'release_account_deletion', { p_user: id, p_attempt: attempt });
  if (released.kind !== 'ok') return pending;
  if (released.data === 'released') return out(500, { error: 'not_deleted' });
  if (released.data === 'gone') return already;
  return pending;
}

/** The person kept their account: ends a freeze none of whose Auth Admin
 * calls is unresolved. A freeze with an unknown call stays. */
async function cancel(id: string, d: Deps): Promise<Outcome> {
  const attempt = await deletionAttempt(id, d);
  if (attempt === undefined) return busy;
  if (attempt === null) return out(200, { released: false, frozen: false });
  const released = await rpc(d, 'release_account_deletion', { p_user: id, p_attempt: attempt });
  if (released.kind !== 'ok') return busy;
  switch (released.data) {
    case 'released': return out(200, { released: true });
    case 'not_frozen': return out(200, { released: false, frozen: false });
    case 'gone': return already;
    // An unresolved call, or a new attempt since the read: stays frozen.
    default: return out(409, { error: 'pending' });
  }
}

/** Sends the confirmation once, after this request's own Auth deletion. */
async function mail(email: string | null, d: Deps): Promise<boolean> {
  if (!d.sendMail || !email) return false;
  try {
    await d.sendMail(email);
    return true;
  } catch (_) {
    // Logged by the caller's platform; the account is gone either way.
    return false;
  }
}

/** The confirmation through Resend's HTTP API (owner's key, M6.5). */
export function resendMailer(apiKey: string, from: string, send: typeof fetch) {
  return async (to: string): Promise<void> => {
    const r = await send('https://api.resend.com/emails', {
      method: 'POST',
      headers: { Authorization: `Bearer ${apiKey}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        from,
        to,
        subject: 'Your Dottoday account is deleted',
        text:
          'Your Dottoday account and everything synced to it have been deleted. ' +
          'Tasks still on your devices stay there until you remove the app.',
      }),
    });
    if (!r.ok) throw new Error(`mail ${r.status}`);
  };
}
