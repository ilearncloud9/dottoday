"""CR-165 (2) (owner, 2026-11-09): secondary label on the selected Mac sidebar row (Week, aria-current) #6A6273 -> #4E4757,
light only. E-FullA-v2 and E-G4-3-Narrow, 5 each."""
import re, sys
for b in ['E-FullA-v2', 'E-G4-3-Narrow']:
    p = f'{sys.argv[1]}/{b}.dc.html'; s = open(p).read()
    rx = re.compile(r'(<a href="#" aria-current="true" style="[^"]*background: rgba\(36,31,43,\.06\);[^"]*">(?:(?!</a>).)*?<span style="font-size: 11px; font-weight: 400; color: )#6A6273(;">⌘3</span>)', re.S)
    s, n = rx.subn(r'\g<1>#4E4757\g<2>', s); assert n == 5, (b, n)
    open(p, 'w').write(s); print(b, n)
