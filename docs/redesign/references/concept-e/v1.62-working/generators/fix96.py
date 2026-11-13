"""CR-154 to CR-156 (owner approval 2026-11-08). Edits src96/project in place for E-Phones, E-Phones-2, E-Phones-3, E-FullA-v2."""
import re, sys
sys.path.insert(0, 'h')
from bal import elem
from dark import cr

def placeholder(s):
    """CR-154: Android Create task title placeholder takes the ED-179 placeholder token (#6F6978 light)."""
    return re.sub(r'(aria-label="Title" style="[^"]*?color: )#8A8494', r'\g<1>#6A6473', s)  # superseded by Q5 (ED-196)

ROUTINE = {'#E2A93B': '#AF7E22', '#C9A227': '#AF7E22', '#4FA37A': '#469763', '#3E9C6B': '#469763', '#5B8DD6': '#338ED1'}
def routine_dots(s):
    """CR-156: pre-palette routine and proposal ring colours -> the approved light ring tokens of the same family (ED-155/161)."""
    for k, v in ROUTINE.items(): s = s.replace(k, v)
    # Wind down's grey ring used the secondary-text colour; slate's ring is #6E6A75
    s = s.replace('box-shadow: inset 0 0 0 3px #6A6273; flex: none;"></span>', 'box-shadow: inset 0 0 0 3px #6E6A75; flex: none;"></span>')
    return s

def swatches(s, fails, colour):
    """CR-155: neutral outline on custom swatches below 3:1 against their surface; removed where the colour passes."""
    starts = [m.start() for m in re.finditer(r'aria-label="Your colour (#[0-9A-Fa-f]{6})"', s)]
    for i in reversed(range(len(starts))):
        a = s.rfind('<', 0, starts[i]); e = elem(s, a); b = s[a:e]
        hx = re.search(r'Your colour (#[0-9A-Fa-f]{6})', b).group(1)
        m = re.search(r'style="([^"]*background: ' + re.escape(hx) + r';[^"]*)"', b)
        st = m.group(1)
        st2 = re.sub(r'inset 0 0 0 1\.5px #[0-9A-F]{6}(, )?', '', st)
        st2 = st2.replace('box-shadow: ;', '')
        if i in fails:
            if 'box-shadow:' in st2: st2 = st2.replace('box-shadow: ', f'box-shadow: inset 0 0 0 1.5px {colour}, ', 1)
            else: st2 = st2.rstrip(';') + f'; box-shadow: inset 0 0 0 1.5px {colour};'
        b = b[:m.start(1)] + st2 + b[m.end(1):]
        s = s[:a] + b + s[e:]
    return s

def run():
    for b in ['E-Phones', 'E-Phones-3']:
        p = f'src96/project/{b}.dc.html'; x = placeholder(open(p).read()); open(p, 'w').write(x)
    p = 'src96/project/E-Phones-2.dc.html'; x = routine_dots(open(p).read()); open(p, 'w').write(x)
    light = {'E-Phones-3': {0, 3, 6, 7, 10, 11, 14, 15, 18}, 'E-FullA-v2': {0}}
    for b, f in light.items():
        p = f'src96/project/{b}.dc.html'; x = swatches(open(p).read(), f, '#7A7280'); open(p, 'w').write(x)
    print('ok')

if __name__ == '__main__': run()
