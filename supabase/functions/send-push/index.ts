// send-push (docs/09 M5.3b, 07 Web): delivers due web-push reminders.
// Called every minute by pg_cron with the service-role key (owner's deploy:
// supabase/snippets/send_push_cron.sql). Bodies are encrypted in the browser;
// this function never sees reminder text (06 §1).
import { deliver, fromPgBytea } from './push.ts';
import type { DuePush, Outcome, Vapid } from './push.ts';

const url = Deno.env.get('SUPABASE_URL')!;
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const vapid: Vapid = {
  publicKey: Deno.env.get('VAPID_PUBLIC_KEY') ?? '',
  privateKey: Deno.env.get('VAPID_PRIVATE_KEY') ?? '',
  subject: Deno.env.get('VAPID_SUBJECT') ?? '',
};

/** Older than this, a reminder is dropped unsent. */
const staleMs = 60 * 60 * 1000;

function rest(path: string, init: RequestInit = {}): Promise<Response> {
  return fetch(`${url}/rest/v1/${path}`, {
    ...init,
    headers: {
      apikey: serviceKey,
      Authorization: `Bearer ${serviceKey}`,
      'Content-Type': 'application/json',
      ...(init.headers ?? {}),
    },
  });
}

interface Row {
  subscription_id: string;
  notification_id: number;
  ciphertext: string;
  push_subscriptions: { endpoint: string };
}

async function due(now: Date): Promise<DuePush[]> {
  const since = new Date(now.getTime() - staleMs).toISOString();
  const response = await rest(
    'scheduled_pushes?select=subscription_id,notification_id,ciphertext,push_subscriptions(endpoint)' +
      `&sent_at=is.null&fire_at=lte.${now.toISOString()}&fire_at=gte.${since}` +
      '&order=fire_at&limit=500',
  );
  if (!response.ok) throw new Error(`select failed: ${response.status}`);
  return ((await response.json()) as Row[]).map((r) => ({
    subscriptionId: r.subscription_id,
    notificationId: r.notification_id,
    endpoint: r.push_subscriptions.endpoint,
    body: fromPgBytea(r.ciphertext),
  }));
}

async function record(push: DuePush, outcome: Outcome, now: Date): Promise<void> {
  if (outcome === 'retry') return;
  if (outcome === 'gone') {
    await rest(`push_subscriptions?id=eq.${push.subscriptionId}`, { method: 'DELETE' });
    return;
  }
  await rest(
    `scheduled_pushes?subscription_id=eq.${push.subscriptionId}&notification_id=eq.${push.notificationId}`,
    { method: 'PATCH', body: JSON.stringify({ sent_at: now.toISOString() }) },
  );
}

/** Marks reminders that waited past [staleMs] as handled, unsent. */
async function dropStale(now: Date): Promise<void> {
  const before = new Date(now.getTime() - staleMs).toISOString();
  await rest(`scheduled_pushes?sent_at=is.null&fire_at=lt.${before}`, {
    method: 'PATCH',
    body: JSON.stringify({ sent_at: now.toISOString() }),
  });
}

Deno.serve(async (req) => {
  // Only the scheduler, holding the service-role key, may run this.
  if (req.headers.get('Authorization') !== `Bearer ${serviceKey}`) {
    return new Response('forbidden', { status: 403 });
  }
  if (!vapid.publicKey || !vapid.privateKey || !vapid.subject) {
    return new Response('VAPID secrets are not set', { status: 500 });
  }
  const now = new Date();
  const pushes = await due(now);
  const counts: Record<Outcome, number> = { sent: 0, gone: 0, retry: 0 };
  for (const push of pushes) {
    let outcome: Outcome;
    try {
      outcome = await deliver(push, vapid, Math.floor(now.getTime() / 1000));
    } catch {
      outcome = 'retry';
    }
    counts[outcome]++;
    await record(push, outcome, now);
  }
  await dropStale(now);
  // Counts only: no endpoints or IDs in logs (04 §9).
  return Response.json(counts);
});
