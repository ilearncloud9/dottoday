// The first slice's journey on the web (docs/09 M19.7): drives a build of
// integration_test/slice_journey_test.dart (built with
// --dart-define=SWEEP_HOST_SHOTS=true) in Playwright's Chromium or WebKit
// (Safari's engine) at one width, and saves each `SWEEP_SHOT <name>` as
// app/build/slice/web_<browser>_<width>_<name>.png. Local only.
// Usage: node tool/slice/web_journey.mjs <baseUrl> <compact|expanded> <chromium|webkit>
import { mkdirSync } from 'node:fs';

// tool/a11y's Playwright (`npm ci` there), or PLAYWRIGHT=<path to its
// index.mjs> from another checkout.
const { chromium, webkit } = await import(
  process.env.PLAYWRIGHT ?? '../a11y/node_modules/playwright/index.mjs'
);

const [baseUrl, width = 'expanded', engine = 'chromium'] = process.argv.slice(2);
const sizes = { compact: { width: 390, height: 844 }, expanded: { width: 1280, height: 800 } };
const out = new URL('../../app/build/slice/', import.meta.url).pathname;
mkdirSync(out, { recursive: true });

const browser = await (engine === 'webkit' ? webkit : chromium).launch({ headless: true });
console.log(`browser ${engine} ${browser.version()} ${width}`);
const page = await browser.newPage({ viewport: sizes[width] });
let pending = Promise.resolve();
let result = null;
page.on('console', (m) => {
  const t = m.text();
  const shot = /SWEEP_SHOT (\w+)/.exec(t);
  if (shot) {
    // The test holds still for about 4 s after announcing a shot.
    const name = `web_${engine}_${width}_${shot[1]}`;
    pending = pending.then(async () => {
      await page.waitForTimeout(800);
      await page.screenshot({ path: `${out}${name}.png` });
      console.log(`saved ${name}`);
    });
  }
  if (process.env.ALL || /STOPPED|EXCEPTION|Expected|timed out|Some tests failed|All tests passed/.test(t)) {
    console.log(t.split('\n').slice(0, 8).join('\n'));
  }
  if (/All tests passed/.test(t)) result = 'PASS';
  if (/Some tests failed|EXCEPTION CAUGHT/.test(t)) result ??= 'FAIL';
});
page.on('pageerror', (e) => console.log(`pageerror ${e.message}`));
await page.goto(baseUrl);
const end = Date.now() + 10 * 60_000;
while (result === null && Date.now() < end) await page.waitForTimeout(1000);
await pending;
await browser.close();
console.log(`RESULT ${result ?? 'TIMEOUT'}`);
process.exit(result === 'PASS' ? 0 : 1);
