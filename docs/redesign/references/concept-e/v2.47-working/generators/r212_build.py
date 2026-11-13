import os, sys, re
sys.path.insert(0, '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/r22')
H = int(sys.argv[1])
import ws
from ws import *
L = '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/live/project/'
EP1 = open(L + 'E-Phones.dc.html', encoding='utf-8').read()
def frame_at(s, st): return s[st:block(s, st, 'div')]
def hide(fr, pat):
    while pat in fr:
        i = fr.index(pat); a = fr.rfind('<', 0, i); tag = re.match(r'<(\w+)', fr[a:]).group(1); fr = fr[:a] + fr[block(fr, a, tag):]
    return fr
def pane(fr, w, h, top, ph, drop=()):
    fr = re.sub(r'^<div style="position: relative; width: (390|412)px; height: (\d+)px; border-radius: \d+px;([^"]*?)box-shadow:[^;"]*(;[^"]*)?"',
                lambda m: '<div style="position: absolute; left: 0; top: %dpx; width: %dpx; height: %dpx; border-radius: 0;%s"' % (-top, w, ph, m.group(3)), fr, count=1)
    for pat in ('aria-label="Main"', 'aria-label="Add a task', 'border-radius: 25px; background: #000;', 'border-radius: 50%; background: #000;') + tuple(drop):
        fr = hide(fr, pat)
    fr = re.sub(r'<div aria-hidden="true" style="position: absolute; bottom: 8px; left: \d+px; width: \d+px; height: [45]px;[^"]*"></div>', '', fr)
    return '<div style="position: relative; width: %dpx; height: %dpx; overflow: hidden; background: %s;">%s</div>' % (w, h, GROUND, fr)
ICAL, ACAL = frame_at(EP1, 125435), frame_at(EP1, 191628)
def seg(sel, font):
    return ('<div role="tablist" aria-label="Calendar range" style="display: flex; gap: 2px; padding: 4px; border-radius: 22px; background: #ECE5DC; font: 600 15px %s;">%s</div>') % (
        font, ''.join('<button role="tab"%s style="height: 36px; padding: 0 18px; border: 0; border-radius: 18px; font: inherit; %s">%s</button>' % (
            ' aria-selected="true"' if v == sel else '', ('background: %s; color: %s; box-shadow: 0 1px 3px rgba(36,31,43,.12);' % (SURF, ACC)) if v == sel else 'background: transparent; color: #4E4757;', v) for v in ('Month', 'Week')))
def month_nav(rows, android):
    n = (android_drawer if android else ipad_sidebar)(rows, 'Month')
    return n
F = {}
# expanded: the Workspace's Month view (Calendar views › Month), Plan panel kept, the one month component at touch size
def ws_month(android):
    w, h, top = (1064, 772, 28) if android else (964, 796, 24)
    tb = toolbar(w, android)
    tb = tb.replace(' aria-selected="true"', '').replace('background: %s; color: %s; box-shadow: 0 1px 3px rgba(36,31,43,.12);' % (SURF, ACC), 'background: transparent; color: #4E4757;')
    tb = tb.replace('>Month</button>', ' aria-selected="true" data-sel>Month</button>', 1)
    tb = re.sub(r'(<button role="tab")( style="[^"]*?)background: transparent; color: #4E4757;("[^>]*data-sel>Month)', r'\1\2background: %s; color: %s; box-shadow: 0 1px 3px rgba(36,31,43,.12);\3' % (SURF, ACC), tb).replace(' data-sel', '')
    tb = tb.replace('2–8 Nov 2026', 'November 2026')
    src = ACAL if android else ICAL
    body = pane(src, w - 240, h - 60, 140 if not android else 150, 892 if android else 844)
    return ('<div style="position: absolute; left: 216px; top: %dpx; width: %dpx; height: %dpx; display: flex; flex-direction: column; background: %s;">%s<div style="display: flex;">%s%s</div></div>') % (
        top, w, h, GROUND, tb, plan_panel(240, h - 60), body)
navI = ipad_sidebar(FULL_ROWS, 'Month'); navA = android_drawer(FULL_ROWS, 'Month')
F['i1'] = device(1180, 820, navI + ws_month(False), False)
F['a1'] = device(1280, 800, navA + ws_month(True), True)
# medium: Calendar tab / rail destination, Month · Week
medI = ipad_top_tabs(['Today', 'Inbox', 'Calendar', 'Search'], 'Calendar', 820, day=False)
F['i2'] = device(820, 1180, medI + '<div style="position: absolute; left: 0; right: 0; top: 96px; display: flex; justify-content: center; z-index: 5;">%s</div>' % seg('Month', '-apple-system, system-ui, sans-serif')
                 + '<div style="position: absolute; left: 0; top: 150px;">%s</div>' % pane(ICAL, 820, 1030, 48, 844), False)
railA = android_rail(['Today', 'Inbox', 'Calendar', 'Search'], 'Calendar')
F['a2'] = device(800, 1280, railA + '<div style="position: absolute; left: 88px; right: 0; top: 40px; display: flex; justify-content: center; z-index: 5;">%s</div>' % seg('Month', 'Roboto, system-ui, sans-serif')
                 + '<div style="position: absolute; left: 88px; top: 96px;">%s</div>' % pane(ACAL, 712, 1184, 40, 892), True)
def tag(c, t): return '<span class="%s">%s</span>' % (c, t)
def fr(key, w, h, sc, label, note):
    return ('<figure style="margin: 0; display: flex; flex-direction: column; gap: 8px; width: %dpx;"><figcaption style="font: 700 15px Manrope; color: #4E4757;">%s</figcaption>'
            '<div style="width: %dpx; height: %dpx;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div>'
            '<div style="font-size: 13.5px; line-height: 20px; color: #4E4757;">%s</div></figure>') % (w * sc + 18, label, w * sc + 18, h * sc + 18, w, h, sc, F[key], note)
ri = [fr('i1', 1180, 820, .5, '1 · Expanded · Workspace › Month', 'Calendar views › Month in the sidebar, Month in the toolbar. The one month component (ED-075) fills the grid area beside the Plan panel; tapping a day shows it below (Open day). Week is R2-2.'),
      fr('i2', 820, 1180, .35, '2 · Medium · Calendar tab', 'The Calendar tab opens Month, with a Month · Week switch at the top: Week wherever the width allows (Q5, ED-075). Week here is the Workspace week at its narrower width (R2-2 rules: days that fit, minimum column 180). The day panel scrolls.')]
ra = [fr('a1', 1280, 800, .47, '1 · Expanded · Workspace › Month', 'The same on Android, with the drawer.'),
      fr('a2', 800, 1280, .33, '2 · Medium · Calendar in the rail', 'Calendar in the rail opens Month, with Month · Week.')]
notes = ['<b>One month grid, everywhere (ED-075):</b> the approved phone Calendar screens (E-Phones) widened to their pane, at phone sizes (the touch scale): the same dots, +n counts, today ring, day panel with Open day. No second month design.',
         '<b>Expanded Full = the Workspace:</b> Month is one of its Calendar views (Day · 3 days · Week · Month), reached from the sidebar or the toolbar; the Plan panel stays. <b>Medium:</b> the Calendar tab or rail destination, with Month · Week. <b>Compact:</b> the phone Calendar tab (Month only).',
         '<b>Minimal on tablets</b> uses E-Minimal’s Calendar place (by width, ED-266); it is not redrawn here.',
         '<b>Interaction:</b> swipe or ‹ › changes month; every day is a button with a spoken summary (ED-075). Dragging tasks between days on Week is pointer-only today (ED-116); touch long-press drag is not drawn.']
li = ''.join('<li style="margin: 0 0 8px;">%s</li>' % n for n in notes)
def row(title, frs): return '<section aria-label="%s" style="display: flex; flex-direction: column; gap: 12px;"><div style="font: 700 22px Manrope;">%s</div><div style="display: flex; gap: 28px; align-items: flex-start;">%s</div></section>' % (title, title, ''.join(frs))
body = ('<header style="display: flex; flex-direction: column; gap: 8px;"><h1 style="margin: 0; font-size: 34px; line-height: 40px; font-weight: 700; letter-spacing: -0.6px;">E · Round 2 · R2-12 · Calendar on tablets: Month and Week</h1>'
        '<p style="margin: 0; font-size: 17px; line-height: 26px; color: #4E4757;">Stage 3, second board. Dark on E-R2-12-Dark. Approved by the owner, 13 Nov 2026 (ED-293).</p>'
        '<div style="display: flex; gap: 6px;">%s %s</div></header>'
        '<ul style="margin: 0; padding-left: 18px; font-size: 15px; line-height: 23px; color: #4E4757; columns: 2; column-gap: 48px;">%s</ul>%s%s') % (
            tag('tb', 'Approved · ED-293'), tag('tn', 'Light'), li, row('iPad', ri), row('Android tablet', ra))
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-12</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 1500px; height: %dpx; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 32px;">\n' % H
        + body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":1500,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
os.makedirs('project', exist_ok=True)
open('project/E-R2-12.dc.html', 'w', encoding='utf-8').write(page)
sys.path.insert(0, 'h'); from darkify import darkify
dark = darkify(page).replace('class="blk-d', 'class="blk').replace('<title>E · R2-12</title>', '<title>E · R2-12 · Dark</title>').replace('Dark on E-R2-12-Dark.', 'Light on E-R2-12.').replace('<span class="tn">Light</span>', '<span class="tn">Dark</span>')
open('project/E-R2-12-Dark.dc.html', 'w', encoding='utf-8').write(dark)
print('ok')
