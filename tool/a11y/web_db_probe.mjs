// Checks the encrypted web database in a real browser (docs/09 M2.9, ADR-0003):
// loads the probe build (app/tool/web_db_probe.dart), waits for its verdict, then scans
// every OPFS file, IndexedDB value, Cache Storage entry (the day snapshot, M9.1) and
// localStorage value for the plaintext task title it wrote, and checks that a second tab is
// refused.
// Lives here to reuse this folder's lockfile-pinned Playwright.
// Usage: node web_db_probe.mjs [baseUrl]
import { chromium } from 'playwright';

const baseUrl = process.argv[2] ?? 'http://127.0.0.1:8081/';
const secret = 'm29-probe-secret-title';

const browser = await chromium.launch();
// One context = one storage partition, like two tabs of one browser profile. Separate
// browser.newPage() calls would each get their own storage and Web Locks.
const context = await browser.newContext();
const page = await context.newPage();
page.on('console', (m) => console.log(`[page] ${m.text()}`));
page.on('pageerror', (e) => console.log(`[page error] ${e}`));
page.on('requestfailed', (r) => console.log(`[request failed] ${r.url()} ${r.failure()?.errorText}`));
page.on('worker', (w) => console.log(`[worker] ${w.url()}`));
await page.goto(baseUrl);
try {
  await page.waitForFunction(() => document.title.startsWith('PROBE:'), null, { timeout: 120_000 });
} catch (e) {
  // The probe writes PROBE-STEP markers; the last one shows where it stalled.
  console.error(`::error::Probe gave no verdict; last title: ${await page.title()}`);
  await browser.close();
  process.exit(1);
}
const verdict = await page.title();
console.log(verdict);
if (!verdict.startsWith('PROBE:OK')) {
  await browser.close();
  process.exit(1);
}

const scan = await page.evaluate(async (needle) => {
  const pattern = new TextEncoder().encode(needle);
  const hits = [];
  let bytes = 0;
  const contains = (u8) => {
    outer: for (let i = 0; i <= u8.length - pattern.length; i++) {
      for (let j = 0; j < pattern.length; j++) if (u8[i + j] !== pattern[j]) continue outer;
      return true;
    }
    return false;
  };
  const check = (u8, where) => {
    bytes += u8.length;
    if (contains(u8)) hits.push(where);
  };
  async function walkOpfs(dir, path) {
    for await (const [name, handle] of dir.entries()) {
      if (handle.kind === 'file') {
        check(new Uint8Array(await (await handle.getFile()).arrayBuffer()), `opfs:${path}${name}`);
      } else {
        await walkOpfs(handle, `${path}${name}/`);
      }
    }
  }
  async function scanValue(value, where) {
    if (value == null) return;
    if (typeof value === 'string') return check(new TextEncoder().encode(value), where);
    if (value instanceof Blob) return check(new Uint8Array(await value.arrayBuffer()), where);
    if (value instanceof ArrayBuffer) return check(new Uint8Array(value), where);
    if (ArrayBuffer.isView(value)) {
      return check(new Uint8Array(value.buffer, value.byteOffset, value.byteLength), where);
    }
    if (typeof value === 'object') {
      for (const [k, v] of Object.entries(value)) await scanValue(v, `${where}.${k}`);
    }
  }
  const request = (r) => new Promise((ok, err) => { r.onsuccess = () => ok(r.result); r.onerror = () => err(r.error); });
  try {
    await walkOpfs(await navigator.storage.getDirectory(), '/');
  } catch (e) {
    console.log(`OPFS unavailable: ${e}`);
  }
  for (const { name } of await indexedDB.databases()) {
    const db = await request(indexedDB.open(name));
    for (const store of db.objectStoreNames) {
      const values = await request(db.transaction(store, 'readonly').objectStore(store).getAll());
      for (const [i, v] of values.entries()) await scanValue(v, `idb:${name}/${store}[${i}]`);
    }
    db.close();
  }
  for (const name of await caches.keys()) {
    const cache = await caches.open(name);
    for (const req of await cache.keys()) {
      const res = await cache.match(req);
      check(new Uint8Array(await res.arrayBuffer()), `cache:${name}${new URL(req.url).pathname}`);
    }
  }
  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i);
    check(new TextEncoder().encode(localStorage.getItem(key)), `localStorage:${key}`);
  }
  return { bytes, hits };
}, secret);

// Report every result before deciding, so a failed run still shows them all.
const failures = [];
console.log(`plaintext scan: ${scan.bytes} bytes of browser storage, ${scan.hits.length} plaintext hits`);
for (const hit of scan.hits) console.log(`  plaintext hit: ${hit}`);
// A database page is 4 KiB; less means the scan didn't see the database at all.
if (scan.bytes < 4096) failures.push('Scan found no database storage; the check would pass vacuously.');
if (scan.hits.length > 0) failures.push(`Plaintext task title in browser storage: ${scan.hits.join(', ')}`);

// A second tab of the same profile must be refused while the first holds the database.
const second = await context.newPage();
await second.goto(baseUrl);
await second.waitForFunction(() => document.title.startsWith('PROBE:'), null, { timeout: 120_000 });
const secondVerdict = await second.title();
console.log(`second tab: ${secondVerdict}`);
if (!secondVerdict.includes('openInAnotherTab')) {
  failures.push('A second tab opened the database; the tab lock is not working.');
}

await browser.close();
for (const f of failures) console.error(`::error::${f}`);
process.exit(failures.length > 0 ? 1 : 0);
