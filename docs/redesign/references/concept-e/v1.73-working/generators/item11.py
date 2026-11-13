"""Cleanup item 11 (owner, 2026-11-09, option A): Minimal web sidebar 210 -> 200 (as Mac); web Now pane 560 -> 570 and moves left 210 -> 200 (absolute layout); the Day column stays at 770. E-Minimal and -Dark only."""
import re, sys
for b in ['E-Minimal', 'E-Minimal-Dark']:
    p = f'{sys.argv[1]}/{b}.dc.html'; s = open(p).read()
    k = [m.start() for m in re.finditer(r'<nav aria-label="Sidebar" style="[^"]*width: 210px', s)]; assert len(k) == 1
    seg = s[k[0]:k[0] + 300]; s = s[:k[0]] + seg.replace('width: 210px', 'width: 200px', 1) + s[k[0] + 300:]
    old = '<section aria-label="Now" style="position: absolute; left: 210px; top: 82px; width: 560px;'
    assert s.count(old) == 1 and s.count('width: 560px') == 1
    s = s.replace(old, '<section aria-label="Now" style="position: absolute; left: 200px; top: 82px; width: 570px;')
    open(p, 'w').write(s); print(b, 'ok')
