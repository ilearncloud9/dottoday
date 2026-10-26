// Design sweep on the web build (docs/08 §7, docs/09 M11.6): every main
// screen and the M11, M12 and M13 screens at the compact and expanded widths, light and
// dark (prefers-color-scheme), saved to app/build/sweep/web_<theme>_<width>_<shot>.png.
// Needs a debug web build (the demo data lives in the debug menu), e.g.
// `flutter run -d web-server --web-port 8099 --dart-define-from-file=.env.example`.
// Usage: node web_sweep.mjs [baseUrl]
import { chromium } from 'playwright';
import { mkdirSync } from 'node:fs';

const baseUrl = process.argv[2] ?? 'http://127.0.0.1:8099/';
const out = new URL('../../app/build/sweep/', import.meta.url).pathname;
mkdirSync(out, { recursive: true });
const viewports = [
  { name: 'compact', width: 390, height: 844 },
  { name: 'expanded', width: 1280, height: 800 },
];

async function enableSemantics(page) {
  const placeholder = page.locator('flt-semantics-placeholder');
  await placeholder.waitFor({ state: 'attached', timeout: 120_000 });
  await placeholder.evaluate((el) => el.click());
  await page.locator('flt-semantics').first().waitFor({ state: 'attached', timeout: 30_000 });
  await page.waitForTimeout(500);
}

async function tap(page, name, { role = 'button', exact = true } = {}) {
  const target = page.getByRole(role, { name, exact }).first();
  await target.waitFor({ state: 'attached', timeout: 30_000 });
  await target.click();
  await page.waitForTimeout(900);
}

// Flutter's semantics name a thing by its role: try menu item, button,
// tab and plain text, whichever exists first.
async function tapText(page, text) {
  const candidates = [
    page.getByRole('menuitem', { name: text, exact: true }),
    page.getByRole('button', { name: text, exact: true }),
    page.getByRole('tab', { name: text, exact: true }),
    page.getByText(text, { exact: true }),
  ];
  const end = Date.now() + 30_000;
  while (Date.now() < end) {
    for (const c of candidates) {
      if ((await c.count()) > 0) {
        await c.first().click();
        await page.waitForTimeout(900);
        return;
      }
    }
    await page.waitForTimeout(500);
  }
  throw new Error(`nothing called "${text}"`);
}

async function go(page, route) {
  await page.evaluate((r) => { window.location.hash = r; }, route);
  await page.waitForTimeout(2_000);
}

const failures = [];
const browser = await chromium.launch({ executablePath: process.env.CHROMIUM_PATH });
for (const theme of ['light', 'dark']) {
  for (const vp of viewports) {
    const tag = `web_${theme}_${vp.name}`;
    const context = await browser.newContext({ viewport: vp, colorScheme: theme });
    const page = await context.newPage();
    page.on('pageerror', (e) => failures.push(`${tag}: ${e}`));
    const shot = (name) => page.screenshot({ path: `${out}${tag}_${name}.png` });
    try {
      await page.goto(baseUrl);
      await enableSemantics(page);
      for (const name of ['Get started', 'Continue', 'Continue', 'Not now',
        'Continue without an account', 'Open today']) {
        await tap(page, name);
      }
      await tap(page, 'More options');
      await tapText(page, 'Load demo day (debug)');
      await page.waitForTimeout(5_000);
      await tap(page, 'More options');
      await tapText(page, 'Load M11 sample (debug)');
      await page.waitForTimeout(5_000);
      await shot('today');
      await tapText(page, 'Reality');
      await shot('reality');
      await tapText(page, 'Plan');
      await go(page, '/inbox');
      await shot('inbox');
      if (vp.name === 'expanded') {
        await go(page, '/week');
        await shot('week');
      }
      await go(page, '/search');
      await shot('search');
      await go(page, '/settings');
      await shot('settings');
      await go(page, '/settings/routines');
      await shot('routines');
      await tapText(page, 'Drop on today');
      await shot('routine_drop');
      await tapText(page, 'Discard');
      await tapText(page, 'Edit');
      await shot('routine_editor');
      // M12: This week, low-energy mode, Past days, Brain dump. A reload
      // between them clears any sheet or dialog (the data stays local).
      const fresh = async (route) => {
        await page.goto(`${baseUrl}#${route}`);
        await page.reload();
        await enableSemantics(page);
        await page.waitForTimeout(2_000);
      };
      await fresh('/today');
      await tap(page, 'More options');
      await tapText(page, 'This week');
      await page.waitForTimeout(1_500);
      await shot('week_review');
      await fresh('/today');
      await tap(page, 'More options');
      await tapText(page, 'Low-energy mode');
      await page.waitForTimeout(2_000);
      await shot('low_energy');
      await tap(page, 'More options');
      await tapText(page, 'Turn off low-energy mode');
      await fresh('/search');
      await page.getByRole('textbox').first().fill('').catch(() => {});
      await page.waitForTimeout(900);
      // Its name is the title and the line under it.
      await page.getByRole('button', { name: /^Past days/ }).first().click();
      await page.waitForTimeout(1_500);
      await shot('past_days');
      await fresh('/today');
      await tap(page, 'More options');
      await tapText(page, 'Brain dump');
      const dump = ['Email Sam', 'Taxes 45m', 'Call the bank 4pm'];
      // The field has the focus at every width (popover_focus_check.mjs).
      await page.waitForTimeout(1_200);
      for (const [i, line] of dump.entries()) {
        if (i > 0) await page.keyboard.press('Enter');
        await page.keyboard.type(line);
      }
      await page.waitForTimeout(900);
      await shot('brain_dump');
      await tapText(page, 'Plan it');
      await page.waitForTimeout(2_000);
      await shot('brain_dump_proposal');
      await tapText(page, 'Discard');
      // M13 (docs/13 §11): Settings › Learning, and a learned value's
      // explanation open on the reality thread.
      await fresh('/settings');
      await page.getByText('LEARNING').first().scrollIntoViewIfNeeded();
      await page.waitForTimeout(900);
      await shot('settings_learning');
      await fresh('/today');
      await tapText(page, 'Reality');
      await page.getByRole('button', { name: /learned from your history$/ })
        .first().click();
      await page.waitForTimeout(900);
      await shot('learned_explained');
      console.log(`PASS ${tag}`);
    } catch (e) {
      failures.push(`${tag}: ${e.message.split('\n')[0]}`);
      await shot('failed').catch(() => {});
      console.log(`FAIL ${tag}`);
    }
    await context.close();
  }
}
await browser.close();
for (const f of failures) console.log(f);
process.exit(failures.length === 0 ? 0 : 1);
