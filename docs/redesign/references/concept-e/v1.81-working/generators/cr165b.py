"""CR-165 (2) remainder (owner, 2026-11-09): Week canvas Today column header secondary label
"3 of 9 · 7 h 40" #6A6273 -> #4E4757, light only. E-FullA-v2 and E-G4-3-Narrow, 5 each."""
import sys
OLD = '<span class="num" style="font-size: 12px; font-weight: 700; color: #6A6273;">3 of 9 · 7 h 40</span>'
for b in ['E-FullA-v2', 'E-G4-3-Narrow']:
    p = f'{sys.argv[1]}/{b}.dc.html'; s = open(p).read()
    assert s.count(OLD) == 5, (b, s.count(OLD))
    s = s.replace(OLD, OLD.replace('#6A6273', '#4E4757')); open(p, 'w').write(s); print(b, 5)
