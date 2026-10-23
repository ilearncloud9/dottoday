// Pure parts of send-push (docs/09 M5.3b): VAPID auth (RFC 8292) and one
// delivery. No Deno or npm imports, so it is tested in Node:
// node --experimental-strip-types --test supabase/functions/send-push/push_test.ts

/** VAPID key pair (base64url) and contact, from Edge Function secrets. */
export interface Vapid {
  publicKey: string; // uncompressed P-256 point, 65 bytes
  privateKey: string; // the scalar d, 32 bytes
  subject: string; // mailto: or https: contact for push services
}

/** A due reminder: where to, and the browser-encrypted body. */
export interface DuePush {
  subscriptionId: string;
  notificationId: number;
  endpoint: string;
  body: Uint8Array;
}

/** What to do with a row after one attempt. */
export type Outcome = 'sent' | 'gone' | 'retry';

const enc = new TextEncoder();

export function b64u(bytes: Uint8Array): string {
  let bin = '';
  for (const b of bytes) bin += String.fromCharCode(b);
  return btoa(bin).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

export function fromB64u(s: string): Uint8Array {
  const b64 = s.replace(/-/g, '+').replace(/_/g, '/') + '==='.slice((s.length + 3) % 4);
  return Uint8Array.from(atob(b64), (c) => c.charCodeAt(0));
}

/** PostgREST returns bytea as `\x` + hex. */
export function fromPgBytea(hex: string): Uint8Array {
  const h = hex.startsWith('\\x') ? hex.slice(2) : hex;
  const out = new Uint8Array(h.length / 2);
  for (let i = 0; i < out.length; i++) out[i] = parseInt(h.substr(i * 2, 2), 16);
  return out;
}

/**
 * The `Authorization` header for [endpoint]: `vapid t=<ES256 JWT>, k=<key>`,
 * audience the push service's origin, valid 12 h.
 */
export async function vapidAuthorization(
  endpoint: string,
  vapid: Vapid,
  nowSeconds: number,
): Promise<string> {
  const pub = fromB64u(vapid.publicKey);
  const key = await crypto.subtle.importKey(
    'jwk',
    {
      kty: 'EC',
      crv: 'P-256',
      d: vapid.privateKey,
      x: b64u(pub.slice(1, 33)),
      y: b64u(pub.slice(33, 65)),
    },
    { name: 'ECDSA', namedCurve: 'P-256' },
    false,
    ['sign'],
  );
  const header = b64u(enc.encode(JSON.stringify({ typ: 'JWT', alg: 'ES256' })));
  const claims = b64u(
    enc.encode(
      JSON.stringify({
        aud: new URL(endpoint).origin,
        exp: nowSeconds + 12 * 60 * 60,
        sub: vapid.subject,
      }),
    ),
  );
  // WebCrypto's ECDSA signature is already r||s, the JWS ES256 form.
  const signature = new Uint8Array(
    await crypto.subtle.sign(
      { name: 'ECDSA', hash: 'SHA-256' },
      key,
      enc.encode(`${header}.${claims}`),
    ),
  );
  return `vapid t=${header}.${claims}.${b64u(signature)}, k=${vapid.publicKey}`;
}

/**
 * Posts one push. 2xx is sent; 404/410 means the browser dropped the
 * subscription; anything else is retried on the next run (until stale).
 */
export async function deliver(
  push: DuePush,
  vapid: Vapid,
  nowSeconds: number,
  fetchFn: typeof fetch = fetch,
): Promise<Outcome> {
  const response = await fetchFn(push.endpoint, {
    method: 'POST',
    headers: {
      Authorization: await vapidAuthorization(push.endpoint, vapid, nowSeconds),
      'Content-Encoding': 'aes128gcm',
      'Content-Type': 'application/octet-stream',
      // A reminder is useless an hour late (docs/02 F6).
      TTL: '3600',
      Urgency: 'high',
    },
    body: push.body,
  });
  if (response.ok) return 'sent';
  if (response.status === 404 || response.status === 410) return 'gone';
  return 'retry';
}
