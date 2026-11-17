// CR-160 B8 on the web (docs/cr-160-multipart-export.md §7): runs a build
// of integration_test/cr160_measure_web_test.dart in a fresh Chromium
// profile and samples the tab while each announced step runs
// (`CR160_STEP begin|end <step>`): the JS heap from the DevTools protocol
// every 100 ms and the renderer processes' resident memory from `ps`.
// Local only. Usage: node tool/cr160/web_measure.mjs <baseUrl>
import { chromium } from '../a11y/node_modules/playwright/index.mjs';
import { execFileSync } from 'node:child_process';

const [baseUrl] = process.argv.slice(2);
const mb = (b) => (b / (1024 * 1024)).toFixed(1);

const browser = await chromium.launch({ headless: true });
console.log(`browser chromium ${browser.version()}`);
const page = await browser.newPage({ viewport: { width: 1280, height: 800 } });
const cdp = await page.context().newCDPSession(page);
await cdp.send('Performance.enable');
const root = await browser.newBrowserCDPSession();

async function rendererRss() {
  const { processInfo } = await root.send('SystemInfo.getProcessInfo');
  const pids = processInfo.filter((p) => p.type === 'renderer').map((p) => String(p.id));
  if (pids.length === 0) return 0;
  const out = execFileSync('ps', ['-o', 'rss=', '-p', pids.join(',')]).toString();
  return out.split('\n').filter(Boolean).reduce((n, k) => n + Number(k) * 1024, 0);
}

let sample = { heap: 0, rss: 0 };
let step = null;
let result = null;
const sampler = setInterval(async () => {
  try {
    const { metrics } = await cdp.send('Performance.getMetrics');
    const heap = metrics.find((m) => m.name === 'JSHeapUsedSize')?.value ?? 0;
    sample = { heap, rss: await rendererRss() };
    if (step) {
      step.heapPeak = Math.max(step.heapPeak, sample.heap);
      step.rssPeak = Math.max(step.rssPeak, sample.rss);
    }
  } catch {
    // The page may be busy or gone; the next tick tries again.
  }
}, 100);

page.on('console', (m) => {
  const t = m.text();
  const begin = /CR160_STEP begin (.+)/.exec(t);
  const end = /CR160_STEP end (.+) took=(\d+)ms/.exec(t);
  if (begin) {
    step = { name: begin[1], heap0: sample.heap, rss0: sample.rss, heapPeak: sample.heap, rssPeak: sample.rss };
  } else if (end && step) {
    console.log(
      `CR160_MEASURE web ${step.name} took=${end[2]}ms ` +
        `heapPeak=${mb(step.heapPeak)}MB heapAboveStart=${mb(step.heapPeak - step.heap0)}MB ` +
        `rendererRssPeak=${mb(step.rssPeak)}MB rssAboveStart=${mb(step.rssPeak - step.rss0)}MB`,
    );
    step = null;
  } else if (/CR160_MEASURE|EXCEPTION|Some tests failed|All tests passed/.test(t)) {
    console.log(t.split('\n').slice(0, 6).join('\n'));
  }
  if (/All tests passed/.test(t)) result = 'PASS';
  if (/Some tests failed|EXCEPTION CAUGHT/.test(t)) result ??= 'FAIL';
});
page.on('pageerror', (e) => console.log(`pageerror ${e.message}`));
await page.goto(baseUrl);
const deadline = Date.now() + 30 * 60_000;
while (result === null && Date.now() < deadline) await page.waitForTimeout(1000);
clearInterval(sampler);
await browser.close();
console.log(`RESULT ${result ?? 'TIMEOUT'}`);
process.exit(result === 'PASS' ? 0 : 1);
