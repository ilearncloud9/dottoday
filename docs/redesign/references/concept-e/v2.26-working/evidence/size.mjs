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
    const res = []; 
    for (const e of document.querySelectorAll(sel)) {
      if (e.closest('[aria-hidden=true]')) continue;
      // scale of ancestors (boards draw some frames scaled)
      let sc = 1; for (let a = e; a; a = a.parentElement) { const t = getComputedStyle(a).transform; if (t && t !== 'none') { const m = new DOMMatrix(t); sc *= m.a; } const z = parseFloat(getComputedStyle(a).zoom || 1); if (z && z !== 1) sc *= z; }
      const bb = e.getBoundingClientRect(); if (!bb.width) continue;
      const w = bb.width / sc, h = bb.height / sc;
      const frame = e.closest('[aria-label]:not(button):not(a):not([role])')?.getAttribute('aria-label') || '';
      res.push({ w: Math.round(w), h: Math.round(h), name: (e.getAttribute('aria-label') || e.textContent || '').trim().slice(0, 40), frame: frame.slice(0, 50) });
    }
    return res;
  });
  const lt = (n) => r.filter(x => Math.min(x.w, x.h) < n);
  console.log('==', f.split('/').pop(), 'controls', r.length, '| <24:', lt(24).length, '| <28:', lt(28).length, '| <44:', lt(44).length);
  const c = {}; for (const x of lt(24)) { const k = `${x.w}x${x.h} ${x.name}`; c[k] = (c[k] || 0) + 1; }
  for (const [k, n] of Object.entries(c).slice(0, 20)) console.log('   <24', n, k);
}
await b.close();
