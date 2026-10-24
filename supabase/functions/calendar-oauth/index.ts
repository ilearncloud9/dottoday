// calendar-oauth (docs/09 M7.4): POST starts a connect (the caller's JWT is
// checked here, since the provider's redirect to GET /callback carries none:
// verify_jwt = false in config.toml). The service-role key and the OAuth
// client secrets are only ever here.
import { callback, start } from './connect.ts';
import type { Outcome } from './connect.ts';
import { oauthClients, returnOrigins } from '../_shared/calendar/env.ts';

const get = (k: string) => Deno.env.get(k);
const deps = {
  db: { url: get('SUPABASE_URL')!, serviceKey: get('SUPABASE_SERVICE_ROLE_KEY')!, fetch },
  client: oauthClients(get),
  returnOrigins: returnOrigins(get),
  now: () => Date.now(),
  log: (event: string, fields?: Record<string, unknown>) => console.log(JSON.stringify({ event, ...fields })),
};

// The app calls from a browser on the web, so the start answers CORS.
const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

function reply(o: Outcome): Response {
  if ('location' in o) return new Response(null, { status: 302, headers: { Location: o.location } });
  if ('text' in o) return new Response(o.text, { status: o.status, headers: { 'Content-Type': 'text/plain' } });
  return Response.json(o.body, { status: o.status, headers: cors });
}

Deno.serve(async (req) => {
  const url = new URL(req.url);
  if (req.method === 'OPTIONS') return new Response(null, { status: 204, headers: cors });
  if (req.method === 'GET' && url.pathname.endsWith('/callback')) {
    return reply(await callback(url.searchParams, deps));
  }
  if (req.method !== 'POST') return new Response(null, { status: 405 });
  const jwt = req.headers.get('Authorization')?.replace(/^Bearer /, '') ?? null;
  const body = await req.json().catch(() => null);
  return reply(await start(jwt, body, deps));
});
