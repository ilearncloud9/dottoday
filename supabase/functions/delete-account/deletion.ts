// The account deletion of 06 §6 / PRD F7 (docs/09 M6.5), without Deno so it
// can be tested with node. index.ts wires it to the request.

/** What the function needs from its surroundings. */
export interface Deps {
  /** The project URL (SUPABASE_URL). */
  url: string;
  /** The service-role key: only in this function, never in a client. */
  serviceKey: string;
  fetch: typeof fetch;
  /** Sends the confirmation, or null when no mail provider is set up. */
  sendMail: ((to: string) => Promise<void>) | null;
}

export type Outcome =
  | { status: 200; body: { deleted: true; mailed: boolean } }
  | { status: 401 | 500; body: { error: string } };

/**
 * Deletes the caller's account: the user behind [jwt] (their own session,
 * never an id from the body), then every row they own goes with it
 * (`profiles` references `auth.users` on delete cascade, everything else
 * references `profiles`). Then the confirmation mail, if one is set up; a
 * failed mail never undoes the deletion.
 */
export async function deleteAccount(jwt: string | null, deps: Deps): Promise<Outcome> {
  if (!jwt) return { status: 401, body: { error: 'no session' } };
  const me = await deps.fetch(`${deps.url}/auth/v1/user`, {
    headers: { apikey: deps.serviceKey, Authorization: `Bearer ${jwt}` },
  });
  if (!me.ok) return { status: 401, body: { error: 'session not valid' } };
  const user = (await me.json()) as { id?: string; email?: string };
  if (!user.id) return { status: 401, body: { error: 'session not valid' } };

  const gone = await deps.fetch(`${deps.url}/auth/v1/admin/users/${user.id}`, {
    method: 'DELETE',
    headers: { apikey: deps.serviceKey, Authorization: `Bearer ${deps.serviceKey}` },
  });
  if (!gone.ok) return { status: 500, body: { error: 'could not delete' } };

  let mailed = false;
  if (deps.sendMail && user.email) {
    try {
      await deps.sendMail(user.email);
      mailed = true;
    } catch (_) {
      // Logged by the caller's platform; the account is gone either way.
    }
  }
  return { status: 200, body: { deleted: true, mailed } };
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
