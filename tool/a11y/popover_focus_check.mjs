// Popover fields take keys at once on the web build in Chromium (M12 follow-up):
// open Add and Brain dump at the compact and expanded widths and type without
// clicking into the field first; the text must land in the field. Brain dump
// opens from Today's ⋯ menu, whose closing used to drop the browser's focus
// and leave the field with a caret but no keys. Semantics are on so the menu
// is driven like a screen reader would. Usage: node popover_focus_check.mjs [baseUrl]
import { chromium } from 'playwright';

const baseUrl = process.argv[2] ?? 'http://127.0.0.1:8080/';
const viewports = [
  { name: 'compact', width: 390, height: 844, add: 'Add task' },
  { name: 'expanded', width: 1280, height: 800, add: 'Add to this day' },
];

async function enableSemantics(page) {
  const placeholder = page.locator('flt-semantics-placeholder');
  await placeholder.waitFor({ state: 'attached', timeout: 60_000 });
  await placeholder.evaluate((el) => el.click());
  await page.locator('flt-semantics').first().waitFor({ state: 'attached', timeout: 30_000 });
  await page.waitForTimeout(500);
}

async function tap(page, name, role = 'button') {
  const target = page.getByRole(role, { name, exact: true }).first();
  await target.waitFor({ state: 'attached', timeout: 30_000 });
  await target.click();
  await page.waitForTimeout(800);
}

// Onboarding O1–O6 the short way: no permission, no account.
async function passOnboarding(page) {
  for (const name of ['Get started', 'Continue', 'Continue', 'Not now',
    'Continue without an account', 'Open today']) {
    await tap(page, name);
  }
}

async function fresh(page) {
  await page.reload();
  await page.locator('flutter-view').waitFor({ state: 'attached', timeout: 60_000 });
  await page.waitForTimeout(4_000); // first frame, the day loaded
  await enableSemantics(page);
}

// What the browser's focused element holds after typing: the field's own
// text when the keys arrived, anything else when they went nowhere.
async function typedInto(page, text) {
  await page.waitForTimeout(1_200); // the popover's entrance and the menu's exit
  await page.keyboard.type(text);
  await page.waitForTimeout(400);
  return page.evaluate(() => {
    const a = document.activeElement;
    return a && 'value' in a ? a.value : `<${a?.tagName.toLowerCase()}>`;
  });
}

// CHROMIUM_PATH: an already-installed headless shell when the lockfile's
// Playwright build isn't downloaded on this machine.
const browser = await chromium.launch({ executablePath: process.env.CHROMIUM_PATH });
const results = [];
const check = (name, ok, detail) => {
  results.push(ok);
  console.log(`${ok ? 'PASS' : 'FAIL'} ${name}${detail ? ` — ${detail}` : ''}`);
};

for (const vp of viewports) {
  const page = await browser.newPage({ viewport: { width: vp.width, height: vp.height } });
  const errors = [];
  page.on('pageerror', (e) => errors.push(String(e)));
  await page.goto(baseUrl);
  await enableSemantics(page);
  await passOnboarding(page);

  await fresh(page);
  await tap(page, vp.add);
  const add = await typedInto(page, 'Call the bank');
  check(`${vp.name}: Add takes keys without a click`, add === 'Call the bank', `got "${add}"`);

  await fresh(page);
  await tap(page, 'More options');
  await tap(page, 'Brain dump', 'menuitem');
  const dump = await typedInto(page, 'Email Sam');
  check(`${vp.name}: Brain dump takes keys without a click`, dump === 'Email Sam', `got "${dump}"`);
  await page.screenshot({ path: `build/popover_focus_${vp.name}.png` });

  check(`${vp.name}: no uncaught page error`, errors.length === 0, errors.join('; '));
  await page.close();
}

await browser.close();
process.exit(results.every(Boolean) ? 0 : 1);
