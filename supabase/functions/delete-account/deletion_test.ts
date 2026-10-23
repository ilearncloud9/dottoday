// node --experimental-strip-types --test supabase/functions/delete-account/deletion_test.ts
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { deleteAccount } from './deletion.ts';
import type { Deps } from './deletion.ts';

function deps(routes: Record<string, number>, mail: string[] | null = null): [Deps, string[]] {
  const calls: string[] = [];
  const fake = (async (url: string, init: RequestInit = {}) => {
    calls.push(`${init.method ?? 'GET'} ${url}`);
    const status = routes[`${init.method ?? 'GET'} ${url}`] ?? 404;
    const body = url.endsWith('/auth/v1/user') ? JSON.stringify({ id: 'u1', email: 'kody@example.com' }) : null;
    return new Response(body, { status });
  }) as typeof fetch;
  return [
    {
      url: 'http://sb',
      serviceKey: 'service',
      fetch: fake,
      sendMail: mail ? async (to: string) => { mail.push(to); } : null,
    },
    calls,
  ];
}

test('no session: refused, nothing deleted', async () => {
  const [d, calls] = deps({});
  assert.equal((await deleteAccount(null, d)).status, 401);
  assert.deepEqual(calls, []);
});

test('a session the server refuses: nothing deleted', async () => {
  const [d, calls] = deps({ 'GET http://sb/auth/v1/user': 401 });
  assert.equal((await deleteAccount('jwt', d)).status, 401);
  assert.equal(calls.some((c) => c.startsWith('DELETE')), false);
});

test('deletes the caller (from their session) and mails them', async () => {
  const mail: string[] = [];
  const [d, calls] = deps(
    { 'GET http://sb/auth/v1/user': 200, 'DELETE http://sb/auth/v1/admin/users/u1': 200 },
    mail,
  );
  const out = await deleteAccount('jwt', d);
  assert.deepEqual(out, { status: 200, body: { deleted: true, mailed: true } });
  assert.deepEqual(calls, ['GET http://sb/auth/v1/user', 'DELETE http://sb/auth/v1/admin/users/u1']);
  assert.deepEqual(mail, ['kody@example.com']);
});

test('no mail provider: still deleted, says so', async () => {
  const [d] = deps({ 'GET http://sb/auth/v1/user': 200, 'DELETE http://sb/auth/v1/admin/users/u1': 200 });
  assert.deepEqual(await deleteAccount('jwt', d), { status: 200, body: { deleted: true, mailed: false } });
});

test('a failed delete is an error, not a success', async () => {
  const [d] = deps({ 'GET http://sb/auth/v1/user': 200, 'DELETE http://sb/auth/v1/admin/users/u1': 500 });
  assert.equal((await deleteAccount('jwt', d)).status, 500);
});
