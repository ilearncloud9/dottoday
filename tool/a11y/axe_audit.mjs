// axe-core scan of the Flutter web build (docs/08 §3 "axe-core on web build", R-12).
//
// Flutter web paints to a canvas; the accessible DOM (<flt-semantics>) only exists once
// semantics are enabled, which a screen reader does via the hidden
// <flt-semantics-placeholder>. We click it the same way, then scan compact and
// expanded layouts. Usage: node axe_audit.mjs [baseUrl]
import AxeBuilder from '@axe-core/playwright';
import { chromium } from 'playwright';

const baseUrl = process.argv[2] ?? 'http://127.0.0.1:8080/';
const viewports = [
  { name: 'compact', width: 400, height: 800 },
  { name: 'expanded', width: 1000, height: 700 },
];
const tags = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'];

async function enableFlutterSemantics(page) {
  const placeholder = page.locator('flt-semantics-placeholder');
  await placeholder.waitFor({ state: 'attached', timeout: 60_000 });
  await placeholder.evaluate((el) => el.click());
  await page.locator('flt-semantics').first().waitFor({ state: 'attached', timeout: 30_000 });
  await page.waitForTimeout(500); // let the semantics tree settle
}

async function scan(browser, viewport) {
  // @axe-core/playwright needs pages from an explicit context.
  const context = await browser.newContext({ viewport });
  const page = await context.newPage();
  await page.goto(baseUrl);
  await enableFlutterSemantics(page);
  const nodes = await page.locator('flt-semantics').count();
  const { violations } = await new AxeBuilder({ page }).withTags(tags).analyze();
  await context.close();
  return { nodes, violations };
}

const browser = await chromium.launch();
let failed = false;
for (const viewport of viewports) {
  const { nodes, violations } = await scan(browser, viewport);
  console.log(`[${viewport.name}] ${nodes} semantics nodes, ${violations.length} violation(s)`);
  for (const v of violations) {
    console.log(`  ✗ ${v.id} (${v.impact}): ${v.help} — ${v.nodes.length} node(s)`);
    for (const n of v.nodes.slice(0, 3)) console.log(`      ${n.target.join(' ')}`);
  }
  if (nodes === 0) {
    console.log('  ✗ no semantics nodes: scan would be vacuous');
    failed = true;
  }
  failed ||= violations.length > 0;
}
await browser.close();
process.exit(failed ? 1 : 0);
