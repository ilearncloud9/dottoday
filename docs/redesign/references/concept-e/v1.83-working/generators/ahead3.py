"""ED-199 follow-up (owner, 2026-11-09, option A): the Lunch ahead dot in "iPhone Today with month pulled down"
(30 px phone thread dot) ring 3 -> 4 px, light and dark. Board keys and the Lands-at marker unchanged."""
import re, sys
for b in ['E-Phones', 'E-Phones-Dark']:
    p = f'{sys.argv[1]}/{b}.dc.html'; s = open(p).read()
    a = s.find('aria-label="iPhone Today with month pulled down"'); i = s.find('Lunch', a)
    ms = list(re.finditer(r'width: 30px; height: 30px;[^"]*?inset 0 0 0 3px', s[a:i])); assert len(ms) == 1, b
    m = ms[0]; st, en = a + m.start(), a + m.end()
    s = s[:st] + s[st:en].replace('inset 0 0 0 3px', 'inset 0 0 0 4px') + s[en:]
    open(p, 'w').write(s); print(b, 'ok')
