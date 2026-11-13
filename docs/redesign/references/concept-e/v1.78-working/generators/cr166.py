"""CR-166 (owner OK 2026-11-09): dark now-ring tracks follow ED-174 - track = the arc's task colour at 25 %.
Only conic now-rings on the dark copies. Excluded (not task now-rings): Week in review progress rings
(#5BC4B8 / rgba(91,196,184,0.18)), the Wind Down ring (#5BC4B8 / #2F2A30), the menu glyph (#F3ECE4 / #3C3A57)."""
import re, sys, collections

EXCLUDE = {('#5BC4B8', 'rgba(91,196,184,0.18)'), ('#5BC4B8', '#2F2A30'), ('#F3ECE4', '#3C3A57')}
RX = re.compile(r'conic-gradient\((#[0-9A-Fa-f]{6}) 0 ([\d.]+)%, ([^ ,]+(?:\([^)]*\))?) \2% 100%\)')


def track(hexc):
    r, g, b = (int(hexc[i:i + 2], 16) for i in (1, 3, 5))
    return f'rgba({r},{g},{b},.25)'


def fix(s):
    n = collections.Counter()
    def rep(m):
        arc, pct, old = m.group(1), m.group(2), m.group(3)
        new = track(arc)
        if (arc, old) in EXCLUDE or old == new or old.upper() == (arc + '40').upper():
            return m.group(0)
        n[(arc, old)] += 1
        return f'conic-gradient({arc} 0 {pct}%, {new} {pct}% 100%)'
    return RX.sub(rep, s), n


d = sys.argv[1]
BOARDS = ['E-Earlier', 'E-FullA-v2', 'E-G4-3-Narrow', 'E-Minimal', 'E-MobileWeb', 'E-Phones', 'E-Phones-2',
          'E-Phones-3', 'E-PhonesMinimal']
for base in BOARDS:
    p = f'{d}/{base}-Dark.dc.html'
    s, n = fix(open(p).read())
    open(p, 'w').write(s)
    print(base + '-Dark', sum(n.values()), dict(n))
