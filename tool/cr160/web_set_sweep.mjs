// CR-160 B7 gate on the web (docs/cr-160-multipart-export.md): drives a
// build of integration_test/cr160_set_sweep_test.dart (built with
// --dart-define=SWEEP_HOST_SHOTS=true and the local-stack defines) in
// Playwright's Chromium and saves each `SWEEP_SHOT <name>` the test
// announces, at one width and theme per run. Local only.
// Usage: node tool/cr160/web_set_sweep.mjs <baseUrl> <compact|expanded> <light|dark>
import { chromium } from '../a11y/node_modules/playwright/index.mjs';
import { mkdirSync } from 'node:fs';

const [baseUrl, width = 'compact', theme = 'light'] = process.argv.slice(2);
const sizes = { compact: { width: 390, height: 844 }, expanded: { width: 1280, height: 800 } };
const out = new URL('../../app/build/sweep/', import.meta.url).pathname;
mkdirSync(out, { recursive: true });

const browser = await chromium.launch({ headless: true });
console.log(`browser chromium ${browser.version()} ${width} ${theme}`);
const page = await browser.newPage({ viewport: sizes[width], colorScheme: theme });
let pending = Promise.resolve();
let result = null;
page.on('console', (m) => {
  const t = m.text();
  const shot = /SWEEP_SHOT (\w+)/.exec(t);
  if (shot) {
    // The test holds still for about 4 s after announcing a shot.
    const name = shot[1].replace(/^web(_dark)?_/, `web$1_${width}_`);
    pending = pending.then(async () => {
      await page.waitForTimeout(800);
      await page.screenshot({ path: `${out}${name}.png` });
      console.log(`saved ${name}`);
    });
  }
  if (process.env.ALL || /A11Y|CR160|EXCEPTION|timed out|Some tests failed|All tests passed/.test(t)) {
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
