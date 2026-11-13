"""Cleanup item 14 (owner, 2026-11-09, option A): the E-Minimal web Now card takes the Mac card sizes:
height 64 -> 68, "Now, N min left" 13.5 -> 12.5, title 17 -> 16. Web layout (time and Now on one line) kept."""
import sys
sys.path.insert(0, 'h')
from bal import elem

for b in ['E-Minimal', 'E-Minimal-Dark']:
    p = f'{sys.argv[1]}/{b}.dc.html'
    s = open(p).read()
    a = s.find('<section aria-label="Day" style="position: absolute; left: 770px')
    assert a > 0 and s.count('<section aria-label="Day" style="position: absolute; left: 770px') == 1
    e = elem(s, a)
    sec = s[a:e]
    i = sec.find('Now, 18 min left')
    c = sec.rfind('<div', 0, sec.rfind('border-radius: 18px', 0, i))
    ce = elem(sec, c)
    card = sec[c:ce]
    reps = [('<div role="listitem" style="position: relative; height: 64px;',
             '<div role="listitem" style="position: relative; height: 68px;'),
            ('font-weight: 700; font-size: 13.5px;">Now, 18 min left',
             'font-weight: 700; font-size: 12.5px;">Now, 18 min left'),
            ('<span style="display: block; font-size: 17px; font-weight: 700;">Deep work: roadmap',
             '<span style="display: block; font-size: 16px; font-weight: 700;">Deep work: roadmap')]
    for o, n in reps:
        assert card.count(o) == 1, (b, o)
        card = card.replace(o, n)
    s = s[:a] + sec[:c] + card + sec[ce:] + s[e:]
    open(p, 'w').write(s)
    print(b, 'ok')
