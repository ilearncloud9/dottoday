// calendar-sync (docs/09 M7.4): the gateway checks the caller's JWT
// (verify_jwt); the service-role key and the OAuth client secrets are only
// ever here. Logs carry action names and providers, never calendar content.
import { handle } from './sync.ts';
import { oauthClients } from '../_shared/calendar/env.ts';
import { googleApi } from '../_shared/calendar/google.ts';
import { microsoftApi } from '../_shared/calendar/microsoft.ts';

const get = (k: string) => Deno.env.get(k);
const deps = {
  db: { url: get('SUPABASE_URL')!, serviceKey: get('SUPABASE_SERVICE_ROLE_KEY')!, fetch },
  client: oauthClients(get),
  api: (p: 'google' | 'microsoft') => (p === 'google' ? googleApi(fetch) : microsoftApi(fetch)),
  now: () => Date.now(),
  log: (event: string, fields?: Record<string, unknown>) => console.log(JSON.stringify({ event, ...fields })),
};

// The web app calls it from the browser.
const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response(null, { status: 204, headers: cors });
  if (req.method !== 'POST') return new Response(null, { status: 405, headers: cors });
  const jwt = req.headers.get('Authorization')?.replace(/^Bearer /, '') ?? null;
  const body = await req.json().catch(() => null);
  const outcome = await handle(jwt, body, deps);
  return Response.json(outcome.body, { status: outcome.status, headers: cors });
});
