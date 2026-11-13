"""Text-fit corrections on the active light boards (owner comment 2026-11-08: "make this a normal thing across the app").
Reads live85/project, writes w88/project/<board>.dc.html for the boards that change."""
import re, sys
sys.path.insert(0, 'h')
from bal import elem

FA = open('live85/project/E-FullA-v2.dc.html').read()
BLKCSS = ''.join(re.findall(r'(\.(?:blk|dot)\{[^}]*\})', FA)[:2])

def ellipsis_blocks(s):
    """Week-grid block titles never clip mid-letter: one line, ellipsis, full title stays in aria-label and tooltip."""
    def fix(m):
        st = m.group(0)
        if 'text-overflow' in st: return st
        return st.replace('white-space: nowrap;', 'white-space: nowrap; overflow: hidden; text-overflow: ellipsis;')
    out = []; i = 0
    for m in re.finditer(r'<button class="blk"', s):
        e = elem(s, m.start()); blk = s[m.start():e]
        blk = re.sub(r'style="[^"]*white-space: nowrap;[^"]*"', fix, blk)
        lab = re.search(r'aria-label="([^"]*)"', blk)
        if lab and ' title="' not in blk[:300]: blk = blk.replace('<button class="blk"', f'<button class="blk" title="{lab.group(1)}"', 1)
        out.append(s[i:m.start()] + blk); i = e
    return ''.join(out) + s[i:]

def nowrap_buttons(s):
    """Pill and push buttons keep their label on one line and size to it."""
    s = re.sub(r'(<button class="num" style="height: 30px; padding: 0 10px;)', r'\1 white-space: nowrap; flex: none;', s)
    s = s.replace('<button style="height: 28px; padding: 0 12px; border: 0; border-radius: 7px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.16); font: 500 13px -apple-system, system-ui;">Add a schedule…',
                  '<button style="height: 28px; padding: 0 12px; border: 0; border-radius: 7px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.16); font: 500 13px -apple-system, system-ui; white-space: nowrap; flex: none;">Add a schedule…')
    return s

def keyboard_hint(s):
    """Web keyboard hint bar: shows what fits and always ends with "? all keys"; Show less (⇧L) stays in the View menu and the ? list."""
    s = re.sub(r'<kbd[^>]*>⇧L</kbd> show less · ', '', s)
    return re.sub(r'<kbd[^>]*>\[</kbd>\s*<kbd[^>]*>\]</kbd> days · ', '', s)

def narrow_toolbar(s):
    """840 toolbar fits its 624 px: tabs and buttons never wrap or clip (CR-157)."""
    s = s.replace('</style>', '[role=toolbar][aria-label=Plan]>*{flex-shrink:0;white-space:nowrap}</style>', 1)
    s = re.sub(r'(<div role="tablist" aria-label="Canvas range" style="margin-left: )10px;', r'\g<1>6px;', s)
    tl = [m.start() for m in re.finditer(r'<div role="tablist" aria-label="Canvas range"', s)]
    for a in reversed(tl):
        e = elem(s, a); s = s[:a] + s[a:e].replace('padding: 0 12px;', 'padding: 0 8px;') + s[e:]
    s = s.replace('<button style="width: 34px; height: 30px; border: 0; border-radius: 21px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.10); display: flex; align-items: center; gap: 7px; padding: 0 12px;',
                  '<button aria-label="Search or run, Command K" style="height: 30px; border: 0; border-radius: 21px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.10); display: flex; align-items: center; gap: 5px; padding: 0 9px;')
    s = s.replace('box-shadow: 0 1px 0 rgba(36,31,43,.08); display: flex; align-items: center; gap: 8px; padding: 0 12px 0 10px;', 'box-shadow: 0 1px 0 rgba(36,31,43,.08); display: flex; align-items: center; gap: 6px; padding: 0 12px 0 10px;')
    return s

POP = ('<button aria-haspopup="menu" aria-label="Canvas range: {v}" style="margin-left: 6px; height: 30px; padding: 0 10px 0 12px; border: 0; border-radius: 21px; '
       'background: rgba(36,31,43,.06); font: 600 12px -apple-system, system-ui, sans-serif; color: #241F2B; display: flex; align-items: center; gap: 5px;">{v}'
       '<svg class="i" width="11" height="11" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 9l6 6 6-6"></path></svg></button>')

def range_popup_840(s):
    """At 840 the Day · 3 days · Week · Month tabs collapse into one pop-up button (toolbar overflow rule)."""
    pos = [m.start() for m in re.finditer(r'<div style="position: relative; width: 840px; height: 640px;', s)]
    for w0 in reversed(pos):
        w1 = elem(s, w0); w = s[w0:w1]
        if '<div role="tablist" aria-label="Canvas range"' not in w: continue
        a = w.index('<div role="tablist" aria-label="Canvas range"'); e = elem(w, a)
        sel = re.search(r'aria-selected="true"[^>]*>([^<]+)<', w[a:e]).group(1)
        w = w[:a] + POP.format(v=sel) + w[e:]
        s = s[:w0] + w + s[w1:]
    return s

def shift_menus(s, label, shifts):
    """Context menus open inside the window (macOS keeps menus on screen): move each instance left by its measured overflow."""
    ms = [m.start() for m in re.finditer(f'role="menu" aria-label="{label}" style="position: absolute; left: ', s)]
    for idx, d in sorted(shifts.items(), reverse=True):
        i = ms[idx] + len(f'role="menu" aria-label="{label}" style="position: absolute; left: ')
        j = s.index('px', i); s = s[:i] + str(int(s[i:j]) - d) + s[j:]
    return s

def clamp_overlap(s):
    old = '<span style="position: absolute; left: 28px; top: 4px; right: 2px; font-size: 11px; line-height: 13px; font-weight: 700;">'
    return s.replace(old, old[:-2] + ' display: -webkit-box; -webkit-box-orient: vertical; -webkit-line-clamp: 2; overflow: hidden;">')

def submenu(s):
    return s.replace('role="menu" aria-label="Need More Time" style="width: 214px;', 'role="menu" aria-label="Need More Time" style="width: 168px;')

SHIFTS = {0: 98, 3: 26}
def run():
    out = {}
    s = FA; s = submenu(clamp_overlap(ellipsis_blocks(nowrap_buttons(keyboard_hint(s))))); out['E-FullA-v2'] = s
    n = open('live85/project/E-G4-3-Narrow.dc.html').read()
    if '.blk{' not in n: n = n.replace('</style>', BLKCSS + '</style>', 1)   # CR-153
    n = clamp_overlap(ellipsis_blocks(nowrap_buttons(keyboard_hint(range_popup_840(narrow_toolbar(n))))))
    n = shift_menus(n, 'Lunch actions', SHIFTS); out['E-G4-3-Narrow'] = n
    for b in ['E-Minimal', 'E-Responsive', 'E-MobileWeb', 'E-Earlier']:
        x = open(f'live85/project/{b}.dc.html').read(); y = ellipsis_blocks(nowrap_buttons(keyboard_hint(x)))
        if y != x: out[b] = y
    for b, x in out.items(): open(f'w88/project/{b}.dc.html', 'w').write(x)
    print(sorted(out))

if __name__ == '__main__': run()
