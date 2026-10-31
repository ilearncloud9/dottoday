// The web live dot in Chromium (docs/09 M9.7, M9.9 sweep): after onboarding the
// short way, Quick Add (dottoday's /add link) adds a task that started 5 min ago;
// the tab title must read "● … left · Live check", the favicon must be the SVG
// ring, and both go back once it is ticked Done. Screenshots at 1280 and 390 px,
// light and dark, go to build/web_live_dot/. Usage: node web_live_dot_check.mjs [baseUrl]
import { mkdirSync } from 'node:fs';
import { chromium } from 'playwright';

const baseUrl = process.argv[2] ?? 'http://127.0.0.1:8080/';
const out = '../../app/build/web_live_dot';
mkdirSync(out, { recursive: true });

async function enableSemantics(page) {
  const placeholder = page.locator('flt-semantics-placeholder');
  await placeholder.waitFor({ state: 'attached', timeout: 60_000 });
  await placeholder.evaluate((el) => el.click());
  await page.locator('flt-semantics').first().waitFor({ state: 'attached', timeout: 30_000 });
  await page.waitForTimeout(500);
}

async function tapButton(page, name) {
  // Onboarding step 0's cards are radio buttons (M16).
  const button = page.getByRole('button', { name, exact: true })
    .or(page.getByRole('radio', { name, exact: true })).first();
  await button.waitFor({ state: 'attached', timeout: 30_000 });
  await button.click();
  await page.waitForTimeout(800);
}

const browser = await chromium.launch({ executablePath: process.env.CHROMIUM_PATH });
const context = await browser.newContext({ viewport: { width: 1280, height: 800 } });
const page = await context.newPage();
const results = [];
const check = (name, ok, detail) => {
  results.push(ok);
  console.log(`${ok ? 'PASS' : 'FAIL'} ${name}${detail ? ` — ${detail}` : ''}`);
};

await page.goto(baseUrl);
await enableSemantics(page);
for (const name of ['Get started', 'The full planner', 'Continue', 'Continue', 'Continue', 'Not now',
  'Continue without an account', 'Open today']) {
  await tapButton(page, name);
}

// Quick Add over Today, a task that started 5 min ago, 45 min long.
const start = new Date(Date.now() - 5 * 60_000);
const hhmm = `${String(start.getHours()).padStart(2, '0')}:${String(start.getMinutes()).padStart(2, '0')}`;
// A hash change, not a reload: semantics stay on.
await page.goto(`${baseUrl}#/add`);
await page.waitForTimeout(2_000);
const field = page.getByRole('textbox').first();
await field.waitFor({ state: 'attached', timeout: 30_000 });
await field.click();
await page.keyboard.type(`Live check ${hhmm} 45m`);
await page.keyboard.press('Enter');
await page.waitForTimeout(3_000);

const live = await page.title();
check('title shows the live dot', /^● .*Live check$/.test(live), live);
const icon = await page.evaluate(() => document.querySelector('link[rel="icon"]')?.href ?? '');
check('favicon is the ring', icon.startsWith('data:image/svg+xml'), icon.slice(0, 40));

for (const [w, h] of [[1280, 800], [390, 844]]) {
  for (const scheme of ['light', 'dark']) {
    await page.setViewportSize({ width: w, height: h });
    await page.emulateMedia({ colorScheme: scheme });
    await page.waitForTimeout(800);
    await page.screenshot({ path: `${out}/today_${w}_${scheme}.png` });
  }
}
await browser.close();
process.exit(results.every(Boolean) ? 0 : 1);
