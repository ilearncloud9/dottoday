import { createRequire } from 'module';
const require = createRequire('/Users/ops/Documents/dottoday/tool/a11y/package.json');
const { chromium } = require('playwright-core');
const exe = '/Users/ops/Library/Caches/ms-playwright/chromium_headless_shell-1248/chrome-headless-shell-mac-arm64/chrome-headless-shell';
const b = await chromium.launch({ executablePath: exe });
for (const f of process.argv.slice(2)) {
  const p = await b.newPage({ viewport: { width: 3000, height: 2000 } });
  await p.goto('file://' + f); await p.waitForTimeout(800);
  const r = await p.evaluate(() => {
    const sel = 'button, a[href], input, select, textarea, [role=button], [role=tab], [role=menuitem], [role=link], [role=switch], [role=checkbox], [role=radio], [role=option]';
    const out = { total: 0, unnamed: [], small: [] };
    const name = (e) => {
      if (e.getAttribute('aria-hidden') === 'true' || e.closest('[aria-hidden=true]')) return 'HIDDEN';
      if (e.getAttribute('aria-label')) return e.getAttribute('aria-label');
      const lb = e.getAttribute('aria-labelledby'); if (lb) return lb.split(' ').map(i => document.getElementById(i)?.textContent || '').join(' ').trim();
      if (e.id) { const l = document.querySelector(`label[for="${e.id}"]`); if (l) return l.textContent.trim(); }
      if (e.tagName === 'INPUT') return e.getAttribute('placeholder') ? 'PLACEHOLDER-ONLY:' + e.placeholder : (e.value ? 'VALUE-ONLY:' + e.value : '');
      return (e.textContent || '').trim() || (e.getAttribute('title') || '');
    };
    for (const e of document.querySelectorAll(sel)) {
      const n = name(e); if (n === 'HIDDEN') continue;
      out.total++;
      if (!n || n.startsWith('PLACEHOLDER-ONLY') || n.startsWith('VALUE-ONLY')) { const lab = e.closest('label'); const row = e.parentElement; out.unnamed.push((lab ? 'IN-LABEL ' : 'ORPHAN ') + (e.getAttribute('role') || e.type || e.tagName) + ' | next to: ' + ((lab || row).textContent || '').trim().slice(0, 60)); }
    }
    return out;
  });
  console.log('==', f.split('/').pop(), 'controls', r.total, 'without a name', r.unnamed.length);
  const c = {}; for (const u of r.unnamed) c[u] = (c[u]||0)+1; for (const [u,k] of Object.entries(c)) console.log('   ', k, u.replace(/\s+/g, ' ').slice(0, 160));
}
await b.close();
