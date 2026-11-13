"""R2-1 shared parts: sources, tablet sidebars, top tabs, rail, medium Today."""
import re, json, sys, os
P = '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/'
S1 = P + '1bd3d7d6-0f73-4a41-85df-3f6fa809d751/scratchpad/'
NAR = open(P + '9260a16b-b810-43b7-b1f7-878c48a9d9f8/scratchpad/w128/project/E-G4-3-Narrow.dc.html', encoding='utf-8').read()
EP = open(P + '808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/live/project/E-FullA-v2.dc.html', encoding='utf-8').read()
PHONES = open(S1 + 'w147/live/project/E-Phones.dc.html', encoding='utf-8').read()
AB = json.load(open(S1 + 'w143/ab.json'))
# touch-size transform approved in ED-256 (built for E-T3)
_src = open(S1 + 'w145/build.py', encoding='utf-8').read(); _src = _src[:_src.index('\nSC = 0.6')]
_argv = sys.argv; sys.argv = [sys.argv[0], '0']; _cwd = os.getcwd()
NS = {'__file__': S1 + 'w145/build.py'}; exec(compile(_src, 'w145build', 'exec'), NS)
os.chdir(_cwd); sys.argv = _argv
phone, block, section = NS['phone'], NS['block'], NS['section']

INK, SEC, ACC, GROUND, SURF = '#241F2B', '#6A6273', '#11615C', '#FBF7F1', '#FFFDF9'

def raw(label):
    i = NAR.index('aria-label="%s"' % label)
    k = NAR.rfind('<div', 0, NAR.index('position: relative', i))
    return NAR[k:block(NAR, k, 'div')]

def no_cursor(f):
    return re.sub(r'<svg width="16" height="22" viewBox="0 0 16 22" aria-hidden="true"[^>]*><path d="M1 1v17[^"]*"[^>]*></path></svg>', '', f)

def no_ctx_menu(f):
    # Mac right-click menu on the Gym dot / Lunch block: touch has no right-click (long-press is R2 stage 2)
    for lab in ('Lunch actions', 'Gym actions'):
        if 'aria-label="%s"' % lab in f:
            i = f.index('aria-label="%s"' % lab); s = f.rfind('<div', 0, i); f = f[:s] + f[block(f, s, 'div'):]
    f = re.sub(r'<div role="menu" aria-label="Gym[^"]*".*?</div>\s*</div>', '', f, flags=re.S)
    return f

def place(f, w, h, top, left=0):
    m = re.search(r'position: relative; width: %dpx; height: 800px; border-radius: \d+px;' % w, f)
    return f[:m.start()] + 'position: absolute; left: %dpx; top: %dpx; width: %dpx; height: %dpx; border-radius: 0;' % (left, top, w, h) + f[m.end():]

def swap_nav(f, new):
    a = f.index('<nav aria-label="Sidebar"'); return f[:a] + new + f[block(f, a, 'nav'):]

I = {  # 24-grid stroke icons (DotGlyph style: stroke 2, round)
 'Today': '<circle cx="12" cy="12" r="8.5"></circle><circle cx="12" cy="12" r="3" fill="currentColor"></circle>',
 'Now': '<circle cx="12" cy="12" r="8.5"></circle><circle cx="12" cy="12" r="3" fill="currentColor"></circle>',
 'Plan': '<path d="M5 6h14M5 12h14M5 18h9"></path>',
 'Inbox': '<path d="M3 13l3-8h12l3 8v6H3z"></path><path d="M3 13h5l1 3h6l1-3h5"></path>',
 'Calendar': '<rect x="3.5" y="5" width="17" height="15" rx="3"></rect><path d="M3.5 10h17M8 3v4M16 3v4"></path>',
 'Search': '<circle cx="11" cy="11" r="6.5"></circle><path d="M20 20l-4.2-4.2"></path>',
 'Review': '<path d="M4 6l2 2 3-3M4 13l2 2 3-3M12 7h8M12 14h8M12 20h8"></path>',
 'Settings': '<circle cx="12" cy="12" r="3"></circle><path d="M12 2.5v3M12 18.5v3M2.5 12h3M18.5 12h3M5.3 5.3l2.1 2.1M16.6 16.6l2.1 2.1M5.3 18.7l2.1-2.1M16.6 7.4l2.1-2.1"></path>',
 'sidebar': '<rect x="3" y="4.5" width="18" height="15" rx="3"></rect><path d="M9 4.5v15"></path>',
 'menu': '<path d="M4 7h16M4 12h16M4 17h16"></path>',
 'plus': '<path d="M12 5v14M5 12h14"></path>',
 'chev': '<path d="M6 9l6 6 6-6"></path>',
}
def ic(n, s=22, w=2):
    return '<svg class="i" width="%d" height="%d" viewBox="0 0 24 24" aria-hidden="true" style="stroke-width: %s;">%s</svg>' % (s, s, w, I[n])

FULL_ROWS = [('Today', 'Today', '3/9', 0), ('Plan', 'Plan', '', 0), (None, 'Inbox', '3', 1), (None, 'Routines', '2', 1), (None, 'Brain dump', '', 1),
             ('§', 'Calendar views', '', 0), (None, 'Day', '', 0), (None, '3 days', '', 0), (None, 'Week', '', 0), (None, 'Month', '', 0),
             ('Review', 'Review', '', 0), ('Search', 'Search', '', 0)]
MIN_ROWS = [('Now', 'Now', '', 0), ('Inbox', 'Inbox', '3', 0), ('Calendar', 'Calendar', '', 0), ('Search', 'Search', '', 0)]

def ipad_sidebar(rows, selected, top=24, h=796, width=216):
    """iPadOS 26 sidebar (tab bar in sidebar mode): floating glass panel, 44 pt rows, Settings at the foot."""
    out = []
    for icon, label, badge, indent in rows:
        if icon == '§':
            out.append('<div style="padding: 14px 12px 4px; font: 600 13px -apple-system, system-ui, sans-serif; color: %s;">%s</div>' % (SEC, label)); continue
        sel = label == selected
        b = ('<span class="num" style="font: 600 13px -apple-system, system-ui, sans-serif; color: %s;">%s</span>' % (ACC if label == 'Inbox' else SEC, badge)) if badge else ''
        out.append('<a href="#"%s style="height: 44px; border-radius: 12px; display: flex; align-items: center; gap: 10px; padding: 0 12px 0 %dpx; text-decoration: none; '
                   'font: %s 16px -apple-system, system-ui, sans-serif; color: %s; %s">%s<span style="flex: 1;">%s</span>%s</a>' % (
                       ' aria-current="page"' if sel else '', 44 if indent else 12, '600' if sel else '500', '#0B4642' if sel else INK,
                       'background: rgba(17,97,92,.14);' if sel else '', ic(icon) if icon else '', label, b))
    foot = ('<div style="margin-top: auto; display: flex; flex-direction: column; gap: 2px; border-top: 1px solid rgba(36,31,43,.08); padding-top: 6px;">'
            '<a href="#" style="height: 44px; border-radius: 12px; display: flex; align-items: center; gap: 10px; padding: 0 12px; text-decoration: none; font: 500 16px -apple-system, system-ui, sans-serif; color: %s;">%s<span>Settings</span></a>'
            '<div class="num" style="height: 32px; display: flex; align-items: center; gap: 6px; padding: 0 12px; font: 500 13px -apple-system, system-ui, sans-serif; color: %s;">'
            '<span aria-hidden="true" style="width: 8px; height: 8px; border-radius: 50%%; background: %s;"></span>Synced · 10:42</div></div>') % (INK, ic('Settings'), SEC, ACC)
    return ('<nav aria-label="Sidebar" style="position: absolute; left: 8px; top: %dpx; height: %dpx; width: %dpx; border-radius: 24px; box-sizing: border-box; padding: 8px; '
            'background: rgba(242,235,226,.88); backdrop-filter: blur(30px); box-shadow: inset 0 0 0 1px rgba(255,255,255,.7), 0 0 0 .5px rgba(36,31,43,.12), 0 8px 24px rgba(36,31,43,.10); '
            'display: flex; flex-direction: column; gap: 2px; z-index: 25;">'
            '<div style="height: 44px; display: flex; align-items: center; justify-content: space-between; padding: 0 4px 0 12px;">'
            '<span style="font: 700 22px -apple-system, system-ui, sans-serif; color: %s;">Dottoday</span>'
            '<button aria-label="Hide sidebar" style="width: 44px; height: 44px; border: 0; background: transparent; color: %s; display: flex; align-items: center; justify-content: center;">%s</button></div>'
            '%s%s</nav>') % (top + 8, h - 16, width - 8, INK, ACC, ic('sidebar'), ''.join(out), foot)

def android_drawer(rows, selected, top=28, width=216):
    """M3 standard navigation drawer at expanded: 48 dp items, pill indicator, Settings at the foot."""
    out = []
    for icon, label, badge, indent in rows:
        if icon == '§':
            out.append('<div style="padding: 12px 16px 4px; font: 500 13px Roboto, system-ui, sans-serif; color: %s;">%s</div>' % (SEC, label)); continue
        sel = label == selected
        b = ('<span class="num" style="font: 500 13px Roboto, system-ui, sans-serif; color: %s;">%s</span>' % (SEC, badge)) if badge else ''
        out.append('<a href="#"%s style="height: 48px; border-radius: 24px; display: flex; align-items: center; gap: 12px; padding: 0 16px 0 %dpx; text-decoration: none; '
                   'font: %s 15px Roboto, system-ui, sans-serif; color: %s; %s">%s<span style="flex: 1;">%s</span>%s</a>' % (
                       ' aria-current="page"' if sel else '', 50 if indent else 16, '600' if sel else '500', '#062F2C' if sel else '#3B3543',
                       'background: #CFE8E4;' if sel else '', ic(icon) if icon else '', label, b))
    foot = ('<div style="margin-top: auto; display: flex; flex-direction: column; gap: 2px; border-top: 1px solid rgba(36,31,43,.10); padding-top: 6px;">'
            '<a href="#" style="height: 48px; border-radius: 24px; display: flex; align-items: center; gap: 12px; padding: 0 16px; text-decoration: none; font: 500 15px Roboto, system-ui, sans-serif; color: #3B3543;">%s<span>Settings</span></a>'
            '<div class="num" style="height: 32px; display: flex; align-items: center; gap: 6px; padding: 0 16px; font: 400 13px Roboto, system-ui, sans-serif; color: %s;">'
            '<span aria-hidden="true" style="width: 8px; height: 8px; border-radius: 50%%; background: %s;"></span>Synced · 10:42</div></div>') % (ic('Settings'), SEC, ACC)
    return ('<nav aria-label="Navigation drawer" style="position: absolute; left: 0; top: %dpx; bottom: 0; width: %dpx; box-sizing: border-box; padding: 8px 12px 20px; background: #F3EEE6; '
            'display: flex; flex-direction: column; gap: 0; z-index: 25;">'
            '<div style="height: 56px; display: flex; align-items: center; gap: 4px; padding: 0 4px;">'
            '<button aria-label="Collapse to rail" style="width: 48px; height: 48px; border: 0; background: transparent; color: #3B3543; display: flex; align-items: center; justify-content: center;">%s</button>'
            '<span style="font: 500 20px Roboto, system-ui, sans-serif; color: %s;">Dottoday</span></div>%s%s</nav>') % (top, width, ic('menu'), INK, ''.join(out), foot)

def ipad_top_tabs(tabs, selected, w, top=30, day=True):
    """iPadOS 26 top tab bar (compact tablet navigation at medium): sidebar button left; Day ▾ and + right."""
    items = ''.join('<span role="tab"%s style="height: 36px; padding: 0 16px; border-radius: 18px; display: flex; align-items: center; %s">%s</span>' % (
        ' aria-selected="true"' if t == selected else '',
        'background: %s; color: %s; box-shadow: 0 1px 4px rgba(36,31,43,.12);' % (SURF, ACC) if t == selected else 'color: #4E4757;', t) for t in tabs)
    glass = 'background: rgba(255,255,255,.66); box-shadow: inset 0 0 0 1px rgba(255,255,255,.6), 0 0 0 .5px rgba(36,31,43,.12), 0 8px 24px rgba(36,31,43,.10);'
    d = ('<button aria-haspopup="menu" aria-label="Day menu" style="height: 44px; padding: 0 14px 0 16px; border: 0; border-radius: 22px; %s display: flex; align-items: center; gap: 6px; '
         'font: 600 16px -apple-system, system-ui, sans-serif; color: %s;">Day%s</button>' % (glass, INK, ic('chev', 16, 2.4))) if day else ''
    return ('<div style="position: absolute; left: 0; right: 0; top: %dpx; height: 52px; display: flex; align-items: center; justify-content: space-between; padding: 0 20px; z-index: 22;">'
            '<button aria-label="Show sidebar" style="width: 44px; height: 44px; border: 0; border-radius: 22px; %s color: %s; display: flex; align-items: center; justify-content: center;">%s</button>'
            '<div role="tablist" aria-label="Main" style="display: flex; gap: 4px; padding: 4px; border-radius: 24px; %s font: 600 15px -apple-system, system-ui, sans-serif;">%s</div>'
            '<span style="display: flex; gap: 10px;">%s<button aria-label="Add a task" aria-haspopup="menu" style="width: 44px; height: 44px; border-radius: 22px; border: 0; background: %s; color: #fff; '
            'display: flex; align-items: center; justify-content: center; box-shadow: 0 6px 16px rgba(17,97,92,.25);">%s</button></span></div>') % (
                top, glass, ACC, ic('sidebar'), glass, items, d, ACC, ic('plus', 22, 2.4))

def android_rail(tabs, selected, top=28):
    """M3 navigation rail at medium: menu (opens the drawer), + FAB, destinations, Settings at the bottom."""
    items = ''.join(
        '<a href="#"%s style="display: flex; flex-direction: column; align-items: center; gap: 4px; text-decoration: none; font: %s 12px Roboto, system-ui, sans-serif; color: %s;">'
        '<span style="width: 56px; height: 32px; border-radius: 16px; display: flex; align-items: center; justify-content: center; %s">%s</span>%s</a>' % (
            ' aria-current="page"' if t == selected else '', '600' if t == selected else '500', '#062F2C' if t == selected else '#4E4757',
            'background: #CFE8E4;' if t == selected else '', ic(t), t) for t in tabs)
    return ('<nav aria-label="Navigation rail" style="position: absolute; left: 0; top: %dpx; bottom: 0; width: 88px; background: #F3EEE6; display: flex; flex-direction: column; align-items: center; gap: 16px; padding: 12px 0 28px; box-sizing: border-box; z-index: 22;">'
            '<button aria-label="Open navigation drawer" style="width: 48px; height: 48px; border: 0; background: transparent; color: #3B3543; display: flex; align-items: center; justify-content: center;">%s</button>'
            '<button aria-label="Add a task" aria-haspopup="menu" style="width: 56px; height: 56px; border-radius: 16px; border: 0; background: #CFE8E4; color: #062F2C; display: flex; align-items: center; justify-content: center; box-shadow: 0 3px 8px rgba(36,31,43,.16);">%s</button>'
            '<div style="display: flex; flex-direction: column; gap: 14px; margin-top: 8px;">%s</div>'
            '<a href="#" style="margin-top: auto; display: flex; flex-direction: column; align-items: center; gap: 4px; text-decoration: none; font: 500 12px Roboto, system-ui, sans-serif; color: #4E4757;">'
            '<span style="width: 56px; height: 32px; display: flex; align-items: center; justify-content: center;">%s</span>Settings</a></nav>') % (top, ic('menu'), ic('plus', 24, 2.2), items, ic('Settings'))
