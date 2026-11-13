import os, sys, re, copy
sys.path.insert(0, '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/r22')
H = int(sys.argv[1])
import ws
from ws import *
L = '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/live/project/'
EP1 = open(L + 'E-Phones.dc.html', encoding='utf-8').read(); EP2 = open(L + 'E-Phones-2.dc.html', encoding='utf-8').read()
def frame_at(s, st): return s[st:block(s, st, 'div')]
def el(s, marker, tag='div'):
    i = s.index(marker); a = s.rfind('<' + tag, 0, i); return s[a:block(s, a, tag)]

# --- sources (approved phone screens; phone sizes = the ED-256 touch scale)
ios_create = el(frame_at(EP1, 578185), 'role="dialog" aria-label="Task editor"')
ios_prop = el(frame_at(EP2, 19282), 'role="dialog" aria-label="Proposal"')
and_create = frame_at(EP1, 499707)
and_prop = frame_at(EP2, 71758)
def strip_grabber(h): return re.sub(r'<div aria-hidden="true" style="[^"]*width: 36px; height: 5px;[^"]*"></div>', '', h)
def as_panel(h, w, hgt, radius):
    h = re.sub(r'position: absolute; left: 0; right: 0; top: 56px; bottom: 0;( z-index: 31;)? border-radius: 38px 38px 0 0;', 'position: relative; box-sizing: border-box; width: %dpx; height: %dpx; border-radius: %s; overflow: hidden;' % (w, hgt, radius), h, count=1)
    return strip_grabber(h)
def android_screen_in_sheet(fr, hgt):
    fr = re.sub(r'<div aria-hidden="true" style="position: absolute; top: 12px; left: 198px; width: 16px; height: 16px; border-radius: 50%; background: #000; z-index: 20;"></div>', '', fr)
    fr = re.sub(r'^<div style="position: relative; width: 412px; height: 892px; border-radius: 44px; background: #FBF7F1; overflow: hidden; box-shadow:[^"]*;', '<div style="position: absolute; left: 0; top: -28px; width: 412px; height: 892px; border-radius: 0; background: #FBF7F1; overflow: hidden; box-shadow: none;', fr, count=1)
    kb = '<div aria-hidden="true" style="position: absolute; left: 0; right: 0; bottom: 0; height: 300px; background: #ECE6EE;'
    if kb in fr:
        a = fr.index(kb); fr = fr[:a] + fr[block(fr, a, 'div'):]
    return fr

GHOST = [('Email Sam', 12.0, 12.5, '#11615C', 'ghost'), ('Taxes', 13.25, 14.0, '#11615C', 'ghost')]
def ws_with(w, h, days, android, ghost=False):
    saved = ws.WEEK['Tue']
    if ghost: ws.WEEK['Tue'] = saved + GHOST
    try: return workspace(w, h, days, android)
    finally: ws.WEEK['Tue'] = saved

POP = 'box-shadow: 0 0 0 .5px rgba(36,31,43,.14), 0 18px 48px rgba(36,31,43,.22);'
def ipad_popover(content, right, top, w, hgt, arrow_x):
    return ('<div role="dialog" aria-label="Create task" style="position: absolute; right: %dpx; top: %dpx; width: %dpx; height: %dpx; border-radius: 26px; background: %s; %s overflow: hidden; z-index: 40;">%s</div>'
            '<span aria-hidden="true" style="position: absolute; left: %dpx; top: %dpx; width: 22px; height: 22px; background: %s; transform: rotate(45deg); border-radius: 4px; z-index: 39; box-shadow: -1px -1px 0 rgba(36,31,43,.08);"></span>') % (
                right, top, w, hgt, GROUND, POP, content, arrow_x - 11, top - 9, GROUND)

IC = {'brain': '<path d="M9 4a3 3 0 0 0-3 3v1a3 3 0 0 0-2 5 3 3 0 0 0 3 4 3 3 0 0 0 5 1V4.5A1 1 0 0 0 11 4zM15 4a3 3 0 0 1 3 3v1a3 3 0 0 1 2 5 3 3 0 0 1-3 4 3 3 0 0 1-5 1"></path>',
      'repeat': '<path d="M4 10V9a3 3 0 0 1 3-3h12l-3-3M20 14v1a3 3 0 0 1-3 3H5l3 3"></path>',
      'clip': '<rect x="6" y="4" width="12" height="17" rx="2"></rect><path d="M9 4V3h6v1M9 10h6M9 14h6"></path>',
      'task': '<circle cx="12" cy="12" r="8"></circle><path d="M8.5 12.5l2.3 2.3 4.7-5"></path>'}
def svg(k, s=20): return '<svg class="i" width="%d" height="%d" viewBox="0 0 24 24" aria-hidden="true">%s</svg>' % (s, s, IC[k])
def ipad_hold_menu(right, top):
    items = ''.join('<div role="menuitem" style="height: 52px; display: flex; align-items: center; justify-content: space-between; padding: 0 18px; font: 400 17px -apple-system, system-ui, sans-serif; color: %s; %s">%s%s</div>' % (
        INK, 'border-top: .5px solid rgba(36,31,43,.12);' if i else '', t, svg(k)) for i, (t, k) in enumerate((('Brain dump', 'brain'), ('Routine', 'repeat'), ('Paste a list', 'clip'))))
    return ('<div role="menu" aria-label="Add" style="position: absolute; right: %dpx; top: %dpx; width: 260px; border-radius: 22px; background: rgba(242,235,226,.94); backdrop-filter: blur(30px); '
            'box-shadow: inset 0 0 0 1px rgba(255,255,255,.6), 0 0 0 .5px rgba(36,31,43,.12), 0 18px 48px rgba(36,31,43,.22); overflow: hidden; z-index: 40;">%s</div>') % (right, top, items)
def android_plus_menu(right, top):
    items = ''.join('<div role="menuitem" style="height: 48px; display: flex; align-items: center; gap: 14px; padding: 0 16px; font: 400 15px Roboto, system-ui, sans-serif; color: %s;">%s%s</div>' % (INK, svg(k), t)
                    for t, k in (('Task', 'task'), ('Brain dump', 'brain'), ('Routine', 'repeat')))
    return ('<div role="menu" aria-label="Add" style="position: absolute; right: %dpx; top: %dpx; width: 220px; border-radius: 12px; background: #F3EEE6; padding: 8px 0; '
            'box-shadow: 0 2px 6px rgba(36,31,43,.18), 0 8px 24px rgba(36,31,43,.14); z-index: 40;">%s</div>') % (right, top, items)
def side_sheet(inner, top, w, modal):
    scrim = '<div aria-hidden="true" style="position: absolute; inset: 0; background: rgba(36,31,43,.32); z-index: 38;"></div>' if modal else ''
    return scrim + ('<aside style="position: absolute; right: 0; top: %dpx; bottom: 0; width: %dpx; border-radius: 28px 0 0 28px; background: %s; overflow: hidden; z-index: 40; '
                    'box-shadow: 0 0 0 1px rgba(36,31,43,.10), -8px 0 28px rgba(36,31,43,.14);">%s</div>') % (top, w, GROUND, inner) .replace('</div>', '</aside>', 0)

IPW = ipad_sidebar(FULL_ROWS, 'Plan') + ws_with(964, 796, ['Tue', 'Wed', 'Thu'], False)
F = {}
F['ip_tap'] = device(1180, 820, IPW + ipad_popover('<div style="position: absolute; left: 0; top: -12px;">%s</div>' % as_panel(ios_create, 400, 712, '0'), 14, 92, 400, 700, 1144), False)
F['ip_hold'] = device(1180, 820, IPW + ipad_hold_menu(14, 88), False)
_tue = ws.WEEK['Tue']; ws.WEEK['Tue'] = _tue + GHOST
IPG = ipad_sidebar(FULL_ROWS, 'Plan') + workspace_inline(964, 796, ['Tue', 'Wed'], False, 404)
panel = ('<div style="position: absolute; right: 8px; top: 32px; bottom: 8px; width: 390px; z-index: 40; border-radius: 26px; overflow: hidden; '
         'box-shadow: 0 0 0 .5px rgba(36,31,43,.14), 0 8px 28px rgba(36,31,43,.12);">%s</div>') % as_panel(ios_prop, 390, 780, '0')
F['ip_prop'] = device(1180, 820, IPG + panel, False)
ws.WEEK['Tue'] = _tue
ANW = android_drawer(FULL_ROWS, 'Plan') + ws_with(1064, 772, ['Mon', 'Tue', 'Wed', 'Thu'], True)
sheet_c = ('<div aria-hidden="true" style="position: absolute; inset: 0; background: rgba(36,31,43,.32); z-index: 38;"></div>'
           '<aside aria-label="New task" style="position: absolute; right: 0; top: 28px; bottom: 0; width: 412px; border-radius: 28px 0 0 28px; overflow: hidden; z-index: 40; box-shadow: -8px 0 28px rgba(36,31,43,.14);">%s</aside>') % android_screen_in_sheet(and_create, 772)
F['and_menu'] = device(1280, 800, ANW + android_plus_menu(14, 88), True)
F['and_create'] = device(1280, 800, ANW + sheet_c, True)
ws.WEEK['Tue'] = _tue + GHOST
ANG = android_drawer(FULL_ROWS, 'Plan') + workspace_inline(1064, 772, ['Tue', 'Wed', 'Thu'], True, 412)
ws.WEEK['Tue'] = _tue
sheet_p = ('<aside aria-label="Brain dump, proposal" style="position: absolute; right: 0; top: 28px; bottom: 0; width: 412px; overflow: hidden; z-index: 40; '
           'box-shadow: -1px 0 0 rgba(36,31,43,.12);">%s</aside>') % android_screen_in_sheet(and_prop, 772)
F['and_prop'] = device(1280, 800, ANG + sheet_p, True)

SC = 0.6
def tag(c, t): return '<span class="%s">%s</span>' % (c, t)
def fr(key, w, h, label, note):
    return ('<figure style="margin: 0; display: flex; flex-direction: column; gap: 8px; width: %dpx;"><figcaption style="font: 700 15px Manrope; color: #4E4757;">%s</figcaption>'
            '<div style="width: %dpx; height: %dpx;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div>'
            '<div style="font-size: 13.5px; line-height: 20px; color: #4E4757;">%s</div></figure>') % (w * SC + 14, label, w * SC + 14, h * SC + 14, w, h, SC, F[key], note)
row1 = [fr('ip_tap', 1180, 820, '1a · iPad · tap + → Create task in a popover', 'The approved Create task (ED-140) as an iPadOS popover from the toolbar +: tabs Task · Brain dump · Routine, title field and parser hint, the When card. The Workspace stays live behind it (no dimming). Done / Cancel as on iPhone; the popover scrolls.'),
        fr('ip_hold', 1180, 820, '1b · iPad · hold + → modes', 'Hold on + shows the native menu with Brain dump · Routine · Paste a list, as on iPhone (G2-8). Each opens the same popover on its tab.'),
        fr('ip_prop', 1180, 820, '1c · iPad · Plan it → the proposal beside the day', 'The one ProposalSheet (ED-150) as a panel beside the day: the grid narrows to the days that fit and the Plan panel steps aside (ED-184). Proposed tasks show as dashed “new” blocks where they would land (Email Sam 12:00, Taxes 1:15). Nothing is written until Add to day.')]
row2 = [fr('and_menu', 1280, 800, '2a · Android · tap + → M3 menu', 'The + opens the M3 menu with Task · Brain dump · Routine, as the phone FAB menu does (G2-8).'),
        fr('and_create', 1280, 800, '2b · Android · Task → New task in a modal side sheet', 'The approved Android Create task (ED-141, ED-142) in an M3 modal side sheet (412 dp): × close, “New task”, Create, segmented Task · Brain dump · Routine, fields. Back closes it; the scrim dims the Workspace. The keyboard (full width on tablets) is drawn with the keyboard states later.'),
        fr('and_prop', 1280, 800, '2c · Android · Brain dump → the proposal in a standard side sheet', 'Plan it shows the same ProposalSheet in an M3 standard side sheet that sits beside the grid (it narrows; with fewer than 3 days the Plan panel steps aside, ED-184), so the dashed proposed blocks stay in view. Add to day writes; Discard leaves everything as it was.')]
notes = ['<b>One Add on every width (rules, CLAUDE.md §11):</b> the approved phone screens are reused unchanged inside tablet containers, since phone sizes are the touch scale (ED-256). No second Add or proposal design.',
         '<b>Containers by platform:</b> iPad uses the popover (Create) and a side panel (proposal); Android uses the M3 menu, a modal side sheet (Create) and a standard side sheet (proposal). Compact windows keep the phone full-screen screens.',
         '<b>Proposal rule:</b> rule-made changes (Brain dump, Routine) appear only in the ProposalSheet and as dashed proposed blocks; nothing is written before Add to day (CLAUDE.md §11; a test proving it is part of done).',
         '<b>Medium windows</b> (iPad top tabs, Android rail): the same popover anchors to the top-bar +, and the same side sheets open from the rail’s FAB. Not drawn again here.',
         '<b>Not on this board:</b> the keyboard (drawn on phones, ED-135/136; on iPad the floating or docked keyboard sits below the popover), dictation, and Paste a list’s preview.']
li = ''.join('<li style="margin: 0 0 8px;">%s</li>' % n for n in notes)
body = ('<header style="display: flex; flex-direction: column; gap: 8px;"><h1 style="margin: 0; font-size: 34px; line-height: 40px; font-weight: 700; letter-spacing: -0.6px;">E · Round 2 · R2-3 · Add on expanded tablets: Create task, modes and the proposal</h1>'
        '<p style="margin: 0; font-size: 17px; line-height: 26px; color: #4E4757;">Stage 1, step “Add” of the core journey (ED-166). On the approved touch Workspace (R2-2) inside the approved navigation (R2-1). Phone screens reused from E-Phones (Create task, ED-140 / ED-141) and E-Phones-2 (proposal, ED-150). Frames at 60 %%. Dark on E-R2-3-Dark. For owner review.</p>'
        '<div style="display: flex; gap: 6px;">%s %s</div></header>'
        '<ul style="margin: 0; padding-left: 18px; font-size: 15px; line-height: 23px; color: #4E4757; max-width: 2100px; columns: 2; column-gap: 48px;">%s</ul>'
        '<section aria-label="iPad" style="display: flex; flex-direction: column; gap: 12px;"><div style="font: 700 22px Manrope;">1 · iPad</div><div style="display: flex; gap: 28px; align-items: flex-start;">%s</div></section>'
        '<section aria-label="Android tablet" style="display: flex; flex-direction: column; gap: 12px;"><div style="font: 700 22px Manrope;">2 · Android tablet</div><div style="display: flex; gap: 28px; align-items: flex-start;">%s</div></section>') % (
            tag('th', 'Proposed · for owner review'), tag('tn', 'Light'), li, ''.join(row1), ''.join(row2))
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-3</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 2560px; height: %dpx; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 32px;">\n' % H
        + body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":2560,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
os.makedirs('project', exist_ok=True)
open('project/E-R2-3.dc.html', 'w', encoding='utf-8').write(page)
sys.path.insert(0, 'h'); from darkify import darkify
dark = darkify(page).replace('class="blk-d', 'class="blk').replace('<title>E · R2-3</title>', '<title>E · R2-3 · Dark</title>').replace('Dark on E-R2-3-Dark.', 'Light on E-R2-3.').replace('>Light</span>', '>Dark</span>')
open('project/E-R2-3-Dark.dc.html', 'w', encoding='utf-8').write(dark)
print('ok')
