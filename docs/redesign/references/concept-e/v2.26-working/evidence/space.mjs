import { createRequire } from 'module';
const require = createRequire('/Users/ops/Documents/dottoday/tool/a11y/package.json');
const { chromium } = require('playwright-core');
const exe = '/Users/ops/Library/Caches/ms-playwright/chromium_headless_shell-1248/chrome-headless-shell-mac-arm64/chrome-headless-shell';
const b = await chromium.launch({ executablePath: exe });
for (const f of process.argv.slice(2)) {
  const p = await b.newPage({ viewport: { width: 3200, height: 2000 } });
  await p.goto('file://' + f); await p.waitForTimeout(800);
  const r = await p.evaluate(() => {
    const sel = 'button, a[href], input:not([type=hidden]), [role=button], [role=tab], [role=menuitem], [role=switch], [role=checkbox]';
    const T = [];
    for (const e of document.querySelectorAll(sel)) {
      if (e.closest('[aria-hidden=true]')) continue;
      let sc = 1; for (let a = e; a; a = a.parentElement) { const t = getComputedStyle(a).transform; if (t && t !== 'none') sc *= new DOMMatrix(t).a; const z = parseFloat(getComputedStyle(a).zoom || 1); if (z && z !== 1) sc *= z; }
      const bb = e.getBoundingClientRect(); if (!bb.width) continue;
      T.push({ e, sc, x: bb.x, y: bb.y, w: bb.width, h: bb.height, role: e.getAttribute('role') || e.tagName.toLowerCase(), name: (e.getAttribute('aria-label') || e.textContent || '').trim().slice(0, 34) });
    }
    const out = { small: 0, spacingOK: 0, menu: 0, fail: [] };
    for (const t of T) {
      const s = 24 * t.sc; if (Math.min(t.w, t.h) >= s - 0.5) continue;
      out.small++;
      if (t.role === 'menuitem') { out.menu++; continue; }
      const cx = t.x + t.w / 2, cy = t.y + t.h / 2, r = 12 * t.sc;
      let clash = null;
      for (const o of T) {
        if (o === t) continue;
        if (o.e.contains(t.e) || t.e.contains(o.e)) continue;
        const nx = Math.max(o.x, Math.min(cx, o.x + o.w)), ny = Math.max(o.y, Math.min(cy, o.y + o.h));
        const small = Math.min(o.w, o.h) < 24 * o.sc - 0.5;
        const ox = o.x + o.w / 2, oy = o.y + o.h / 2;
        if (Math.hypot(nx - cx, ny - cy) < r || (small && Math.hypot(ox - cx, oy - cy) < 2 * r)) { clash = o.name; break; }
      }
      if (!clash) { out.spacingOK++; continue; }
      out.fail.push(`${Math.round(t.w / t.sc)}x${Math.round(t.h / t.sc)} ${t.role} "${t.name}" ↔ "${clash}"`);
    }
    return out;
  });
  console.log('==', f.split('/').pop(), 'under 24:', r.small, '| native menu items:', r.menu, '| pass by spacing:', r.spacingOK, '| need another exception:', r.fail.length);
  const c = {}; for (const x of r.fail) c[x.replace(/\d{1,2}:\d\d/g,'#')] = (c[x.replace(/\d{1,2}:\d\d/g,'#')] || 0) + 1;
  for (const [k, n] of Object.entries(c)) console.log('   ', n, k.slice(0, 150));
}
await b.close();
