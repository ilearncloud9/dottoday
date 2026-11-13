"""CR-143 (owner, 2026-11-09, option A): ⌥⌘I toggles the right-hand pane in both modes (Full inspector, Minimal Day column).
Only the stale ⌥⌘D notes change; ⌥⌘D stays never-bound (macOS Dock)."""
import sys
d = sys.argv[1]
NOTE_O = '(its key is shown inconsistently on the boards as ⌥⌘D and ⌥⌘I; see CR-143)'
NOTE_N = '(⌥⌘I, the same key as the Full inspector: it toggles the right-hand pane in each mode; CR-143)'
for b in ['E-G4-3-Narrow', 'E-G4-3-Narrow-Dark']:
    p = f'{d}/{b}.dc.html'; s = open(p).read(); assert s.count(NOTE_O) == 1 and s.count('⌥⌘D') == 1, b
    open(p, 'w').write(s.replace(NOTE_O, NOTE_N)); print(b, 'ok')
p = f'{d}/E-Map.dc.html'; s = open(p).read()
o = 'EM: Day thread in the right column, hide ⌥⌘D;'; assert s.count(o) == 1 and s.count('⌥⌘D') == 1
s = s.replace(o, 'EM: Day thread in the right column, hide ⌥⌘I;')
o2 = 'ahead-ring specimens settled (ED-217);'; assert s.count(o2) == 1
s = s.replace(o2, o2 + ' Day-column key ⌥⌘I (CR-143, ED-218);')
open(p, 'w').write(s); print('E-Map ok')
