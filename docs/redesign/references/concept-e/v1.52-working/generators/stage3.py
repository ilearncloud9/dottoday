"""G4-6 Stage 3: dark companions of the active Concept E boards (ED-180/181).
Light boards are read-only inputs; output goes to w85/project/<board>-Dark.dc.html."""
import re, sys, json
sys.path.insert(0, 'h')
import darkify as DK
from bal import elem

BOARDS = ['E-Phones', 'E-Phones-2', 'E-Phones-3', 'E-PhonesMinimal', 'E-FullA-v2', 'E-Minimal',
          'E-Earlier', 'E-Responsive', 'E-MobileWeb', 'E-G4-3-Narrow']

_kb_old = DK.kb_dark
def kb_dark(k):
    # the mobile-web keyboard is written without spaces and on #D1D3D9
    k = re.sub(r'background: ?#(FFFFFF|fff)\b', 'background: #6C6C70', k)
    k = k.replace('#D1D3D9', '#2C2C2E').replace('#898A8D', '#000000')
    k = re.sub(r'color: ?#000000|color: ?#000\b', 'color: #FFFFFF', k)
    return _kb_old(k)
DK.kb_dark = kb_dark

# Unmapped light colours found when converting whole boards (Stage 3 audit), mapped to P1 roles.
EXTRA = {
    '#CFC6D3': '#4A4348', '#D7D2DB': '#2F2A30',            # responsive wireframe bars
    '#79747E': '#8C838A', '#C9C3CF': '#8C838A', '#B7B0BE': '#8C838A', '#B9B2C0': '#8C838A',  # outlines, empty step boxes, disabled
    '#8D86D2': '#7A7EDE', '#ECE8F8': '#3C3A57', '#C9C7EE': '#3C3A57',  # indigo arc and 25 % track
    '#FBEBD0': '#483924', '#6E4300': '#E9B864',            # amber tag
    '#F8F5FA': '#37313A', '#F7EFF4': '#37313A', '#EFE8EF': '#37313A',  # menus, icon circle = popover
    '#F6E2EA': '#523342', '#9C3D63': '#F2A7C1',            # rose settings tile
    '#E3DDE6': '#39393D',                                  # iOS switch off track (system dark)
    '#D8ECE9': '#1E3A37',                                  # secondary text on a teal button
    '#F1EBE3': '#28232A', '#C9C2CE': '#4A4348',            # Mac title bar, inactive traffic light
    '#F2F2F4': '#1C1C1E', '#F1F3F4': '#202124', '#202124': '#E8EAED', '#5F6368': '#9AA0A6',  # Safari / Chrome dark chrome
    '#1D1B20': '#F3ECE4',                                  # native Mac menu label
    '#5E7A39': '#739646',                                  # custom App colour, derived dark shade (>= 4.5:1)
    '#4FA37A': '#4CA36B', '#3E9C6B': '#4CA36B', '#5B8DD6': '#4A9BD6', '#E2A93B': '#D9A23A', '#C9A227': '#D9A23A',  # off-palette dots (CR)
}

def shadows(h):
    """Blurred drop shadows stay dark (no glow, ED-178 T1 spirit); hairlines become light outlines."""
    def one(m):
        blur = float(m.group(3)); a = float(m.group(5))
        if blur < 3: return m.group(0)
        return f'{m.group(1)} {m.group(2)} {m.group(3)}px{m.group(4) or ""} rgba(0,0,0,{min(0.5, a*2.2):.2f})'
    pat = re.compile(r'(-?[\d.]+(?:px)?)\s+(-?[\d.]+(?:px)?)\s+([\d.]+)px(\s+-?[\d.]+px)?\s+rgba\(36,\s*31,\s*43,\s*([0-9.]+)\)')
    return re.sub(r'(box-shadow:[^;"]+)', lambda d: pat.sub(one, d.group(1)), h)

def extra(h):
    def f(m):
        k = '#' + m.group(1).upper(); v = EXTRA.get(k)
        return (v + (m.group(2) or '')) if v else m.group(0)
    return re.sub(r'#([0-9A-Fa-f]{6})([0-9A-Fa-f]{2})?\b', f, h)

def mac_selected(D):
    # ED-176/178 (I1): Mac sidebar selected row: label #F3ECE4, icon #A3E2D9; web rows unchanged
    def fix(m):
        a = m.group(0)
        if 'rgba(91,196,184,0.14)' not in a: return a
        return a.replace('<span style="flex: 1;">', '<span style="flex: 1; color: #F3ECE4;">', 1)
    return re.sub(r'<a href="#" aria-current="page"[^>]*>.*?</a>', fix, D, flags=re.S)

def thread(D, swaps):
    # Q1-B (ED-179): #7B7279 only on segments measured below 3:1 on a lighter surface
    ms = list(re.finditer(r'border-left: ?\d+px dotted #6B6369', D))
    for idx in sorted(swaps, reverse=True):
        m = ms[idx]; D = D[:m.start()] + m.group(0).replace('#6B6369', '#7B7279') + D[m.end():]
    return D

FA = open('src96/project/E-FullA-v2.dc.html').read()
BLKCSS = ''.join(re.findall(r'(\.(?:blk|dot)\{[^}]*\})', FA)[:2])

def protect(src, bg):
    # drawings that are dark in both themes (Wake Up lock screen) stay as drawn
    keep = []
    while f'background: {bg}' in src:
        i = src.index(f'background: {bg}'); a = src.rfind('<div', 0, i); e = elem(src, a)
        keep.append(src[a:e]); src = src[:a] + f'@@KEEP{len(keep)-1}@@' + src[e:]
    return src, keep

def convert(src, swaps=()):
    if '.blk{' not in src and 'class="blk"' in src:   # E-G4-3-Narrow ships without the grid CSS (CR-153)
        src = src.replace('</style>', BLKCSS + '</style>', 1)
    src, keep = protect(src, '#1F1A24')
    src = re.sub(r'background:rgba\(36,', 'background: rgba(36,', src)   # scrims written without a space
    if '#D1D3D9' in src:   # mobile-web iOS keyboard drawn without data-kb
        i = src.index('background:#D1D3D9'); a = src.rfind('<div', 0, i)
        src = src[:a] + '<div data-kb="ios" ' + src[a + 5:]
    # swipe Move action: system-grey fill with white label (iOS dark), not a light grey
    src = src.replace('background: #6A6273; color: #fff;', 'background: @@MV@@; color: @@W2@@;')
    # Android title placeholder takes the ED-179 placeholder role (dark #A0999F)
    src = re.sub(r'(aria-label="Title" style="[^"]*?color: )#8A8494', r'\1#6F6978', src)
    D = DK.darkify(shadows(src))
    D = D.replace('@@MV@@', '#636366').replace('@@W2@@', '#FFFFFF')
    D = D.replace('class="blk-d', 'class="blk')
    D = extra(D)
    D = mac_selected(D)
    D = re.sub(r'rgba\(246,\s*243,\s*239,', 'rgba(55,49,58,', D)   # Mac menu material -> popover
    D = D.replace('</style>', 'button{color:inherit}</style>', 1)  # UA black button text
    for n, k in enumerate(keep): D = D.replace(f'@@KEEP{n}@@', k)
    D = re.sub(r'(<h1[^>]*>)', r'\1Dark · ', D, count=1)
    return thread(D, swaps)

if __name__ == '__main__':
    swaps = json.load(open('h/swaps.json')) if len(sys.argv) > 1 else {}
    for b in BOARDS:
        D = convert(open(f'src96/project/{b}.dc.html').read(), swaps.get(b, []))
        open(f'w85/project/{b}-Dark.dc.html', 'w').write(D)
        print(b, len(D))
