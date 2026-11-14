// Drives the CR-160 web builds in Playwright's Chromium (local only).
// Usage (after `npm ci` in tool/a11y): node tool/cr160/web_flows.mjs <scenario>
//   scenarios: shared, flow1, flow2, flow4, flow5
// Builds are served at http://127.0.0.1:8099/: /shared/ (cr160_shared_device_test),
// /test/ (cr160_web_flows_test) and /app/ (the real app), one origin. See
// docs/cr-160-verification.md, criterion 10.
import { chromium } from '../a11y/node_modules/playwright/index.mjs';

const base = 'http://127.0.0.1:8099';
const scenario = process.argv[2];
const browser = await chromium.launch({ headless: true });
console.log(`browser chromium ${browser.version()}`);

function watch(page, tag) {
  const lines = [];
  const waiters = [];
  page.on('console', (m) => {
    const t = m.text();
    if (/CR160|EXCEPTION|Expected|Actual|Which|reason|failed|Error|PASS/.test(t)) {
      console.log(`[${tag}] ${t.split('\n').slice(0, 12).join('\n')}`);
    }
    lines.push(t);
    for (const w of [...waiters]) if (w.re.test(t)) { waiters.splice(waiters.indexOf(w), 1); w.res(t); }
  });
  page.on('pageerror', (e) => console.log(`[${tag}] pageerror ${e.message}`));
  return {
    lines,
    wait(re, ms = 600000) {
      const hit = lines.find((l) => re.test(l));
      if (hit) return Promise.resolve(hit);
      return new Promise((res, rej) => {
        waiters.push({ re, res });
        setTimeout(() => rej(new Error(`timeout waiting for ${re}`)), ms);
      });
    },
  };
}

const done = /CR160 (PHASE \S+ PASS|RESULT PASS)|EXCEPTION CAUGHT|Test failed|Some tests failed/;
async function phase(ctx, name, s, tag = name) {
  const page = await ctx.newPage();
  const w = watch(page, tag);
  await page.goto(`${base}/test/?phase=${name}${s ? `&s=${s}` : ''}`);
  return { page, w };
}
const stateOf = (w) => (w.lines.find((l) => l.startsWith('CR160 STATE ')) || '').slice(12);
async function finish(w) {
  const end = await w.wait(done);
  if (!/PASS/.test(end)) throw new Error(`failed: ${end.split('\n')[0]}`);
  return end;
}

async function semanticsText(page) {
  await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.click());
  await page.waitForTimeout(1500);
  return page.evaluate(() => {
    const host = document.querySelector('flt-semantics-host') || document.body;
    const out = [];
    host.querySelectorAll('*').forEach((e) => {
      const l = e.getAttribute('aria-label');
      if (l) out.push(l);
    });
    return out.join(' | ') + ' | ' + (host.innerText || '');
  });
}

try {
  if (scenario === 'shared') {
    const ctx = await browser.newContext();
    const page = await ctx.newPage();
    const w = watch(page, 'shared');
    await page.goto(`${base}/shared/`);
    console.log(await finish(w));
  } else if (scenario === 'flow1') {
    const ctx = await browser.newContext();
    const p1 = await phase(ctx, 'flow1');
    await finish(p1.w);
    const s = stateOf(p1.w);
    await p1.page.close();
    const p2 = await phase(ctx, 'flow1after', s); // same profile: a reload
    await finish(p2.w);
  } else if (scenario === 'flow2') {
    const dev1 = await browser.newContext();
    const p1 = await phase(dev1, 'flow2seed');
    await finish(p1.w);
    const s = stateOf(p1.w);
    await dev1.close();
    const dev2 = await browser.newContext(); // a fresh profile
    const p2 = await phase(dev2, 'flow2', s);
    await finish(p2.w);
  } else if (scenario === 'flow4') {
    const ctx = await browser.newContext();
    const p1 = await phase(ctx, 'flow4');
    await p1.w.wait(/CR160 RELOAD-NOW/);
    const s = stateOf(p1.w);
    // Leave the page mid-migration: the same tab loads again at once.
    await p1.page.goto(`${base}/test/?phase=flow4after&s=${s}`);
    const w2 = watch(p1.page, 'flow4after');
    await finish(w2);
  } else if (scenario === 'flow5') {
    const ctx = await browser.newContext();
    const p1 = await phase(ctx, 'flow5');
    await p1.w.wait(/CR160 TAB2-NOW/);
    const tab2 = await ctx.newPage();
    await tab2.goto(`${base}/app/`);
    await tab2.waitForTimeout(8000);
    const t1 = await semanticsText(tab2);
    console.log(`[tab2 while A] lockScreen=${/open in another tab/i.test(t1)} showsA=${/cr160 web tab A/.test(t1)}`);
    await p1.w.wait(/CR160 TAB2-AGAIN/);
    await tab2.reload();
    await tab2.waitForTimeout(8000);
    const t2 = await semanticsText(tab2);
    console.log(`[tab2 while B] lockScreen=${/open in another tab/i.test(t2)} showsA=${/cr160 web tab A/.test(t2)}`);
    await finish(p1.w);
    if (!/open in another tab/i.test(t1) || /cr160 web tab A/.test(t1 + t2)) throw new Error('second tab check failed');
  }
  console.log(`SCENARIO ${scenario} PASS`);
} catch (e) {
  console.log(`SCENARIO ${scenario} FAIL ${e.message}`);
  process.exitCode = 1;
} finally {
  await browser.close();
}
