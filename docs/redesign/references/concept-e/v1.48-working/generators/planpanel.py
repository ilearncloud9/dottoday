"""Plan panel options board (owner comment 2026-11-08): A collapsible panel, B sections, C sidebar only, A+B.
Reads the approved light windows; writes w87/project/E-PlanPanel-Options.dc.html. No active board is changed."""
import re, sys
sys.path.insert(0, 'h')
from bal import elem

W1280 = open('macwin.html').read()          # E-FullA-v2 Mac Workspace, 1280 x 800
W840 = open('mac840.html').read()           # E-G4-3-Narrow Full 840 x 640
# At 840 the range tabs become one pop-up button so the Plan button fits (the 840 toolbar already wraps "3 days" on E-G4-3-Narrow, CR-157)
_t0 = W840.index('<div role="tablist" aria-label="Canvas range"'); _t1 = elem(W840, _t0)
W840 = W840[:_t0] + ('<button aria-haspopup="menu" aria-label="Canvas range: Week" style="margin-left: 4px; height: 30px; padding: 0 10px 0 12px; border: 0; border-radius: 21px; '
       'background: rgba(36,31,43,.06); font: 600 12px -apple-system, system-ui, sans-serif; color: #241F2B; display: flex; align-items: center; gap: 5px;">Week'
       '<svg class="i" width="11" height="11" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 9l6 6 6-6"></path></svg></button>') + W840[_t1:]
W840 = W840.replace('<button style="width: 34px; height: 30px; border: 0; border-radius: 21px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.10); display: flex; align-items: center; gap: 7px;', '<button style="height: 30px; border: 0; border-radius: 21px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.10); display: flex; align-items: center; gap: 5px;', 1)  # the 34 px search button clipped its ⌘K (CR-157)
W840 = W840.replace('aria-label="Plan" style="height: 52px; flex: none; background: #F6F1EA; box-shadow: 0 1px 0 rgba(36,31,43,.08); display: flex; align-items: center; gap: 8px;', 'aria-label="Plan" style="height: 52px; flex: none; background: #F6F1EA; box-shadow: 0 1px 0 rgba(36,31,43,.08); display: flex; align-items: center; gap: 6px;', 1)
FA = open('live85/project/E-FullA-v2.dc.html').read()
BLKCSS = ''.join(re.findall(r'(\.(?:blk|dot)\{[^}]*\})', FA)[:2])

def plan_of(w):
    i = w.index('<div style="padding: 6px 12px 12px; display: flex; flex-direction: column; gap: 7px; overflow: hidden;">')
    return i, elem(w, i)

def parts(p):
    """Capture, hint, Inbox header, Inbox list, Routines header, 2 routines, Brain dump header, textarea, footer."""
    out = []; i = p.index('>') + 1
    while True:
        j = p.find('<', i)
        if j < 0 or p.startswith('</', j): break
        e = elem(p, j); out.append(p[j:e]); i = e
    return out

ICON_PANEL = '<svg class="i" width="17" height="17" viewBox="0 0 24 24" aria-hidden="true"><rect x="3.5" y="4.5" width="17" height="15" rx="2.5"></rect><path d="M9.5 4.5v15"></path></svg>'
CHEV_D = '<svg class="i" width="11" height="11" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 9l6 6 6-6"></path></svg>'
CHEV_R = '<svg class="i" width="11" height="11" viewBox="0 0 24 24" aria-hidden="true"><path d="M9 6l6 6-6 6"></path></svg>'
PIN = '<svg class="i" width="14" height="14" viewBox="0 0 24 24" aria-hidden="true"><path d="M9 4h6l-1 6 3 3H7l3-3z"></path><path d="M12 13v7"></path></svg>'
CLOSE = '<svg class="i" width="13" height="13" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 6l12 12M18 6L6 18"></path></svg>'

def toggle(pressed):
    if pressed:
        return ('<button aria-label="Hide Plan panel" aria-pressed="true" style="width: 34px; height: 30px; flex: none; border: 0; border-radius: 21px; '
                'background: rgba(17,97,92,.12); color: #0B4642; display: flex; align-items: center; justify-content: center;">' + ICON_PANEL + '</button>')
    return ('<button aria-label="Show Plan panel" aria-pressed="false" style="width: 34px; height: 30px; flex: none; border: 0; border-radius: 21px; '
            'background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.10); color: #4E4757; display: flex; align-items: center; justify-content: center;">' + ICON_PANEL + '</button>')

def add_toggle(w, pressed):
    i = w.index('role="toolbar" aria-label="Plan"'); j = w.index('>', i) + 1
    return w[:j] + toggle(pressed) + w[j:]

def sections(p, collapsed=('Routines',)):
    """B: each section header gets a disclosure chevron; collapsed sections show only the header and a count."""
    c = parts(p)
    hdr = lambda title, right, open_: (
        f'<button aria-expanded="{"true" if open_ else "false"}" style="display: flex; align-items: center; gap: 5px; margin-top: 8px; padding: 2px 2px; border: 0; '
        f'background: none; font: 700 13px Manrope, system-ui, sans-serif; color: #241F2B; text-align: left;">'
        f'<span style="color: #6A6273; display: flex;">{CHEV_D if open_ else CHEV_R}</span><span style="flex: 1;">{title}</span>'
        f'<span style="font-size: 11.5px; font-weight: 500; color: #6A6273;">{right}</span></button>')
    inbox_open = 'Inbox' not in collapsed; rout_open = 'Routines' not in collapsed; dump_open = 'Brain dump' not in collapsed
    body = c[0] + c[1] + hdr('Inbox', '3', inbox_open) + (c[3] if inbox_open else '')
    body += hdr('Routines', 'drag onto a day' if rout_open else '2', rout_open) + (c[5] + c[6] if rout_open else '')
    body += hdr('Brain dump', '⇧⌘N', dump_open) + (c[8] + c[9] if dump_open else '')
    return p[:p.index('>') + 1] + body + '</div>'

def tabs(p, sel='Inbox'):
    """B (narrow variant): one section at a time behind a segmented control."""
    c = parts(p)
    seg = ''.join(
        f'<button role="tab" aria-selected="{"true" if t == sel else "false"}" style="flex: 1 1 auto; min-width: 0; padding: 0 5px; white-space: nowrap; border: 0; border-radius: 19px; font: {"700" if t == sel else "600"} 11px Manrope, system-ui, sans-serif; '
        f'background: {"#FFFDF9" if t == sel else "transparent"}; box-shadow: {"0 0 0 1px rgba(36,31,43,.10)" if t == sel else "none"}; color: {"#241F2B" if t == sel else "#4E4757"};">{lab}</button>'
        for t, lab in (('Inbox', 'Inbox 3'), ('Routines', 'Routines'), ('Brain dump', 'Brain dump')))
    bar = f'<div role="tablist" aria-label="Plan sections" style="display: flex; height: 30px; margin-top: 8px; border-radius: 21px; background: rgba(36,31,43,.06); padding: 2px; box-sizing: border-box;">{seg}</div>'
    content = {'Inbox': c[3], 'Routines': c[5] + c[6], 'Brain dump': c[8] + c[9]}[sel]
    return p[:p.index('>') + 1] + c[0] + c[1] + bar + content + '</div>'

def set_plan(w, newp):
    a, e = plan_of(w); return w[:a] + newp + w[e:]

def hide_plan(w, five_days):
    a, e = plan_of(w); w = w[:a] + w[e:]
    w = w.replace('grid-template-columns: 196px 620px 248px;', 'grid-template-columns: 816px 248px;')
    w = w.replace('grid-template-columns: 196px minmax(0, 1fr);', 'grid-template-columns: minmax(0, 1fr);')
    if five_days: w = add_friday(w)
    return w

def add_friday(w):
    g0 = w.index('role="grid" aria-label="Week of 2 November'); g0 = w.rfind('<div', 0, g0); g1 = elem(w, g0); g = w[g0:g1]
    g = g.replace('Monday to Thursday visible', 'Monday to Friday visible').replace('width: 576px; height: 46px; display: grid; grid-template-columns: repeat(4,', 'width: 720px; height: 46px; display: grid; grid-template-columns: repeat(5,')
    thu = g.rfind('<div role="columnheader"'); thu_e = elem(g, thu)
    fri = g[thu:thu_e].replace('>Thu<', '>Fri<').replace('>5<', '>6<')
    g = g[:thu_e] + ' ' + fri + g[thu_e:]
    line = '<div style="position: absolute; left: 620px; top: 46px; width: 1px; height: 702px; background: rgba(36,31,43,.07);"></div>'
    k = g.index('<div aria-hidden="true">') + len('<div aria-hidden="true">'); g = g[:k] + line + g[k:]
    blocks = []
    for m in re.finditer(r'<button class="blk" aria-label="[^"]*Thursday[^"]*" style="left: 480px;', g):
        b = g[m.start():elem(g, m.start())]
        blocks.append(b.replace('Thursday', 'Friday').replace('left: 480px;', 'left: 624px;', 1))
    g = g[:-6] + ''.join(blocks) + g[-6:]
    return w[:g0] + g + w[g1:]

def floating(w, inner, label='Plan panel', left=10):
    """Plan panel brought out over the grid (does not squeeze it); pin docks it, Esc or a drop on the grid closes it."""
    head = (f'<div style="display: flex; align-items: center; gap: 6px; padding: 10px 12px 2px;"><span style="flex: 1; font: 700 13px Manrope, system-ui, sans-serif;">Plan</span>'
            f'<button aria-label="Keep the Plan panel open" title="Keep open" style="width: 26px; height: 26px; border: 0; border-radius: 13px; background: rgba(36,31,43,.06); color: #4E4757; display: flex; align-items: center; justify-content: center;">{PIN}</button>'
            f'<button aria-label="Close" style="width: 26px; height: 26px; border: 0; border-radius: 13px; background: rgba(36,31,43,.06); color: #4E4757; display: flex; align-items: center; justify-content: center;">{CLOSE}</button></div>')
    panel = (f'<div role="dialog" aria-label="{label}" aria-modal="false" style="position: absolute; left: {left}px; top: 62px; bottom: 12px; width: 236px; z-index: 5; border-radius: 16px; '
             f'background: #F6F1EA; box-shadow: 0 0 0 .5px rgba(36,31,43,.20), 0 18px 40px rgba(36,31,43,.22), 0 4px 10px rgba(36,31,43,.08); display: flex; flex-direction: column; overflow: hidden;">'
             + head + inner + '</div>')
    i = w.index('<div style="position: absolute; left: 216px; top: 0; right: 0; bottom: 0; display: flex; flex-direction: column;">'); e = elem(w, i)
    return w[:e - 6] + panel + w[e - 6:]

def divider(w):
    """Hover state of the panel's edge: drag to resize, drag past the minimum to hide."""
    w = w.replace('<div style="flex: 1; display: grid; grid-template-columns: 196px', '<div style="position: relative; flex: 1; display: grid; grid-template-columns: 196px', 1)
    k = w.index('<div style="position: relative; flex: 1; display: grid;'); e = elem(w, k)
    h = ('<div aria-hidden="true" style="position: absolute; left: 195px; top: 0; bottom: 0; width: 2px; background: rgba(17,97,92,.45);"></div>'
         '<div aria-hidden="true" style="position: absolute; left: 188px; top: 300px; width: 16px; height: 40px; border-radius: 8px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(17,97,92,.45), 0 2px 6px rgba(36,31,43,.12); '
         'display: flex; align-items: center; justify-content: center; font: 700 12px -apple-system, system-ui; color: #0B4642;">⋮</div>'
         '<div aria-hidden="true" style="position: absolute; left: 210px; top: 306px; padding: 4px 8px; border-radius: 7px; background: #241F2B; color: #FFFFFF; font: 600 11px -apple-system, system-ui; white-space: nowrap;">'
         'Drag to resize · drag left to hide</div>')
    return w[:e - 6] + h + w[e - 6:]

def sidebar_popover(w):
    """C: Inbox opened from the sidebar as a popover; there is no Plan column."""
    p = W1280[plan_of(W1280)[0]:plan_of(W1280)[1]]; c = parts(p)
    w = w.replace('<a href="#"', '<a href="#"', 1)
    pop = ('<div role="dialog" aria-label="Inbox" style="position: absolute; left: 206px; top: 92px; width: 250px; z-index: 6; border-radius: 14px; background: #F6F1EA; '
           'box-shadow: 0 0 0 .5px rgba(36,31,43,.20), 0 18px 40px rgba(36,31,43,.22); padding: 10px 12px 12px; display: flex; flex-direction: column; gap: 7px; font-family: Manrope, system-ui, sans-serif;">'
           '<div aria-hidden="true" style="position: absolute; left: -6px; top: 16px; width: 12px; height: 12px; background: #F6F1EA; transform: rotate(45deg); box-shadow: -0.5px 0.5px 0 rgba(36,31,43,.20);"></div>'
           + c[2].replace('margin-top: 8px; ', '') + c[3] +
           '<div style="font-size: 11.5px; color: #6A6273;">Drag onto the grid · Esc closes</div></div>')
    return w[:-6] + pop + w[-6:]

def rail(w, hover=False):
    """D: after a pause the panel shrinks to a 30 px rail; pointing at the rail (or clicking an icon) slides the panel out."""
    ic = [('Inbox, 3', '<path d="M4 13l2.5-7h11L20 13v5H4z"></path><path d="M4 13h4.5l1 2h5l1-2H20"></path>'),
          ('Routines, 2', '<path d="M17 3l3 3-3 3"></path><path d="M20 6H8a4 4 0 00-4 4"></path><path d="M7 21l-3-3 3-3"></path><path d="M4 18h12a4 4 0 004-4"></path>'),
          ('Brain dump', '<path d="M5 6h14M5 11h14M5 16h9"></path>')]
    btns = ''.join(f'<button aria-label="Show {l}" style="width: 26px; height: 26px; border: 0; border-radius: 13px; background: {"rgba(17,97,92,.14)" if hover and n == 0 else "none"}; color: {"#0B4642" if hover and n == 0 else "#4E4757"}; display: flex; align-items: center; justify-content: center;"><svg class="i" width="15" height="15" viewBox="0 0 24 24" aria-hidden="true">{d}</svg></button>' for n, (l, d) in enumerate(ic))
    r = ('<div role="toolbar" aria-label="Plan panel, hidden" style="background: #F6F1EA; box-shadow: 1px 0 0 rgba(36,31,43,.10); position: relative; z-index: 1; '
         'display: flex; flex-direction: column; align-items: center; gap: 6px; padding-top: 10px; box-sizing: border-box;">' + btns +
         '<span aria-hidden="true" style="margin-top: 4px; width: 4px; height: 4px; border-radius: 2px; background: #11615C;"></span></div>')
    w = w.replace('grid-template-columns: 816px 248px;', 'grid-template-columns: 30px 786px 248px;')
    k = w.index('grid-template-columns: 30px 786px 248px;'); k = w.index('>', k) + 1
    return w[:k] + r + w[k:]

def frame(w, zoom, ww, wh, title, notes, tag='Proposal · not approved'):
    box = f'<div style="width: {int(ww*zoom)}px; height: {int(wh*zoom)}px; overflow: hidden; flex: none;"><div style="zoom: {zoom};">{w}</div></div>'
    cap = (f'<div style="width: {max(int(ww*zoom), 300)}px; font-size: 14px; line-height: 20px; color: #4E4757;"><div style="font-weight: 800; font-size: 16px; color: #241F2B;">{title}</div>'
           + ''.join(f'<div>{n}</div>' for n in notes) + f'<span class="th" style="margin-top: 6px;">{tag}</span></div>')
    return f'<section aria-label="{title}" style="display: flex; flex-direction: column; gap: 10px;">{box}{cap}</section>'

def panel_only(inner, title, notes, h=748):
    box = f'<div style="width: 196px; max-height: {h}px; overflow: hidden; border-radius: 14px; background: #F6F1EA; box-shadow: 0 0 0 1px rgba(36,31,43,.10); font-family: Manrope, system-ui, sans-serif; color: #241F2B;">{inner}</div>'
    cap = f'<div style="width: 300px; font-size: 14px; line-height: 20px; color: #4E4757;"><div style="font-weight: 800; font-size: 16px; color: #241F2B;">{title}</div>' + ''.join(f'<div>{n}</div>' for n in notes) + '<span class="th" style="margin-top: 6px;">Proposal · not approved</span></div>'
    return f'<section aria-label="{title}" style="display: flex; gap: 18px; align-items: flex-start;">{box}{cap}</section>'

def row(t, sub, items):
    return (f'<div style="display: flex; flex-direction: column; gap: 14px;"><div><div style="font-size: 26px; font-weight: 800;">{t}</div>'
            f'<div style="font-size: 16px; color: #4E4757; max-width: 2600px;">{sub}</div></div><div style="display: flex; gap: 40px; row-gap: 32px; align-items: flex-start; flex-wrap: wrap;">{"".join(items)}</div></div>')

def build():
    P = W1280[plan_of(W1280)[0]:plan_of(W1280)[1]]
    Z, Z8 = 0.55, 0.62
    A = [
        frame(divider(add_toggle(W1280, True)), Z, 1280, 800, 'A1 · Open (today\'s layout) + hide button', [
            'New toolbar button at the left, mirroring the inspector button on the right. View menu: Hide Plan Panel / Show Plan Panel (shortcut assigned within the ED-095 scheme on approval).',
            'Edge drawn in its hover state: drag to resize (176–300), drag past the minimum to hide.']),
        frame(hide_plan(add_toggle(W1280, False), True), Z, 1280, 800, 'A2 · Hidden by you', [
            'The week gains 196 px: Friday comes into view (Mon–Fri). Sidebar Inbox · Routines · Brain dump, ⌘N Capture and ⇧⌘N Brain dump still work.',
            'Drag from the grid\'s left edge, click the button or use the menu to bring it back. The choice is remembered per window.']),
        frame(floating(hide_plan(add_toggle(W1280, False), True), P), Z, 1280, 800, 'A3 · Brought out when needed', [
            'While hidden, the button opens the panel over the grid without squeezing it. Drop a task on the grid, press Esc or click away: it closes.',
            'The pin keeps it open (docks it back as A1).']),
        frame(hide_plan(add_toggle(W840, False), False), Z8, 840, 640, 'A4 · Hidden automatically on a small window', [
            'At 840 the Day · 3 days · Week · Month tabs become one Week ⌄ pop-up so the Plan button fits. Below a width threshold (proposed: when the grid would show fewer than 3 days) the panel hides on its own; at 840 the grid gets 624 px and shows Mon–Thu instead of under 3 days.',
            'Widening the window brings it back, unless you hid it yourself. Same button and A3 floating panel.']),
    ]
    B = [
        panel_only(sections(P, ('Routines',)), 'B1 · Sections you can collapse', [
            'Each header (Inbox, Routines, Brain dump) folds with its chevron: any one, two or all three visible. Capture stays on top.',
            'Shown: Inbox and Brain dump open, Routines folded (count 2). Folded state is remembered.']),
        panel_only(sections(P, ('Inbox', 'Routines')), 'B2 · Only Brain dump open', ['Two folded headers give Brain dump the room; text box unchanged.']),
        panel_only(tabs(P, 'Inbox'), 'B3 · Tabs variant (one at a time)', [
            'Segmented control Inbox · Routines · Brain dump. Simpler, but never shows two together; offered as the narrow-window form.']),
        panel_only(tabs(P, 'Brain dump'), 'B4 · Tabs variant, Brain dump', ['Same panel with Brain dump selected.']),
    ]
    C = [
        frame(sidebar_popover(hide_plan(W1280, True)), Z, 1280, 800, 'C1 · No Plan column; open from the sidebar', [
            'Inbox, Routines and Brain dump live only in the sidebar. Clicking Inbox opens a popover; Routines the same; Brain dump opens its sheet (⇧⌘N).',
            'Most room always, but you can\'t keep the Inbox in view while planning several tasks onto the week.']),
    ]
    D = [
        frame(rail(hide_plan(W1280, True)), Z, 1280, 800, 'D1 · Auto-hidden after a pause', [
            'When you have not used the panel for a while (proposed 8 s after the pointer and focus leave it), it shrinks to a 30 px rail beside the week with Inbox, Routines and Brain dump icons; the dot says the Inbox has items.',
            'The week gets the space (Mon–Fri). Small windows: rail from the start.'], 'Proposal · not approved · advised against'),
        frame(floating(rail(hide_plan(W1280, True), True), P, left=36), Z, 1280, 800, 'D2 · Pointer on the rail: it slides out', [
            'Pointing at the rail (after a short delay) or clicking an icon brings the panel out over the grid at that section; dragging a task out works. It hides again after the pause unless pinned.',
            'Keyboard: Tab reaches the rail; Enter opens. Reduced motion: appears without sliding.'], 'Proposal · not approved · advised against'),
    ]
    AB = [
        frame(divider(add_toggle(set_plan(W1280, sections(P, ('Routines',))), True)), 0.7, 1280, 800, 'A+B · 1 · Docked, sections, hide button', [
            'A1 with B1 sections: Routines folded. Drag the edge or click the button to hide; the week takes the space.']),
        frame(floating(hide_plan(add_toggle(W840, False), False), sections(P, ('Routines',))), 0.8, 840, 640, 'A+B · 2 · Small window: hidden, brought out', [
            'Auto-hidden at 840; the button brings the same sectioned panel over the grid; pin docks it if the window is wide enough.']),
    ]
    table = '''<div style="width: 2700px; border-radius: 18px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.10); padding: 22px 26px; font-size: 15px; line-height: 22px; color: #4E4757; display: flex; flex-direction: column; gap: 10px;">
<div style="font-size: 20px; font-weight: 800; color: #241F2B;">Compare · native fit and trade-offs</div>
<div><b style="color:#241F2B">A · Collapsible panel:</b> native on Mac (a collapsible split-view pane with a toolbar button and a View menu item, as Mail, Notes and Xcode do) and a standard web pattern (VS Code, Figma, Gmail). Keyboard and screen readers: one labelled button with pressed state; Hide/Show announced. Reduced motion: no slide, it appears in place.</div>
<div><b style="color:#241F2B">B · Sections:</b> works inside A or alone; native disclosure headers (Finder sidebar sections). Tabs (B3–B4) are the fallback form when space is short.</div>
<div><b style="color:#241F2B">C · Sidebar only:</b> most room, simplest window; loses "see the Inbox while dragging several tasks onto the week". Already partly true today: the sidebar has Inbox, Routines and Brain dump.</div>
<div><b style="color:#241F2B">D · Auto-hide on inactivity:</b> gives the most room without a click, and the rail keeps it discoverable. Against it: Mac and web panels do not hide on a timer (the Dock is the only common precedent), the panel can vanish mid-thought or appear when you only pass the pointer by, content moves while you work, the timing is hard for keyboard, switch and screen-reader users, and it conflicts with reduced motion. A4 already hides it automatically when space is short. If you prefer D, I would make the timer an opt-in setting on top of A.</div>
<div><b style="color:#241F2B">Recommendation: A + B</b> (bottom row). Unchanged in every option: ⌘N Capture, ⇧⌘N Brain dump, sidebar items, Day menu, ⌘K palette, the inspector and its ⌥⌘I button. If approved, it is drawn on E-FullA-v2, E-G4-3-Narrow and their dark copies, plus web (same, without the View menu).</div>
<div>All frames are light mode, Mac at 1280 × 800 (E-FullA-v2) and 840 × 640 (E-G4-3-Narrow); Friday's blocks in A2/A3/C1 repeat Thursday's routine to fill the extra day. Nothing on the active boards changed.</div></div>'''
    body = ('<div style="width: 2900px; height: 4180px; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 46px; overflow: hidden;">'
            '<header><h1 style="margin: 0; font-size: 36px; line-height: 44px; font-weight: 700; letter-spacing: -0.6px;">Plan panel on Mac and web · hide it, bring it back · options A, B, C, D and A + B for your review</h1>'
            '<p style="margin: 8px 0 0; font-size: 18px; color: #4E4757;">Your comment: the column with Capture, Inbox, Routines and Brain dump should get out of the way to give the week more room, come back easily, and hide on smaller windows. Today it is always 196 px wide (E-FullA-v2, E-G4-3-Narrow). Nothing is approved or merged.</p></header>'
            + row('A · Collapsible Plan panel', 'Hide and show with a toolbar button, the View menu or by dragging its edge; hides itself on small windows; comes back over the grid when needed.', A)
            + row('B · Sections inside the panel', 'Show Inbox, Routines and Brain dump separately or together. Panels at 100 %.', B)
            + row('C · Sidebar only', 'No column at all; each part opens from the sidebar when needed.', C)
            + row('D · Hide automatically when not in use', 'Your first idea, drawn so you can compare: the panel shrinks to a rail after a pause and slides out when you point at it.', D)
            + row('A + B · Recommended', 'The collapsible panel with collapsible sections.', AB)
            + table + '</div>')
    head = open('h/head.html').read().replace('<title>E · Responsive</title>', '<title>E · Plan panel options</title>').replace('</style>', BLKCSS + '[role=toolbar][aria-label=Plan]>*{flex-shrink:0;white-space:nowrap}</style>', 1)
    tail = '\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":2900,"height":4180}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n'
    return head + body + tail

if __name__ == '__main__':
    open('w87/project/E-PlanPanel-Options.dc.html', 'w').write(build()); print('ok')
