"""Dark post-steps after stage3 (CR-155): outlines where dark custom swatches fail; swatch glyph re-derived (ink or white by contrast)."""
import re, sys
sys.path.insert(0, 'h')
from fix96 import swatches
from bal import elem
from dark import cr
FAILS = {'E-Phones-3': {1, 2, 4, 5, 8, 9, 12, 13, 16, 17}, 'E-FullA-v2': {1, 2}}
def glyphs(s):
    for m in reversed(list(re.finditer(r'aria-label="Your colour (#[0-9A-Fa-f]{6})"', s))):
        a = s.rfind('<', 0, m.start()); e = elem(s, a); b = s[a:e]; hx = m.group(1)
        ink = '#171416' if cr(hx, '#171416') >= cr(hx, '#FFFFFF') else '#FFFFFF'
        b = re.sub(r'(background: ' + re.escape(hx) + r';[^"]*?color: )#[0-9A-Fa-f]{6}', lambda x: x.group(1) + ink, b)
        s = s[:a] + b + s[e:]
    return s
for b, f in FAILS.items():
    p = f'w85/project/{b}-Dark.dc.html'; x = glyphs(swatches(open(p).read(), f, '#8C838A')); open(p, 'w').write(x)
print('ok')
