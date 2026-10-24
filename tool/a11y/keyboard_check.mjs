// Keyboard checks on the web build in Chromium (docs/08 §6.2, M8.7): on a fresh
// load after onboarding the first Tab lands on "Skip to content", Enter moves
// focus past the rail, and Ctrl+/ (⌘/ on a Mac) opens the shortcut list.
// What this cannot show: which shortcuts a real Chrome window keeps for itself
// (⌘N, ⌘T, ⌘1–4) — Playwright's keys reach the page, not the browser's menus;
// that stays a person's check (08 §6.1). Usage: node keyboard_check.mjs [baseUrl]
import { chromium } from 'playwright';

const baseUrl = process.argv[2] ?? 'http://127.0.0.1:8080/';

async function enableSemantics(page) {
  const placeholder = page.locator('flt-semantics-placeholder');
  await placeholder.waitFor({ state: 'attached', timeout: 60_000 });
  await placeholder.evaluate((el) => el.click());
  await page.locator('flt-semantics').first().waitFor({ state: 'attached', timeout: 30_000 });
  await page.waitForTimeout(500);
}

async function tapButton(page, name) {
  const button = page.getByRole('button', { name, exact: true }).first();
  await button.waitFor({ state: 'attached', timeout: 30_000 });
  await button.click();
  await page.waitForTimeout(800);
}

// Onboarding O1–O6 the short way: no permission, no account.
async function passOnboarding(page) {
  for (const name of ['Get started', 'Continue', 'Continue', 'Not now',
    'Continue without an account', 'Open today']) {
    await tapButton(page, name);
  }
}

// CHROMIUM_PATH: an already-installed headless shell when the lockfile's
// Playwright build isn't downloaded on this machine.
const browser = await chromium.launch({ executablePath: process.env.CHROMIUM_PATH });
const page = await browser.newPage({ viewport: { width: 1280, height: 800 } });
const errors = [];
page.on('pageerror', (e) => errors.push(String(e)));
const results = [];
const check = (name, ok, detail) => {
  results.push({ name, ok });
  console.log(`${ok ? 'PASS' : 'FAIL'} ${name}${detail ? ` — ${detail}` : ''}`);
};

await page.goto(baseUrl);
await enableSemantics(page);
await passOnboarding(page);
await page.getByRole('button', { name: 'Settings' }).first()
  .waitFor({ state: 'attached', timeout: 30_000 });

// A keyboard user without a screen reader: Flutter's own focus traversal
// handles Tab, so each step runs on a fresh load with semantics off, and
// semantics are switched on only afterwards to read what is on screen.
async function freshLoad() {
  await page.reload();
  await page.locator('flutter-view').waitFor({ state: 'attached', timeout: 60_000 });
  await page.waitForTimeout(4_000); // first frame, the day loaded
}
const present = (locator) => locator.first()
  .waitFor({ state: 'attached', timeout: 5_000 }).then(() => true, () => false);

await freshLoad();
await page.keyboard.press('Tab');
await page.waitForTimeout(400);
await enableSemantics(page);
const skip = page.getByRole('button', { name: 'Skip to content' });
check('first Tab shows "Skip to content"', await present(skip));

// Enter on the link, then Tab: the next stop is in the page, not the rail.
// Read from pixels (semantics off): the rail strip looks as it did before
// any key — no link, no focus ring there — while the page shows a ring.
const railClip = { x: 0, y: 0, width: 80, height: 800 };
const pageClip = { x: 80, y: 0, width: 1200, height: 800 };
await freshLoad();
const railBefore = await page.screenshot({ clip: railClip });
const pageBefore = await page.screenshot({ clip: pageClip });
await page.keyboard.press('Tab');
await page.waitForTimeout(300);
await page.keyboard.press('Enter');
await page.waitForTimeout(400);
await page.keyboard.press('Tab');
await page.waitForTimeout(400);
await page.screenshot({ path: 'build/keyboard_check_after_skip.png' });
const railAfter = await page.screenshot({ clip: railClip });
const pageAfter = await page.screenshot({ clip: pageClip });
check('Enter on the link moves Tab past the rail',
  railBefore.equals(railAfter) && !pageBefore.equals(pageAfter),
  'rail unchanged, focus ring in the page (build/keyboard_check_after_skip.png)');

await freshLoad();
await page.keyboard.press('ControlOrMeta+Slash');
await page.waitForTimeout(800);
await enableSemantics(page);
check('Ctrl/⌘+/ opens the shortcut list', await present(page.getByText('Keyboard shortcuts')));
check('no uncaught page error', errors.length === 0, errors.join('; '));

await page.screenshot({ path: 'build/keyboard_check.png' });
await browser.close();
process.exit(results.every((r) => r.ok) ? 0 : 1);
