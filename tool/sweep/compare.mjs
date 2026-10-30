// Four-platform comparison of the design sweep (docs/08 §7): one row per
// screen, one column per platform × theme (× width on the web), written to
// app/build/sweep/compare.html for review beside the §4 idiom list.
// Usage: node tool/sweep/compare.mjs [filter]   (filter: a substring of
// the shot name, e.g. "minimal").
import { readdirSync, writeFileSync } from 'node:fs';

const dir = new URL('../../app/build/sweep/', import.meta.url).pathname;
const filter = process.argv[2] ?? '';
const columns = [
  'ios', 'ios_dark', 'android', 'android_dark', 'macos', 'macos_dark',
  'web_light_compact', 'web_dark_compact', 'web_light_expanded',
  'web_dark_expanded',
];
const files = new Set(readdirSync(dir).filter((f) => f.endsWith('.png')));
const shots = new Set();
for (const f of files) {
  const col = [...columns].sort((a, b) => b.length - a.length)
    .find((c) => f.startsWith(`${c}_`));
  if (col) shots.add(f.slice(col.length + 1, -4));
}
const rows = [...shots].filter((s) => s.includes(filter)).sort();
const cell = (c, s) => (files.has(`${c}_${s}.png`)
  ? `<td><img src="${c}_${s}.png" loading="lazy"></td>`
  : '<td class="none">—</td>');
const html = `<!doctype html><meta charset="utf-8"><title>Sweep comparison</title>
<style>body{font:12px system-ui;margin:8px}td,th{vertical-align:top;padding:2px}
img{width:180px;border:1px solid #ccc}.none{color:#999;text-align:center}
th{position:sticky;top:0;background:#fff}</style>
<table><tr><th>shot</th>${columns.map((c) => `<th>${c}</th>`).join('')}</tr>
${rows.map((s) => `<tr><th>${s}</th>${columns.map((c) => cell(c, s)).join('')}</tr>`).join('\n')}
</table>`;
writeFileSync(`${dir}compare${filter ? `_${filter}` : ''}.html`, html);
console.log(`${rows.length} shots × ${columns.length} columns → ${dir}compare${filter ? `_${filter}` : ''}.html`);
