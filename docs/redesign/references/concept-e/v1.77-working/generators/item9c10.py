"""Owner OK 2026-11-09 ("Apply both"):
9c  web focus ring -> ED-174 recipe: 2 px solid ring after a 2 px gap that shows the surface
    (light #11615C, dark #7FD6CB). E-Minimal (1) and E-FullA-v2 (3), light and dark.
10  E-Minimal web primary Add -> accent: light #11615C / white, dark #5BC4B8 / #171416 (as the Mac Add)."""
import re, sys

RING = {False: 'outline: 2px solid #11615C; outline-offset: 2px;', True: 'outline: 2px solid #7FD6CB; outline-offset: 2px;'}
OLD = re.compile(r'outline: 3px solid rgba\((?:17,97,92,\.45|91,196,184,0\.45)\); outline-offset: [12]px;')
ADD = {False: ('aria-label="Add a task, press n" style="height: 36px; padding: 0 16px; border: 0; border-radius: 22px; background: #241F2B; color: #fff;',
               'aria-label="Add a task, press n" style="height: 36px; padding: 0 16px; border: 0; border-radius: 22px; background: #11615C; color: #fff;'),
       True: ('aria-label="Add a task, press n" style="height: 36px; padding: 0 16px; border: 0; border-radius: 22px; background: #F3ECE4; color: #171416;',
              'aria-label="Add a task, press n" style="height: 36px; padding: 0 16px; border: 0; border-radius: 22px; background: #5BC4B8; color: #171416;')}
EXPECT = {'E-Minimal': 1, 'E-FullA-v2': 3}

d = sys.argv[1]
for base, n in EXPECT.items():
    for dark in (False, True):
        b = base + ('-Dark' if dark else '')
        p = f'{d}/{b}.dc.html'
        s = open(p).read()
        s, k = OLD.subn(RING[dark], s)
        assert k == n, (b, k)
        if base == 'E-Minimal':
            o, w = ADD[dark]
            assert s.count(o) == 1, b
            s = s.replace(o, w)
        open(p, 'w').write(s)
        print(b, 'rings', k, 'add', base == 'E-Minimal')
