// node --experimental-strip-types --test supabase/functions/send-push/push_test.ts
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { b64u, deliver, fromB64u, fromPgBytea, vapidAuthorization } from './push.ts';
import type { DuePush, Vapid } from './push.ts';

async function testVapid(): Promise<Vapid> {
  const pair = await crypto.subtle.generateKey(
    { name: 'ECDSA', namedCurve: 'P-256' },
    true,
    ['sign', 'verify'],
  );
  const jwk = await crypto.subtle.exportKey('jwk', pair.privateKey);
  const raw = new Uint8Array(await crypto.subtle.exportKey('raw', pair.publicKey));
  return { publicKey: b64u(raw), privateKey: jwk.d!, subject: 'mailto:ops@example.com' };
}

const push = (status: number): [DuePush, typeof fetch, RequestInit[]] => {
  const calls: RequestInit[] = [];
  const fake = (async (_url: string, init: RequestInit) => {
    calls.push(init);
    return new Response(null, { status });
  }) as typeof fetch;
  return [
    {
      subscriptionId: 's1',
      notificationId: 7,
      endpoint: 'https://fcm.googleapis.com/fcm/send/abc',
      body: new Uint8Array([1, 2, 3]),
    },
    fake,
    calls,
  ];
};

test('the VAPID JWT verifies with the public key and names the origin', async () => {
  const vapid = await testVapid();
  const header = await vapidAuthorization('https://push.example.com/x/y', vapid, 1_800_000_000);
  const [, jwt, k] = /^vapid t=([^,]+), k=(.+)$/.exec(header)!;
  assert.equal(k, vapid.publicKey);
  const [h, c, s] = jwt.split('.');
  const claims = JSON.parse(new TextDecoder().decode(fromB64u(c)));
  assert.deepEqual(claims, {
    aud: 'https://push.example.com',
    exp: 1_800_000_000 + 43_200,
    sub: 'mailto:ops@example.com',
  });
  const key = await crypto.subtle.importKey(
    'raw',
    fromB64u(vapid.publicKey),
    { name: 'ECDSA', namedCurve: 'P-256' },
    false,
    ['verify'],
  );
  const ok = await crypto.subtle.verify(
    { name: 'ECDSA', hash: 'SHA-256' },
    key,
    fromB64u(s),
    new TextEncoder().encode(`${h}.${c}`),
  );
  assert.ok(ok);
});

test('posts the ciphertext with aes128gcm, TTL and high urgency', async () => {
  const vapid = await testVapid();
  const [p, fake, calls] = push(201);
  assert.equal(await deliver(p, vapid, 1_800_000_000, fake), 'sent');
  const headers = calls[0].headers as Record<string, string>;
  assert.equal(headers['Content-Encoding'], 'aes128gcm');
  assert.equal(headers.TTL, '3600');
  assert.equal(headers.Urgency, 'high');
  assert.match(headers.Authorization, /^vapid t=/);
  assert.deepEqual(calls[0].body, new Uint8Array([1, 2, 3]));
});

test('404 and 410 mean the subscription is gone; others retry', async () => {
  const vapid = await testVapid();
  for (const [status, outcome] of [[404, 'gone'], [410, 'gone'], [429, 'retry'], [500, 'retry']] as const) {
    const [p, fake] = push(status);
    assert.equal(await deliver(p, vapid, 0, fake), outcome);
  }
});

test('reads PostgREST bytea', () => {
  assert.deepEqual(fromPgBytea('\\x0102ff'), new Uint8Array([1, 2, 255]));
});
