// PWA checks on the web build in real Chromium (docs/07 Web, docs/09 M5.7):
// - no Content-Security-Policy violation while the app starts and runs;
// - the service worker registers and controls the page;
// - after one online visit the app opens with the network off (local-first);
// - a first visit with the network off gets offline.html.
// Usage: node pwa_check.mjs [baseUrl]
import { chromium } from 'playwright';

const baseUrl = process.argv[2] ?? 'http://127.0.0.1:8080/';
// PLAYWRIGHT_CHROMIUM: a local Chromium for runs without Playwright's own.
const browser = await chromium.launch(
  process.env.PLAYWRIGHT_CHROMIUM ? { executablePath: process.env.PLAYWRIGHT_CHROMIUM } : {},
);
const failures = [];
const fail = (m) => { failures.push(m); console.log(`  ✗ ${m}`); };
const ok = (m) => console.log(`  ✓ ${m}`);

async function flutterShown(page) {
  try {
    await page.locator('flutter-view, flt-glass-pane').first().waitFor({ state: 'attached', timeout: 60_000 });
    return true;
  } catch { return false; }
}

// 1-3: one online visit, then offline.
{
  const context = await browser.newContext();
  const page = await context.newPage();
  const violations = [];
  // flutter-view attaches before main() runs, so it alone can't tell a
  // started app from one that threw on start (found in M8.5: a build whose
  // env failed to load still "opened offline").
  const pageErrors = [];
  page.on('pageerror', (e) => pageErrors.push(e.message));
  page.on('console', (m) => { if (/Content Security Policy|Refused to/.test(m.text())) violations.push(m.text()); });
  await page.goto(baseUrl);
  if (!(await flutterShown(page))) fail('app did not start online');
  await page.evaluate(() => navigator.serviceWorker.ready);
  if (!(await page.evaluate(() => !!navigator.serviceWorker.controller))) {
    await page.reload();
    await flutterShown(page);
  }
  const controlled = await page.evaluate(() => !!navigator.serviceWorker.controller);
  controlled ? ok('service worker controls the page') : fail('service worker does not control the page');
  // The page hands the worker what it loaded (register_sw.js); wait for it.
  // A poll, not waitForFunction: that takes a returned Promise as truthy.
  const cached = () => page.evaluate(async () => {
    const c = await caches.open('dottoday-shell-v1');
    return !!(await c.match('main.dart.js')) && !!(await c.match('./'));
  });
  for (let i = 0; i < 60 && !(await cached()); i++) await page.waitForTimeout(500);
  violations.length === 0 ? ok('no CSP violations') : fail(`CSP violations: ${violations.slice(0, 3).join(' | ')}`);
  await context.setOffline(true);
  await page.reload();
  (await flutterShown(page)) ? ok('opens offline after one visit') : fail('does not open offline after one visit');
  await page.waitForTimeout(3000);
  pageErrors.length === 0 ? ok('no uncaught errors') : fail(`uncaught errors: ${pageErrors.slice(0, 3).join(' | ')}`);
  await context.close();
}

// 4: first visit, offline. The worker isn't installed yet, so the browser's
// own error page shows; offline.html is precached on install and served
// once a worker exists but the shell isn't cached. Check that path: install
// the worker on a blank page, then go offline before loading the app.
{
  const context = await browser.newContext();
  const page = await context.newPage();
  await page.goto(new URL('offline.html', baseUrl).href);
  await page.evaluate(() => navigator.serviceWorker.register('sw.js').then(() => navigator.serviceWorker.ready));
  await context.setOffline(true);
  await page.goto(new URL('./?first', baseUrl).href).catch(() => {});
  const title = await page.title().catch(() => '');
  title.includes('Offline') ? ok('offline.html when nothing is cached') : fail(`expected offline.html, got "${title}"`);
  await context.close();
}

await browser.close();
process.exit(failures.length ? 1 : 0);
