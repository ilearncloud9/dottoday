// An in-memory Supabase for deletion_test.ts: Auth (users, sessions, the
// Admin API) and the 0015 functions with the same rules as the migration
// (frozen while an attempt is set, calls recorded before they're made,
// release only for that attempt with none unresolved). Each Auth Admin
// deletion answers from a script, to stage outcomes the real stack can't.
import type { Deps } from './deletion.ts';

type Account = {
  email: string;
  revision: number;
  attempt: string | null;
  frozenAt: number | null;
  unresolved: number;
};

/** How one Auth Admin deletion goes: an HTTP status (2xx deletes) with an
 * optional error body, or a timeout / dropped connection after which the
 * user is gone or not. */
export type AdminStep =
  | number
  | { status: number; body: unknown }
  | 'timeout-deleted' | 'timeout-kept' | 'network-kept' | 'hang-kept';

export class FakeSupabase {
  readonly users = new Map<string, Account>();
  readonly calls: string[] = [];
  readonly mails: string[] = [];
  readonly adminSteps: AdminStep[] = [];
  /** Routes that fail: by name, with a status or a dropped connection. */
  readonly failing = new Map<string, number | 'network'>();
  lockTimeout = false;
  /** Runs once just before the named route: another request's step in between. */
  readonly before = new Map<string, () => void>();
  private attempts = 0;

  addUser(id: string, email: string): string {
    this.users.set(id, { email, revision: 1, attempt: null, frozenAt: null, unresolved: 0 });
    return token(id);
  }

  /** A write to [id]'s exported data from another device. */
  write(id: string): boolean {
    const a = this.users.get(id);
    if (!a || a.attempt) return false;
    a.revision++;
    return true;
  }

  deps(mail = true): Deps {
    return {
      url: 'http://sb',
      serviceKey: 'service',
      fetch: ((u: string, init?: RequestInit) => this.handle(u, init ?? {})) as typeof fetch,
      sendMail: mail ? async (to: string) => { this.mails.push(to); } : null,
      adminTimeoutMs: 50,
    };
  }

  private async handle(u: string, init: RequestInit): Promise<Response> {
    const method = init.method ?? 'GET';
    const path = u.replace('http://sb', '');
    const name = route(method, path);
    this.calls.push(name);
    const step = this.before.get(name);
    if (step) { this.before.delete(name); step(); }
    const fail = this.failing.get(name);
    if (fail === 'network') throw new TypeError('network');
    if (typeof fail === 'number') return json(fail, { code: 'XX000' });
    const args = init.body ? JSON.parse(String(init.body)) : {};
    switch (name) {
      case 'user': return this.user(String((init.headers as Record<string, string>).Authorization));
      case 'admin-get': return this.users.has(lastPart(path)) ? json(200, {}) : json(404, {});
      case 'admin-delete': return this.adminDelete(lastPart(path), init.signal ?? null);
      case 'attempt': return json(200, this.attemptRows(path));
      case 'begin': return this.begin(args.p_user, args.p_expected);
      case 'note-call': return json(200, this.noteCall(args.p_user, args.p_attempt));
      case 'note-refused': return json(200, this.noteRefused(args.p_user, args.p_attempt));
      case 'release': return json(200, this.release(args.p_user, args.p_attempt));
      default: return json(404, {});
    }
  }

  private user(auth: string): Response {
    const id = JSON.parse(atob(auth.replace('Bearer ', '').split('.')[1])).sub;
    const a = this.users.get(id);
    return a ? json(200, { id, email: a.email }) : json(403, { code: 'user_not_found' });
  }

  private adminDelete(id: string, signal: AbortSignal | null): Promise<Response> | Response {
    const step = this.adminSteps.shift() ?? 200;
    // Never answers: only the caller's own timeout ends the wait.
    if (step === 'hang-kept') {
      return new Promise((_, reject) => {
        // AbortSignal.timeout's timer doesn't hold node's event loop open.
        const keep = setTimeout(() => reject(new Error('never aborted')), 5_000);
        signal?.addEventListener('abort', () => { clearTimeout(keep); reject(signal.reason); });
      });
    }
    if (!this.users.has(id) && typeof step === 'number' && step < 300) return json(404, {});
    if (step === 'timeout-deleted') this.users.delete(id);
    if (typeof step === 'string') {
      if (step === 'network-kept') return Promise.reject(new TypeError('network'));
      return Promise.reject(new DOMException('timed out', 'TimeoutError'));
    }
    if (typeof step === 'object') return json(step.status, step.body);
    if (step >= 200 && step < 300) this.users.delete(id);
    return json(step, {});
  }

  private attemptRows(path: string): unknown[] {
    const id = decodeURIComponent(path.split('user_id=eq.')[1] ?? '');
    const a = this.users.get(id);
    return a ? [{ deletion_attempt: a.attempt }] : [];
  }

  private begin(id: string, expected: number): Response {
    if (this.lockTimeout) return json(503, { code: '55P03' });
    const a = this.users.get(id);
    if (!a) return json(200, [{ outcome: 'gone', attempt: null }]);
    if (a.attempt) {
      return json(200, [a.frozenAt === expected
        ? { outcome: 'frozen', attempt: a.attempt }
        : { outcome: 'pending', attempt: null }]);
    }
    if (a.revision !== expected) return json(200, [{ outcome: 'changed', attempt: null }]);
    a.attempt = `attempt-${++this.attempts}`;
    a.frozenAt = a.revision;
    return json(200, [{ outcome: 'frozen', attempt: a.attempt }]);
  }

  private noteCall(id: string, attempt: string): boolean {
    const a = this.users.get(id);
    if (!a || a.attempt !== attempt) return false;
    a.unresolved++;
    return true;
  }

  private noteRefused(id: string, attempt: string): boolean {
    const a = this.users.get(id);
    if (!a || a.attempt !== attempt || a.unresolved === 0) return false;
    a.unresolved--;
    return true;
  }

  private release(id: string, attempt: string): string {
    const a = this.users.get(id);
    if (!a) return 'gone';
    if (!a.attempt) return 'not_frozen';
    if (a.attempt !== attempt) return 'other_attempt';
    if (a.unresolved > 0) return 'unresolved';
    a.attempt = null;
    a.frozenAt = null;
    a.revision++;
    return 'released';
  }
}

/** A session token whose payload names [id] (the gateway verified it). */
export function token(id: string): string {
  const b64 = (o: unknown) => btoa(JSON.stringify(o)).replace(/=+$/, '').replace(/\+/g, '-').replace(/\//g, '_');
  return `${b64({ alg: 'HS256' })}.${b64({ sub: id, role: 'authenticated' })}.sig`;
}

function route(method: string, path: string): string {
  if (path === '/auth/v1/user') return 'user';
  if (path.startsWith('/auth/v1/admin/users/')) return method === 'DELETE' ? 'admin-delete' : 'admin-get';
  if (path.startsWith('/rest/v1/account_revisions')) return 'attempt';
  const rpcs: Record<string, string> = {
    begin_account_deletion: 'begin',
    note_account_deletion_call: 'note-call',
    note_account_deletion_refused: 'note-refused',
    release_account_deletion: 'release',
  };
  return rpcs[path.replace('/rest/v1/rpc/', '')] ?? `unknown ${method} ${path}`;
}

const lastPart = (path: string) => path.split('/').pop()!;
const json = (status: number, body: unknown) => new Response(JSON.stringify(body), { status });
