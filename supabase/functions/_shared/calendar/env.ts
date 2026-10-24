// The calendar functions' configuration (docs/09 M7.4; placeholders in
// supabase/functions/.env.example, real values are the owner's function
// secrets, docs/08 §6.1).
import type { OAuthClient } from './oauth.ts';
import type { Provider } from './store.ts';

type Get = (key: string) => string | undefined;

/** Placeholder values count as unset, so a missing secret says so. */
const real = (v: string | undefined) => (v && !v.startsWith('placeholder') ? v : undefined);

/**
 * The OAuth client of each provider, or null when its id or secret is
 * missing. The callback is CALENDAR_OAUTH_REDIRECT_URL, else the project's
 * own `…/functions/v1/calendar-oauth/callback`.
 */
export function oauthClients(get: Get): (p: Provider) => OAuthClient | null {
  const redirectUri =
    get('CALENDAR_OAUTH_REDIRECT_URL') ?? `${get('SUPABASE_URL')}/functions/v1/calendar-oauth/callback`;
  return (p) => {
    const prefix = p === 'google' ? 'GOOGLE' : 'MICROSOFT';
    const clientId = real(get(`${prefix}_CALENDAR_CLIENT_ID`));
    const clientSecret = real(get(`${prefix}_CALENDAR_CLIENT_SECRET`));
    if (!clientId || !clientSecret) return null;
    return { clientId, clientSecret, redirectUri, tenant: get('MICROSOFT_CALENDAR_TENANT') ?? 'common' };
  };
}

/** CALENDAR_RETURN_ORIGINS: comma-separated web origins. */
export function returnOrigins(get: Get): string[] {
  return (get('CALENDAR_RETURN_ORIGINS') ?? '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
}
