// node --experimental-strip-types --test supabase/functions/delete-account/deletion_test.ts
// delete-account under the CR-160 W2 contract (migration 0015), against an
// in-memory Supabase that keeps the migration's rules (deletion_fake.ts).
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { deleteAccount } from './deletion.ts';
import { FakeSupabase } from './deletion_fake.ts';

const A = '00000000-0000-4000-8000-0000000000a1';
const B = '00000000-0000-4000-8000-0000000000b1';

function world() {
  const sb = new FakeSupabase();
  const ta = sb.addUser(A, 'a@example.com');
  sb.addUser(B, 'b@example.com');
  return { sb, ta, d: sb.deps() };
}
const del = (rev: number) => ({ expected_revision: rev });
const adminCalls = (sb: FakeSupabase) => sb.calls.filter((c) => c === 'admin-delete').length;

// ---------- the request ----------
test('no session: refused, nothing called', async () => {
  const { sb, d } = world();
  assert.equal((await deleteAccount(null, del(1), d)).status, 401);
  assert.deepEqual(sb.calls, []);
});

for (const [name, body] of [
  ['no body (an older app)', null],
  ['an empty body', {}],
  ['a revision that is text', { expected_revision: '1' }],
  ['a negative revision', { expected_revision: -1 }],
  ['a fractional revision', { expected_revision: 1.5 }],
  ['an unknown action', { action: 'purge', expected_revision: 1 }],
  ['an array', [1]],
] as const) {
  test(`${name}: 400 update_required, nothing called, nothing deleted`, async () => {
    const { sb, ta, d } = world();
    assert.deepEqual(await deleteAccount(ta, body, d), { status: 400, body: { error: 'update_required' } });
    assert.deepEqual(sb.calls, []);
    assert.ok(sb.users.has(A));
  });
}

test('the account comes from the session, never the body', async () => {
  const { sb, ta, d } = world();
  const out = await deleteAccount(ta, { expected_revision: 1, p_user: B, user_id: B }, d);
  assert.equal(out.status, 200);
  assert.ok(!sb.users.has(A), 'A, whose session it is, is deleted');
  assert.ok(sb.users.has(B), 'B, named in the body, is untouched');
});

// ---------- revisions ----------
test('current revision: frozen, call recorded first, deleted, mailed once', async () => {
  const { sb, ta, d } = world();
  const out = await deleteAccount(ta, del(1), d);
  assert.deepEqual(out, { status: 200, body: { deleted: true, mailed: true } });
  assert.deepEqual(sb.calls, ['user', 'begin', 'note-call', 'admin-delete']);
  assert.deepEqual(sb.mails, ['a@example.com']);
  assert.ok(sb.users.has(B), 'another account is untouched');
});

test('a write from another device after the export: 409 changed, nothing frozen or deleted', async () => {
  const { sb, ta, d } = world();
  sb.write(A);
  assert.deepEqual(await deleteAccount(ta, del(1), d), { status: 409, body: { error: 'changed' } });
  assert.equal(sb.users.get(A)!.attempt, null);
  assert.equal(adminCalls(sb), 0);
});

test('lock timeout while freezing: 503 busy, nothing frozen, no Admin call', async () => {
  const { sb, ta, d } = world();
  sb.lockTimeout = true;
  assert.deepEqual(await deleteAccount(ta, del(1), d), { status: 503, body: { error: 'busy', retry: true } });
  assert.equal(adminCalls(sb), 0);
});

test('frozen at another revision: 503 pending, never taken over', async () => {
  const { sb, ta, d } = world();
  sb.adminSteps.push('timeout-kept');
  await deleteAccount(ta, del(1), d);
  const attempt = sb.users.get(A)!.attempt;
  assert.equal((await deleteAccount(ta, del(7), d)).body.error, 'pending');
  assert.equal(sb.users.get(A)!.attempt, attempt);
  assert.equal(adminCalls(sb), 1, 'no Admin call for the other revision');
});

// ---------- recording each call before it is made ----------
for (const failure of ['network', 500] as const) {
  test(`recording the call fails (${failure}): no Admin call, frozen, pending`, async () => {
    const { sb, ta, d } = world();
    sb.failing.set('note-call', failure);
    assert.equal((await deleteAccount(ta, del(1), d)).body.error, 'pending');
    assert.equal(adminCalls(sb), 0);
    assert.notEqual(sb.users.get(A)!.attempt, null);
  });
}

test('cancelled between the freeze and recording the call: 409 changed, no Admin call', async () => {
  const { sb, ta, d } = world();
  sb.before.set('note-call', () => {
    const a = sb.users.get(A)!;
    a.attempt = null; // a cancel released it (no call was recorded yet)
    a.frozenAt = null;
    a.revision++;
  });
  assert.deepEqual(await deleteAccount(ta, del(1), d), { status: 409, body: { error: 'changed' } });
  assert.equal(adminCalls(sb), 0);
  assert.ok(sb.users.has(A));
});

test('deleted by another request between the freeze and recording: 200 already, no Admin call', async () => {
  const { sb, ta, d } = world();
  sb.before.set('note-call', () => sb.users.delete(A));
  assert.deepEqual((await deleteAccount(ta, del(1), d)).body, { deleted: true, already: true, mailed: false });
  assert.equal(adminCalls(sb), 0);
});

// ---------- outcomes of the Auth Admin call ----------
for (const step of ['timeout-kept', 'timeout-deleted', 'network-kept', 'hang-kept', 500, 502, 503, 504] as const) {
  test(`Admin ${step}: 503 pending, call unresolved, nothing released`, async () => {
    const { sb, ta, d } = world();
    sb.adminSteps.push(step);
    assert.deepEqual(await deleteAccount(ta, del(1), d), { status: 503, body: { error: 'pending', retry: true } });
    assert.ok(!sb.calls.includes('note-refused') && !sb.calls.includes('release'));
    if (sb.users.has(A)) {
      assert.notEqual(sb.users.get(A)!.attempt, null, 'still frozen');
      assert.equal(sb.users.get(A)!.unresolved, 1);
    }
    assert.deepEqual(sb.mails, []);
  });
}

// GoTrue's pre-transaction rejections, in both of its error formats: the
// only answers that prove the call ended without deleting.
const proven = [
  { status: 400, body: { code: 400, error_code: 'bad_json', msg: 'x' } },
  { status: 401, body: { code: 401, error_code: 'no_authorization', msg: 'x' } },
  { status: 403, body: { code: 403, error_code: 'bad_jwt', msg: 'x' } },
  { status: 403, body: { code: 403, error_code: 'not_admin', msg: 'x' } },
  { status: 413, body: { code: 413, error_code: 'request_entity_too_large', msg: 'x' } },
  { status: 400, body: { code: 'bad_json', message: 'x' } },
];
for (const step of proven) {
  test(`Admin ${step.status} ${JSON.stringify(step.body)}: proven refusal, released, 500 not_deleted`, async () => {
    const { sb, ta, d } = world();
    sb.adminSteps.push(step);
    assert.deepEqual(await deleteAccount(ta, del(1), d), { status: 500, body: { error: 'not_deleted' } });
    assert.deepEqual(sb.calls.slice(-2), ['note-refused', 'release']);
    assert.equal(sb.users.get(A)!.attempt, null);
    assert.equal(sb.users.get(A)!.revision, 2, 'the revision moved: the old review is void');
  });
}

// A status without GoTrue's matching pre-transaction code proves nothing.
const unproven = [
  { status: 400, body: {} },
  { status: 400, body: { code: 400, error_code: 'validation_failed', msg: 'x' } },
  { status: 401, body: { message: 'No API key found in request' } }, // a gateway
  { status: 403, body: { code: 403, error_code: 'bad_json', msg: 'x' } }, // code for another status
  { status: 405, body: {} },
  { status: 409, body: { code: 409, error_code: 'conflict', msg: 'x' } },
  { status: 422, body: { code: 422, error_code: 'validation_failed', msg: 'x' } },
  { status: 429, body: { code: 429, error_code: 'over_request_rate_limit', msg: 'x' } },
  { status: 500, body: { code: 500, error_code: 'unexpected_failure', msg: 'x' } },
];
for (const step of unproven) {
  test(`Admin ${step.status} ${JSON.stringify(step.body)}: not proof, pending, call unresolved`, async () => {
    const { sb, ta, d } = world();
    sb.adminSteps.push(step);
    assert.deepEqual(await deleteAccount(ta, del(1), d), { status: 503, body: { error: 'pending', retry: true } });
    assert.ok(!sb.calls.includes('note-refused') && !sb.calls.includes('release'));
    assert.notEqual(sb.users.get(A)!.attempt, null, 'still frozen');
    assert.equal(sb.users.get(A)!.unresolved, 1);
  });
}

test('a refusal never clears an earlier unknown call: still frozen', async () => {
  const { sb, ta, d } = world();
  sb.adminSteps.push('timeout-kept', proven[0]);
  await deleteAccount(ta, del(1), d);
  assert.equal((await deleteAccount(ta, del(1), d)).body.error, 'pending');
  assert.deepEqual(sb.calls.slice(-2), ['note-refused', 'release'], 'the refusal resolved its own call');
  assert.equal(sb.users.get(A)!.unresolved, 1, 'the first call is still unknown');
  assert.notEqual(sb.users.get(A)!.attempt, null, 'not released');
  // A third attempt that succeeds still finishes the deletion.
  assert.equal((await deleteAccount(ta, del(1), d)).body.deleted, true);
});

test('Admin "not found" while the user still exists (not proof of anything): pending, kept frozen', async () => {
  const { sb, ta, d } = world();
  sb.adminSteps.push(404);
  assert.equal((await deleteAccount(ta, del(1), d)).body.error, 'pending');
  assert.ok(!sb.calls.includes('note-refused') && !sb.calls.includes('release'));
  assert.equal(sb.users.get(A)!.unresolved, 1);
});

// ---------- retries ----------
test('crash after recording (outcome unknown), then a retry at the same revision finishes it', async () => {
  const { sb, ta, d } = world();
  sb.adminSteps.push('network-kept');
  await deleteAccount(ta, del(1), d);
  const attempt = sb.users.get(A)!.attempt;
  const out = await deleteAccount(ta, del(1), d);
  assert.deepEqual(out, { status: 200, body: { deleted: true, mailed: true } });
  assert.equal(adminCalls(sb), 2);
  assert.ok(attempt, 'the retry joined the same attempt');
  assert.deepEqual(sb.mails, ['a@example.com'], 'one mail');
});

test('Auth deleted but the answer was lost: the retry reports it, no second mail', async () => {
  const { sb, ta, d } = world();
  sb.adminSteps.push('timeout-deleted');
  assert.equal((await deleteAccount(ta, del(1), d)).body.error, 'pending');
  assert.deepEqual(await deleteAccount(ta, del(1), d), {
    status: 200, body: { deleted: true, already: true, mailed: false },
  });
  assert.deepEqual(sb.mails, [], 'the deleting call\'s answer was lost: no mail was sent');
});

test('two requests at once at the same revision: one deletes and mails, the other reports it', async () => {
  const { sb, ta, d } = world();
  const [x, y] = await Promise.all([deleteAccount(ta, del(1), d), deleteAccount(ta, del(1), d)]);
  assert.deepEqual([x.status, y.status], [200, 200]);
  assert.equal([x, y].filter((o) => o.body.already === true).length, 1);
  assert.deepEqual(sb.mails, ['a@example.com']);
});

test('a session whose user is gone: 200 already, nothing frozen or called', async () => {
  const { sb, ta, d } = world();
  sb.users.delete(A);
  assert.deepEqual((await deleteAccount(ta, del(1), d)).body, { deleted: true, already: true, mailed: false });
  assert.ok(!sb.calls.includes('begin'));
});

test('Auth unreachable for the session: 503 busy, nothing frozen', async () => {
  const { sb, ta, d } = world();
  sb.failing.set('user', 'network');
  assert.equal((await deleteAccount(ta, del(1), d)).body.error, 'busy');
  assert.equal(sb.users.get(A)!.attempt, null);
});

// ---------- cancel ----------
test('cancel with nothing frozen: nothing to do', async () => {
  const { ta, d } = world();
  assert.deepEqual((await deleteAccount(ta, { action: 'cancel' }, d)).body, { released: false, frozen: false });
});

test('cancel after a crash before any call was recorded: released, writes resume', async () => {
  const { sb, ta, d } = world();
  sb.failing.set('note-call', 500);
  await deleteAccount(ta, del(1), d);
  sb.failing.delete('note-call');
  assert.deepEqual((await deleteAccount(ta, { action: 'cancel' }, d)).body, { released: true });
  assert.ok(sb.write(A));
  assert.equal(adminCalls(sb), 0);
});

test('cancel while a call\'s outcome is unknown: refused, still frozen, no Admin call', async () => {
  const { sb, ta, d } = world();
  sb.adminSteps.push('timeout-kept');
  await deleteAccount(ta, del(1), d);
  assert.deepEqual(await deleteAccount(ta, { action: 'cancel' }, d), { status: 409, body: { error: 'pending' } });
  assert.notEqual(sb.users.get(A)!.attempt, null);
  assert.ok(!sb.write(A));
  assert.equal(adminCalls(sb), 1);
});

test('no mail provider: deleted, says so', async () => {
  const sb = new FakeSupabase();
  const ta = sb.addUser(A, 'a@example.com');
  assert.deepEqual((await deleteAccount(ta, del(1), sb.deps(false))).body, { deleted: true, mailed: false });
});
