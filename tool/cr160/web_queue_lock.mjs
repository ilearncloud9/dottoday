// CR-160 I7 in a real browser: a real service worker running the shipped
// app/web/action_queue.js appends while the tab removes, both through Cache
// Storage and the Web Lock 'dottoday-action-queue'. With the lock nothing is
// lost; the control (tab without the lock) shows what it prevents. Also: the
// worker refuses while an account is being deleted.
//
//   [PLAYWRIGHT=<path to playwright/index.mjs>] node tool/cr160/web_queue_lock.mjs
//
// Uses the tool/a11y Playwright install (no new dependency).
import { createServer } from 'node:http';
import { readFileSync, existsSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const { chromium } = await import(
  process.env.PLAYWRIGHT ?? join(here, '../a11y/node_modules/playwright/index.mjs')
);
const files = {
  '/': join(here, 'web_lock_page/index.html'),
  '/sw.js': join(here, 'web_lock_page/sw.js'),
  '/action_queue.js': join(here, '../../app/web/action_queue.js'),
};
const server = createServer((req, res) => {
  const path = files[req.url.split('?')[0]];
  if (!path || !existsSync(path)) { res.writeHead(404); res.end(); return; }
  res.writeHead(200, { 'content-type': path.endsWith('.html') ? 'text/html' : 'text/javascript' });
  res.end(readFileSync(path));
});
await new Promise((r) => server.listen(0, '127.0.0.1', r));
const origin = `http://localhost:${server.address().port}/`;
const browser = await chromium.launch();
let failed = false;
try {
  const page = await (await browser.newContext()).newPage();
  await page.goto(origin);
  await page.evaluate(() => window.ready);
  const owner = { v: 1, owner: '01928c3e-0000-7000-8000-00000000000a' };
  const locked = await page.evaluate((m) => window.runScenario(true, m), owner);
  console.log('with the lock   ', JSON.stringify(locked));
  const control = await page.evaluate((m) => window.runScenario(false, m), owner);
  console.log('control, no lock', JSON.stringify(control));
  const refusing = await page.evaluate(() => window.runScenario(true, { v: 1, refuse: true }));
  console.log('while deleting  ', JSON.stringify(refusing));
  const ok =
    locked.workerEntries === 120 && locked.seedsLeft === 0 && locked.refused === 0 &&
    locked.owners.length === 1 && locked.owners[0] === owner.owner &&
    refusing.refused === 120 && refusing.total === 0;
  failed = !ok;
  console.log(`WEB QUEUE LOCK (${browser.version()}): ${ok ? 'PASS' : 'FAIL'}`);
} finally {
  await browser.close();
  server.close();
}
process.exit(failed ? 1 : 0);
