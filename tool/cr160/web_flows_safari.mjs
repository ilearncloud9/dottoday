// Drives the CR-160 web builds in real Safari through safaridriver (local
// only), the same five scenarios as web_flows.mjs. No dependency: plain
// WebDriver over fetch.
// Usage: `safaridriver -p 4723` running, then
//   node tool/cr160/web_flows_safari.mjs <scenario>   (shared, flow1, flow2, flow4, flow5)
// Safari's WebDriver can't read the console, where the test pages report.
// After each page load a hook copies console output into the page and the
// script reads it every second; a line printed before the hook lands is
// missed, so every check waits for a line printed late (a PHASE/RESULT
// line, or STATE/RELOAD-NOW/TAB2 markers) and a missing one fails the run.
// A "fresh profile" is a new session; each is checked empty first.
// See docs/cr-160-verification.md, criterion 10.

const driver = 'http://127.0.0.1:4723';
const base = 'http://127.0.0.1:8099';
const scenario = process.argv[2];
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function wd(method, path, body) {
  const res = await fetch(`${driver}${path}`, {
    method,
    headers: { 'Content-Type': 'application/json' },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const json = await res.json();
  if (json.value && json.value.error) throw new Error(`${path}: ${json.value.error} ${json.value.message}`);
  return json.value;
}

const hook = `if (!window.__cr160) { window.__cr160 = [];
  for (const k of ['log', 'info', 'warn', 'error', 'debug']) {
    const o = console[k].bind(console);
    console[k] = (...a) => { try { window.__cr160.push(a.map(String).join(' ')); } catch (_) {} o(...a); };
  }
  window.addEventListener('error', (e) => window.__cr160.push('pageerror ' + e.message));
}`;

class Session {
  static async open() {
    const v = await wd('POST', '/session', { capabilities: { alwaysMatch: { browserName: 'safari' } } });
    const s = new Session(v.sessionId);
    s.version = v.capabilities.browserVersion;
    return s;
  }
  constructor(id) { this.id = id; this.queue = Promise.resolve(); this.current = null; }
  // One WebDriver command at a time per session; with [handle], the switch
  // to that window and the command run as one step, so the poll loop and
  // the scenario never act in each other's window.
  cmd(method, path, body, handle) {
    const run = this.queue.then(async () => {
      if (handle && handle !== this.current) {
        await wd('POST', `/session/${this.id}/window`, { handle });
        this.current = handle;
      }
      return wd(method, `/session/${this.id}${path}`, body);
    });
    this.queue = run.catch(() => {});
    return run;
  }
  exec(script, handle) { return this.cmd('POST', '/execute/sync', { script, args: [] }, handle); }
  async close() { await wd('DELETE', `/session/${this.id}`); }

  /// Fails unless this session's storage on the origin is empty.
  async expectEmpty() {
    await this.cmd('POST', '/url', { url: `${base}/` });
    const v = await this.cmd('POST', '/execute/async', {
      script: `const done = arguments[arguments.length - 1];
        Promise.all([indexedDB.databases ? indexedDB.databases() : [], caches.keys()])
          .then(([dbs, cs]) => done({ ls: localStorage.length, dbs: dbs.length, caches: cs.length }))
          .catch((e) => done({ err: String(e) }));`,
      args: [],
    });
    if (v.err || v.ls || v.dbs || v.caches) throw new Error(`session not empty: ${JSON.stringify(v)}`);
  }
}

/// Watches the window [handle] of [s] after loading [url] in it.
async function watch(s, handle, tag, url) {
  await s.cmd('POST', '/url', { url }, handle);
  await s.exec(hook, handle);
  const lines = [];
  let stopped = false;
  const poll = (async () => {
    while (!stopped) {
      try {
        const got = await s.exec('const l = window.__cr160 || []; return l.splice(0, l.length);', handle);
        for (const t of got) {
          if (/CR160|EXCEPTION|Expected|Actual|Which|reason|failed|Error|PASS|pageerror/.test(t)) {
            console.log(`[${tag}] ${t.split('\n').slice(0, 12).join('\n')}`);
          }
          lines.push(t);
        }
      } catch (_) { /* a navigation in progress; next poll */ }
      await sleep(1000);
    }
  })();
  return {
    lines,
    stop() { stopped = true; return poll; },
    async wait(re, ms = 600000) {
      const until = Date.now() + ms;
      for (;;) {
        const hit = lines.find((l) => re.test(l));
        if (hit) return hit;
        if (Date.now() > until) throw new Error(`timeout waiting for ${re}`);
        await sleep(500);
      }
    },
  };
}

const done = /CR160 (PHASE \S+ PASS|RESULT PASS)|EXCEPTION CAUGHT|Test failed|Some tests failed/;
async function finish(w) {
  const end = await w.wait(done);
  if (!/PASS/.test(end)) throw new Error(`failed: ${end.split('\n')[0]}`);
  return end;
}
function stateOf(w) {
  const line = w.lines.find((l) => l.startsWith('CR160 STATE '));
  if (!line) throw new Error('STATE line missed (printed before the hook)');
  return line.slice(12);
}
const testUrl = (name, s) => `${base}/test/?phase=${name}${s ? `&s=${s}` : ''}`;

async function semanticsText(s, handle) {
  await s.exec("document.querySelector('flt-semantics-placeholder')?.click();", handle);
  await sleep(1500);
  return s.exec(`const host = document.querySelector('flt-semantics-host') || document.body;
    const out = [];
    host.querySelectorAll('*').forEach((e) => { const l = e.getAttribute('aria-label'); if (l) out.push(l); });
    return out.join(' | ') + ' | ' + (host.innerText || '');`, handle);
}

async function fresh() {
  const s = await Session.open();
  await s.expectEmpty();
  return s;
}

const open = [];
try {
  const s = await fresh();
  open.push(s);
  console.log(`browser safari ${s.version}`);
  const main = await s.cmd('GET', '/window');
  s.current = main;
  if (scenario === 'shared') {
    const w = await watch(s, main, 'shared', `${base}/shared/`);
    console.log(await finish(w));
    await w.stop();
  } else if (scenario === 'flow1') {
    const w1 = await watch(s, main, 'flow1', testUrl('flow1'));
    await finish(w1);
    const st = stateOf(w1);
    await w1.stop();
    const w2 = await watch(s, main, 'flow1after', testUrl('flow1after', st)); // a reload
    await finish(w2);
    await w2.stop();
  } else if (scenario === 'flow2') {
    const w1 = await watch(s, main, 'flow2seed', testUrl('flow2seed'));
    await finish(w1);
    const st = stateOf(w1);
    await w1.stop();
    await s.close();
    open.pop();
    const dev2 = await fresh(); // another device: a new, empty session
    open.push(dev2);
    const h2 = await dev2.cmd('GET', '/window');
    dev2.current = h2;
    const w2 = await watch(dev2, h2, 'flow2', testUrl('flow2', st));
    await finish(w2);
    await w2.stop();
  } else if (scenario === 'flow4') {
    const w1 = await watch(s, main, 'flow4', testUrl('flow4'));
    await w1.wait(/CR160 RELOAD-NOW/);
    const st = stateOf(w1);
    await w1.stop();
    // Leave the page mid-migration: the same window loads again at once.
    const w2 = await watch(s, main, 'flow4after', testUrl('flow4after', st));
    await finish(w2);
    await w2.stop();
  } else if (scenario === 'flow5') {
    const w1 = await watch(s, main, 'flow5', testUrl('flow5'));
    await w1.wait(/CR160 TAB2-NOW/);
    const { handle: tab2 } = await s.cmd('POST', '/window/new', { type: 'tab' });
    await s.cmd('POST', '/url', { url: `${base}/app/` }, tab2);
    await sleep(8000);
    const t1 = await semanticsText(s, tab2);
    console.log(`[tab2 while A] lockScreen=${/open in another tab/i.test(t1)} showsA=${/cr160 web tab A/.test(t1)}`);
    await w1.wait(/CR160 TAB2-AGAIN/);
    await s.cmd('POST', '/refresh', {}, tab2);
    await sleep(8000);
    const t2 = await semanticsText(s, tab2);
    console.log(`[tab2 while B] lockScreen=${/open in another tab/i.test(t2)} showsA=${/cr160 web tab A/.test(t2)}`);
    await finish(w1);
    await w1.stop();
    if (!/open in another tab/i.test(t1) || /cr160 web tab A/.test(t1 + t2)) throw new Error('second tab check failed');
  } else {
    throw new Error(`unknown scenario ${scenario}`);
  }
  console.log(`SCENARIO ${scenario} PASS`);
} catch (e) {
  console.log(`SCENARIO ${scenario} FAIL ${e.message}`);
  process.exitCode = 1;
} finally {
  for (const s of open) await s.close().catch(() => {});
  process.exit(process.exitCode ?? 0);
}
